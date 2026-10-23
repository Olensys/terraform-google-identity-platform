variable "name" {
  description = "Name used for outputs and labels only; Identity Platform configuration is a project singleton and has no name of its own. Lowercase letters, digits and hyphens."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,63}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "project_id" {
  description = "GCP project whose Identity Platform configuration is managed."
  type        = string
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "sign_in" {
  description = "Sign-in providers. email: email/password sign-in; email_link: passwordless email-link sign-in (requires email); anonymous: anonymous sign-in; phone: phone number sign-in."
  type = object({
    email      = optional(bool, true)
    email_link = optional(bool, false)
    anonymous  = optional(bool, false)
    phone      = optional(bool, false)
  })
  default = {}
  validation {
    condition     = var.sign_in.email || !var.sign_in.email_link
    error_message = "sign_in.email_link requires sign_in.email to be true."
  }
}

variable "authorized_domains" {
  description = "Extra domains allowed for OAuth redirects. localhost, <project_id>.firebaseapp.com and <project_id>.web.app are always included."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for d in var.authorized_domains : can(regex("^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\\.)*[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", d))])
    error_message = "Every authorized domain must be a lowercase hostname without scheme, port or path."
  }
}

variable "mfa" {
  description = "Multi-factor authentication state: OFF, ENABLED or MANDATORY. When not OFF, PHONE_SMS is the enabled provider."
  type        = string
  default     = "OFF"
  validation {
    condition     = contains(["OFF", "ENABLED", "MANDATORY"], var.mfa)
    error_message = "mfa must be one of OFF, ENABLED, MANDATORY."
  }
}

variable "blocking_functions" {
  description = "Map of trigger (beforeCreate or beforeSignIn) to the URI of the Cloud Function that handles it. Credentials are not forwarded to the function."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.blocking_functions) : contains(["beforeCreate", "beforeSignIn"], k)])
    error_message = "blocking_functions keys must be beforeCreate or beforeSignIn."
  }
}

variable "labels" {
  description = "Labels reported through the labels output. Identity Platform configuration takes no labels, so they are not applied to any resource."
  type        = map(string)
  default     = {}
}
