mock_provider "google" {}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name       = "example"
  project_id = "example-project"
}

run "test_email_sign_in_default" {
  command = plan

  assert {
    condition     = google_identity_platform_config.this[0].sign_in[0].email[0].enabled == true
    error_message = "Email sign-in must be enabled by default."
  }

  assert {
    condition     = google_identity_platform_config.this[0].sign_in[0].email[0].password_required == true
    error_message = "Email/password sign-in must require a password when email_link is off."
  }

  assert {
    condition     = google_identity_platform_config.this[0].sign_in[0].allow_duplicate_emails == false
    error_message = "Duplicate emails must be disallowed."
  }

  assert {
    condition     = google_project_service.identitytoolkit[0].service == "identitytoolkit.googleapis.com" && google_project_service.identitytoolkit[0].disable_on_destroy == false
    error_message = "The Identity Toolkit API must be enabled and kept on destroy."
  }

  assert {
    condition     = output.name == "example" && output.sign_in_config.email == true
    error_message = "Outputs must expose the name and the effective sign-in config."
  }
}

run "test_email_link_disables_password" {
  command = plan

  variables {
    sign_in = { email_link = true }
  }

  assert {
    condition     = google_identity_platform_config.this[0].sign_in[0].email[0].password_required == false
    error_message = "Email link sign-in must not require a password."
  }
}

run "test_anonymous_off_default" {
  command = plan

  assert {
    condition     = google_identity_platform_config.this[0].sign_in[0].anonymous[0].enabled == false && google_identity_platform_config.this[0].sign_in[0].phone_number[0].enabled == false
    error_message = "Anonymous and phone sign-in must be off by default."
  }

  assert {
    condition     = google_identity_platform_config.this[0].autodelete_anonymous_users == true
    error_message = "Anonymous users must be auto-deleted."
  }
}

run "test_mfa_off_maps_to_disabled" {
  command = plan

  assert {
    condition     = google_identity_platform_config.this[0].mfa[0].state == "DISABLED" && output.mfa_state == "OFF"
    error_message = "mfa OFF must map to the provider state DISABLED."
  }
}

run "test_mfa_validation" {
  command = plan

  variables {
    mfa = "SOMETIMES"
  }

  expect_failures = [var.mfa]
}

run "test_mfa_enabled_uses_sms" {
  command = plan

  variables {
    mfa = "ENABLED"
  }

  assert {
    condition     = google_identity_platform_config.this[0].mfa[0].state == "ENABLED" && contains(google_identity_platform_config.this[0].mfa[0].enabled_providers, "PHONE_SMS")
    error_message = "MFA must use PHONE_SMS when not OFF."
  }

  assert {
    condition     = output.mfa_state == "ENABLED"
    error_message = "mfa_state output must reflect the input."
  }
}

run "test_authorized_domains_include_defaults" {
  command = plan

  variables {
    authorized_domains = ["app.example.com"]
  }

  assert {
    condition     = contains(google_identity_platform_config.this[0].authorized_domains, "localhost") && contains(google_identity_platform_config.this[0].authorized_domains, "example-project.firebaseapp.com") && contains(google_identity_platform_config.this[0].authorized_domains, "example-project.web.app") && contains(google_identity_platform_config.this[0].authorized_domains, "app.example.com")
    error_message = "Authorized domains must include the project defaults and the input."
  }
}

run "test_authorized_domains_validation" {
  command = plan

  variables {
    authorized_domains = ["https://bad_host/"]
  }

  expect_failures = [var.authorized_domains]
}

run "test_blocking_functions" {
  command = plan

  variables {
    blocking_functions = { beforeSignIn = "https://europe-west1-example-project.cloudfunctions.net/check" }
  }

  assert {
    condition     = length(google_identity_platform_config.this[0].blocking_functions) == 1
    error_message = "A blocking_functions block must be rendered when triggers are set."
  }
}

run "test_blocking_function_key_validation" {
  command = plan

  variables {
    blocking_functions = { afterSignIn = "https://example.com/fn" }
  }

  expect_failures = [var.blocking_functions]
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.id == null && output.name == null && output.self_link == null && output.labels == null && output.sign_in_config == null && output.mfa_state == null
    error_message = "All outputs must be null when create is false."
  }

  assert {
    condition     = length(google_identity_platform_config.this) == 0 && length(google_project_service.identitytoolkit) == 0
    error_message = "No resources when create is false."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmn"
  }

  expect_failures = [var.name]
}

run "test_tags_contract" {
  command = plan

  variables {
    labels = { owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { Owner = "y", Team = "Core Team" }
    }
  }

  assert {
    condition     = output.labels.owner == "x"
    error_message = "var.labels must win over extra_tags."
  }

  assert {
    condition     = output.labels.team == "core-team"
    error_message = "extra_tags must be merged."
  }
}
