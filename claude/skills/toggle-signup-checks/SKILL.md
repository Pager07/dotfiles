---
name: toggle-signup-checks
description: Toggle captcha, VPN check, and signup cache check on or off for local agency creation testing. Use when you need to disable or re-enable signup protections.
disable-model-invocation: true
user-invocable: true
allowed-tools: Read, Edit, Grep
argument-hint: [enable|disable]
---

# Toggle Signup Checks

This skill comments out or uncomments the captcha, VPN IP check, and signup status cache check in the agency creation flow. This is useful for local testing where these checks get in the way.

## Arguments

- `$ARGUMENTS` should be either `enable` or `disable`
  - `disable` - comments out the checks (for local dev/testing)
  - `enable` - uncomments the checks (restores production behavior)

## Files to modify

1. **`TutorCruncher/tcsales/forms.py`** in `CreateAgencyForm`:
   - The `ga4_client_id` field declaration line: `ga4_client_id = forms.CharField(widget=forms.HiddenInput(), required=False)`
   - The `captcha` field declaration line: `captcha = hCaptchaField()`
   - The `'captcha'` entry in `Meta.fields` list

2. **`TutorCruncher/tcsales/views/agency_creation.py`** in `CreateAgencyView.form_valid`:
   - The VPN IP check block (the `if _vpn_ip_check(...)` block including the `messages.error(...)` and `return self.form_invalid(form)`)
   - The signup status cache check line (`if signup_status := cache.get(...)` and its `return`)
   - The `form_data.pop('captcha')` line

## How to toggle

### When disabling (commenting out):
- Add `# ` prefix to each line being disabled
- Make sure indentation is preserved after the `# `

### When enabling (uncommenting):
- Remove `# ` prefix from each disabled line
- Make sure indentation is correct after removal

## Important
- Always read both files first before making edits
- Do NOT modify any other code
- Do NOT commit these changes - they are local dev-only
- After toggling, tell the user which state the checks are now in
