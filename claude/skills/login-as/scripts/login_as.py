# Run via:  ROLE=<role> ROLE_ID=<id> uv run ./manage.py shell < <this file>
# (cwd must be the TutorCruncher repo root). Reads ROLE / ROLE_ID / LOGIN_PASSWORD /
# LOCAL_BASE_URL from the environment. Overwrites the role's user email + password so
# you can log in through the normal form on a local or anon dev DB.
import os
import sys

# --- Safety: never touch production --------------------------------------------------
if 'DYNO' in os.environ:  # Heroku marker used throughout settings as the prod signal
    sys.exit('REFUSING: this looks like a production (Heroku) environment.')

from django.conf import settings
from django.db import connection

if not settings.DEBUG:
    print('WARNING: settings.DEBUG is False. Continue only if this is a local/anon DB.')

from TutorCruncher.crm.models import Administrator, Agent, Client, Contractor, ServiceRecipient

ROLE_MAP = {
    'client': Client,
    'tutor': Contractor,
    'contractor': Contractor,
    'admin': Administrator,
    'administrator': Administrator,
    'agent': Agent,
    'sr': ServiceRecipient,
    'recipient': ServiceRecipient,
    'servicerecipient': ServiceRecipient,
    'student': ServiceRecipient,
    'pupil': ServiceRecipient,
}

role_word = (os.environ.get('ROLE') or '').strip().lower()
role_id = (os.environ.get('ROLE_ID') or '').strip()
password = os.environ.get('LOGIN_PASSWORD') or 'testing'
base = (os.environ.get('LOCAL_BASE_URL') or 'http://localhost:8000').rstrip('/')

Model = ROLE_MAP.get(role_word)
if Model is None:
    sys.exit(f'Unknown role {role_word!r}. Choose from: client, tutor, admin, agent, sr.')
if not role_id.isdigit():
    sys.exit(f'ROLE_ID must be a numeric id, got {role_id!r}.')

try:
    role = Model.objects.select_related('user', 'user__branch', 'user__branch__agency').get(id=role_id)
except Model.DoesNotExist:
    sys.exit(f'No {Model.__name__} with id={role_id} on this database.')

user = role.user
email = f'{role_id}@tutorcruncher.com'
user.email = email
user.set_password(password)
user.save()

agency = user.branch.agency
slug = agency.url_slug
login_url = f'{base}/{slug}/login/'

print('\n=== login-as ============================================')
print(f'database    : {connection.settings_dict.get("NAME")}')
print(f'role        : {Model.__name__} #{role_id} ({user.get_full_name()})')
print(f'branch      : {user.branch} (id={user.branch_id})')
print(f'agency      : {agency} (slug={slug})')
print(f'email       : {email}')
print(f'password    : {password}')
print(f'login url   : {login_url}')
if Model is Client:
    print(f'client login: {base}/{slug}/login/client/')
print('=========================================================\n')
