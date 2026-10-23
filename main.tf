# Identity Platform is a project singleton: exactly one google_identity_platform_config
# exists per project, so `name` only feeds outputs and is not part of any resource name.

locals {
  extra_labels = { for k, v in var.context.extra_tags :
  substr(replace(lower(k), "/[^a-z0-9_-]/", "-"), 0, 63) => substr(replace(lower(v), "/[^a-z0-9_-]/", "-"), 0, 63) }
  labels = merge(local.extra_labels, var.labels)

  authorized_domains = distinct(concat(
    ["localhost", "${var.project_id}.firebaseapp.com", "${var.project_id}.web.app"],
    var.authorized_domains,
  ))
}

resource "google_project_service" "identitytoolkit" {
  count = var.create ? 1 : 0

  project            = var.project_id
  service            = "identitytoolkit.googleapis.com"
  disable_on_destroy = false
}

resource "google_identity_platform_config" "this" {
  count = var.create ? 1 : 0

  project                    = var.project_id
  autodelete_anonymous_users = true
  authorized_domains         = local.authorized_domains

  sign_in {
    allow_duplicate_emails = false

    email {
      enabled           = var.sign_in.email
      password_required = !var.sign_in.email_link
    }

    phone_number {
      enabled = var.sign_in.phone
    }

    anonymous {
      enabled = var.sign_in.anonymous
    }
  }

  mfa {
    state             = var.mfa == "OFF" ? "DISABLED" : var.mfa
    enabled_providers = var.mfa == "OFF" ? null : ["PHONE_SMS"]
  }

  dynamic "blocking_functions" {
    for_each = length(var.blocking_functions) > 0 ? [1] : []

    content {
      dynamic "triggers" {
        for_each = var.blocking_functions

        content {
          event_type   = triggers.key
          function_uri = triggers.value
        }
      }

      forward_inbound_credentials {
        id_token      = false
        access_token  = false
        refresh_token = false
      }
    }
  }

  depends_on = [google_project_service.identitytoolkit]
}
