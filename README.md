# terraform-google-identity-platform

Identity Platform project configuration with sign-in providers, authorized domains, MFA state and blocking functions. It enables the Identity Toolkit API and manages the project's single `google_identity_platform_config`. Pairs with `terraform-aws-cognito-user-pool`.

## Opinions

- Email/password sign-in is on; `email_link = true` switches the email provider to passwordless (no password required). Phone and anonymous sign-in are off.
- Duplicate emails are not allowed.
- Anonymous users are automatically deleted.
- MFA is `OFF` by default (`mfa` accepts `OFF`, `ENABLED`, `MANDATORY`, mirroring the Cognito module); `OFF` maps to the provider state `DISABLED`; when not `OFF`, SMS (`PHONE_SMS`) is the enabled provider.
- Authorized domains always include `localhost`, `<project_id>.firebaseapp.com` and `<project_id>.web.app`, plus `authorized_domains`.
- Blocking functions (`beforeCreate`, `beforeSignIn`) never receive the caller's ID, access or refresh tokens.
- The Identity Toolkit API is enabled and left enabled on destroy.
- Project singleton: Identity Platform allows one configuration per project, so `name` only feeds outputs and `labels` is informational (the configuration takes no labels). Creation fails if Identity Platform was already enabled in the project; import the existing configuration first: `terraform import 'module.<label>.google_identity_platform_config.this[0]' projects/<project_id>/config`.
- `context.extra_tags` keys and values are normalised to valid GCP label syntax (lowercase, `[^a-z0-9_-]` → `-`, 63 chars); `labels` are applied verbatim and win.

## Usage

```hcl
variable "context" {
  default = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
}

module "naming" {
  source  = "git::https://github.com/Olensys/terraform-null-naming.git?ref=v1.0.1"
  context = var.context
}

module "this" {
  source = "git::https://github.com/Olensys/terraform-google-identity-platform.git?ref=v1.1.0"

  name       = module.naming.name
  project_id = "my-project"
  context = var.context

  labels = module.naming.labels
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.0, < 8.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_identity_platform_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/identity_platform_config) | resource |
| [google_project_service.identitytoolkit](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name used for outputs and labels only; Identity Platform configuration is a project singleton and has no name of its own. Lowercase letters, digits and hyphens. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project whose Identity Platform configuration is managed. | `string` | n/a | yes |
| <a name="input_authorized_domains"></a> [authorized\_domains](#input\_authorized\_domains) | Extra domains allowed for OAuth redirects. localhost, <project\_id>.firebaseapp.com and <project\_id>.web.app are always included. | `list(string)` | `[]` | no |
| <a name="input_blocking_functions"></a> [blocking\_functions](#input\_blocking\_functions) | Map of trigger (beforeCreate or beforeSignIn) to the URI of the Cloud Function that handles it. Credentials are not forwarded to the function. | `map(string)` | `{}` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels reported through the labels output. Identity Platform configuration takes no labels, so they are not applied to any resource. | `map(string)` | `{}` | no |
| <a name="input_mfa"></a> [mfa](#input\_mfa) | Multi-factor authentication state: OFF, ENABLED or MANDATORY. When not OFF, PHONE\_SMS is the enabled provider. | `string` | `"OFF"` | no |
| <a name="input_sign_in"></a> [sign\_in](#input\_sign\_in) | Sign-in providers. email: email/password sign-in; email\_link: passwordless email-link sign-in (requires email); anonymous: anonymous sign-in; phone: phone number sign-in. | <pre>object({<br/>    email      = optional(bool, true)<br/>    email_link = optional(bool, false)<br/>    anonymous  = optional(bool, false)<br/>    phone      = optional(bool, false)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | Identifier of the Identity Platform configuration. Null when create is false. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels with context.extra\_tags merged in; informational, as the configuration takes no labels. Null when create is false. |
| <a name="output_mfa_state"></a> [mfa\_state](#output\_mfa\_state) | Configured multi-factor authentication state. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name given to this module instance (var.name); used for outputs only. Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Resource name of the Identity Platform configuration (projects/<project>/config). Null when create is false. |
| <a name="output_sign_in_config"></a> [sign\_in\_config](#output\_sign\_in\_config) | Effective sign-in provider switches (email, email\_link, anonymous, phone). Null when create is false. |
<!-- END_TF_DOCS -->
