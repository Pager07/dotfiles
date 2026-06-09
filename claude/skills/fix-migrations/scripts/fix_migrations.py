# Run via:  uv run ./manage.py shell < <this file>   (cwd must be the repo root).
# Optional env: BASE_REF (default "master").
#
# Reconciles django_migrations with the actual schema after loading an anon/prod dump,
# then applies the current branch's genuinely-new migrations:
#   1. find new migrations on this branch vs BASE_REF (from git)
#   2. derive each app's rollback target from the new migration's real dependencies
#   3. migrate --fake (record the whole graph as applied)
#   4. migrate --fake <app> <target> (un-record just the new ones)
#   5. migrate <app> (really apply them -> adds the missing columns/tables)
import os
import subprocess
import sys
from collections import defaultdict

from django.core.management import call_command
from django.db import connection
from django.db.migrations.loader import MigrationLoader

if 'DYNO' in os.environ:
    sys.exit('REFUSING: this looks like a production (Heroku) environment.')

base = (os.environ.get('BASE_REF') or 'master').strip()

# --- 1. new migration files on this branch vs base -----------------------------------
diff = subprocess.run(
    ['git', 'diff', '--name-only', f'{base}...HEAD'], capture_output=True, text=True
)
if diff.returncode != 0:
    sys.exit(f'git diff failed:\n{diff.stderr}')

new_migs = []  # list of (app_label, migration_name)
for path in diff.stdout.splitlines():
    path = path.strip()
    if '/migrations/' not in path or not path.endswith('.py') or path.endswith('__init__.py'):
        continue
    parts = path.split('/')
    i = parts.index('migrations')
    new_migs.append((parts[i - 1], parts[i + 1][:-3]))

# --- 2. derive rollback target per app from real dependencies ------------------------
loader = MigrationLoader(connection, ignore_no_migrations=True)
disk = loader.disk_migrations
by_app = defaultdict(list)
for app, name in new_migs:
    by_app[app].append(name)

targets = {}  # app -> migration name to fake-rollback to (None = new app, roll to zero)
for app, names in by_app.items():
    names_set = set(names)
    target = 'ZERO'  # sentinel: found a new app with no same-app parent
    for name in names:
        mig = disk.get((app, name))
        if mig is None:
            continue
        same_app_parents = [d[1] for d in mig.dependencies if d[0] == app and d[1] != '__first__']
        existing_parents = [n for n in same_app_parents if n not in names_set]
        if same_app_parents and existing_parents:
            cand = sorted(existing_parents)[-1]
            target = cand if target == 'ZERO' else max(target, cand)
    targets[app] = None if target == 'ZERO' else target

# --- report --------------------------------------------------------------------------
print('\n=== fix-migrations ======================================')
print(f'database           : {connection.settings_dict.get("NAME")}')
print(f'base ref           : {base}')
if new_migs:
    print('new migrations     :')
    for app, name in new_migs:
        print(f'    {app}.{name}')
    print('rollback targets   :')
    for app, t in targets.items():
        print(f'    {app} -> {t or "zero (new app)"}')
else:
    print('new migrations     : none (will only sync state with --fake)')
print('=========================================================\n')

# --- 3/4/5. fake all, un-fake the delta, really apply --------------------------------
call_command('migrate', fake=True, verbosity=1)
for app, target in targets.items():
    call_command('migrate', app, target or 'zero', fake=True, verbosity=1)
for app in targets:
    call_command('migrate', app, verbosity=1)

print('\nDone: migration state synced' + (' and new migrations applied.' if new_migs else '.'))
