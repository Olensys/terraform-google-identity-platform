# Changelog

## [1.1.2](https://github.com/Olensys/terraform-google-identity-platform/compare/v1.1.1...v1.1.2) (2026-10-24)


### Bug Fixes

* **examples:** unique application slug so concurrent integration runs do not collide ([#2](https://github.com/Olensys/terraform-google-identity-platform/issues/2)) ([0096d71](https://github.com/Olensys/terraform-google-identity-platform/commit/0096d71de07d3ff8e72e66deadb87998d7baa149))

## [1.1.1](https://github.com/Olensys/terraform-google-identity-platform/compare/v1.1.0...v1.1.1) (2026-10-24)


### Bug Fixes

* **examples:** pin naming module to v1.0.1 ([7a8bb08](https://github.com/Olensys/terraform-google-identity-platform/commit/7a8bb0883c00ba3ec29ae1cf81413c92be52f67b))
* run integration on change and weekly instead of nightly ([92269be](https://github.com/Olensys/terraform-google-identity-platform/commit/92269bec7e881db70dee4a1ee636c4eb363e3e70))

## 1.1.0

### Fixes

- normalise `context.extra_tags` keys and values to valid GCP label syntax (lowercase, invalid characters to `-`, 63 characters); `labels` still win

### Tests

- `test_tags_contract` covers a mixed-case tag key and a value with a space

### Docs

- README usage shows the naming module

### Behaviour changes

- `context.extra_tags` entries now appear as normalised labels (for example `Team = "Core Team"` becomes `team = "core-team"`). Callers that relied on unnormalised keys must read the normalised ones; values that previously failed GCP label validation now succeed.

## 1.0.0

- Identity Platform project configuration: Identity Toolkit API enablement, sign-in providers (email, email link, anonymous, phone), authorized domains, MFA state and blocking functions.
