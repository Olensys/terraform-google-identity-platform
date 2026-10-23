output "id" {
  description = "Identifier of the Identity Platform configuration. Null when create is false."
  value       = try(google_identity_platform_config.this[0].id, null)
}

output "name" {
  description = "Name given to this module instance (var.name); used for outputs only. Null when create is false."
  value       = var.create ? var.name : null
}

output "self_link" {
  description = "Resource name of the Identity Platform configuration (projects/<project>/config). Null when create is false."
  value       = try(google_identity_platform_config.this[0].name, null)
}

output "labels" {
  description = "Labels with context.extra_tags merged in; informational, as the configuration takes no labels. Null when create is false."
  value       = var.create ? local.labels : null
}

output "sign_in_config" {
  description = "Effective sign-in provider switches (email, email_link, anonymous, phone). Null when create is false."
  value       = var.create ? var.sign_in : null
}

output "mfa_state" {
  description = "Configured multi-factor authentication state. Null when create is false."
  value       = var.create ? var.mfa : null
}
