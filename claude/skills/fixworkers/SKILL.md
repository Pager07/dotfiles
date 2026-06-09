---
name: fixworkers
description: Diagnose and recover the local TutorCruncher2 RQ worker when background jobs fail with "Work-horse terminated unexpectedly; waitpid returned 256" or jobs aren't running. Use when the user reports an RQ job failure, a stuck/silent worker, or messages like "Invoice regeneration has failed" / "PO generation has failed" coming from the dev environment.
---

# Fix RQ workers (TutorCruncher2 local dev)

The user's local RQ worker is misbehaving — work-horses dying with exit 1, jobs queuing but not running, or fork-time crashes with no Python traceback. This skill walks the playbook that fixed it last time. **Do not skip the diagnosis steps.** "Just restart the worker" is the right answer some of the time, but not always — confirm the failure shape first.

## Step 1: Establish what's actually happening

Run these in parallel:

```bash
ps aux | grep -E "rqworker|rq worker" | grep -v grep
```

Look at the STAT column:
- `Tl` / `T` → worker is **suspended** (SIGSTOP, usually accidental Ctrl-Z). New jobs sit in the queue forever. Restart fixes it.
- `Sl` / `S` → worker is alive. The problem is elsewhere — keep going.
- No output → no worker running at all. Just start one.

```bash
free -h && uptime
journalctl --user -k 2>/dev/null | grep -i -E 'oom|killed process' | tail -20
```

This rules in or out OS-level OOM kills. If you see "Killed process" entries near the time of failure, it's memory pressure, not a code bug.

## Step 2: Inspect RQ's failed-job registry

This is the one diagnostic the user usually skips. The registry holds the actual exception (or lack thereof) for jobs RQ marked failed.

```bash
cd /home/sandeep/repos/TutorCruncher2 && DJANGO_SETTINGS_MODULE=TutorCruncher.settings.main .venv/bin/python -c "
import django; django.setup()
from TutorCruncher.tcrq import redis_client
from rq.registry import FailedJobRegistry
from rq import Queue
from rq.job import Job
conn = redis_client()
for qn in ['high','default','low','scheduler','scheduler_long']:
    q = Queue(qn, connection=conn)
    ids = FailedJobRegistry(queue=q).get_job_ids()
    print(qn, 'failed:', len(ids))
    for jid in ids[-5:]:
        try:
            j = Job.fetch(jid, connection=conn)
            print('  ', jid, j.func_name, j.ended_at)
            print('  exc:', (j.exc_info or '')[:600])
        except Exception as e:
            print('  ', jid, 'fetch err:', e)
"
```

What you're looking for:
- **Multiple unrelated jobs all dying with `Work-horse terminated unexpectedly; waitpid returned 256`** → the worker fork path itself is broken. Tiny jobs like `log_failed_login_for_user` dying with this message is the smoking gun. Go to Step 4.
- **A real Python traceback** in `j.exc_info` → it's a code bug or data issue. Read the traceback; this skill doesn't apply.
- **Memory error or 137 exit** → OS killed the horse. Reduce job size or close other apps.

## Step 3: If the user reported a specific failed job — try it synchronously

Skipping RQ entirely tells you whether the bug is in the *job* or in the *worker environment*. The job runs through `Job.perform()` in `TutorCruncher/tcrq/mod.py`, which sets up `hook_context.new_manager(branch)` and `dj_timezone.activate(branch.timezone)` — you must do the same when calling directly, otherwise you'll get a misleading `HookException: hook context not active` from the search hooks.

Template (adapt args):

```bash
cd /home/sandeep/repos/TutorCruncher2 && DJANGO_SETTINGS_MODULE=TutorCruncher.settings.main .venv/bin/python -c "
import django, traceback, resource
django.setup()
from datetime import datetime
from zoneinfo import ZoneInfo
from django.utils import timezone as dj_tz
from TutorCruncher.agency.models import Branch
from TutorCruncher.search.hooks import hook_context
# from TutorCruncher.<app>.<module> import <the_job_function>

branch = Branch.objects.get(id=<BRANCH_ID>)
dj_tz.activate(branch.timezone)
try:
    with hook_context.new_manager(branch):
        result = <the_job_function>(<args>, branch=branch)
    print('Success:', result)
except BaseException as e:
    print('FAILED:', type(e).__name__, repr(e))
    traceback.print_exc()
finally:
    rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    print(f'peak RSS: {rss/1024:.1f} MB')
"
```

If this **succeeds**, the user's data is now in the post-job state — the job effectively ran. They don't need to retry from the UI. Tell them this. If it **fails with a real exception**, that's the bug.

## Step 4: Recover the worker

Only after the diagnosis above. Don't kill the user's worker process without telling them — confirm first if a foreground session might be using it.

```bash
# Kill the broken/suspended worker (substitute the PID from Step 1)
kill -9 <PID>

# Clear stale bytecode — fork-time exit-1 is often from .pyc files left over after branch switches
find /home/sandeep/repos/TutorCruncher2/TutorCruncher -name __pycache__ -type d -exec rm -rf {} +

# Start a fresh worker
cd /home/sandeep/repos/TutorCruncher2 && source .venv/bin/activate && python manage.py rqworker high default low
```

Then trigger a tiny job (e.g. a failed login from the auth UI, or just enqueue something trivial) and watch the worker output. If horses still die exit-1 on trivial jobs after the cache wipe, the next suspects are environment vars — `SENTRY_DSN`, `LOGFIRE_TOKEN`, anything that runs in the forked child's startup. Check `_localsettings.py` and the user's shell env for stale tokens.

## Step 5: Report

Tell the user, in order:
1. **What you found** (worker state, failed-job registry contents, OS-level memory).
2. **Whether the original job ran successfully synchronously** — if yes, their data is already in the right state.
3. **What you did to recover** (if anything destructive — confirm before, report after).
4. **The likely root cause** based on the failure shape from Step 2. If the registry showed multiple unrelated jobs failing with exit 256, name that explicitly — it's environmental, not a TC bug.

Keep it short. Bulletpoints, not paragraphs. The user wants to know "is it fixed now and what was wrong" in under 30 seconds of reading.

## Notes / gotchas

- The "Invoice regeneration has failed" error message in the UI comes from a 60-second cached flag in Redis (`failed_inv_generate_{branch_id}`), set in `TutorCruncher/accounting/views/invoices/generate.py` when the view detects a failed RQ job. The flag is *not* cleared when the user successfully retries — so the message can persist for up to 60s after the actual failure was resolved. If the user reports seeing both "failed" and "Started bulk generating Invoices" on the same page, that's why; it's a UI artifact, not an active failure.
- `Job.perform()` in `TutorCruncher/tcrq/mod.py` is the real job entry point. It pops `branch` from kwargs, fetches the Branch, activates timezone, and wraps in `hook_context.new_manager(branch)`. Replicate that when running synchronously.
- `bulk_generate_invoices` runs on the `high` queue with `timeout=1800` (30 min) and is `@atomic` over the entire run. For a 6-month range it's still fine memory-wise (~150 MB peak in the case I tested) — don't assume OOM without evidence.
