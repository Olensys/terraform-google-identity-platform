# Run only by the integration workflow, against real cloud credentials.
#
# Plan only. Identity Platform is a project singleton that cannot be disabled once
# enabled: the first apply in a project succeeds, destroy removes the configuration
# from state only, and every later apply fails with
# "INVALID_PROJECT_ID : Identity Platform has already been enabled for this project".
# Adopting the existing configuration from here is not possible either: an import
# block in examples/minimal is rejected because `terraform test` loads the example as
# a child module ("Import blocks are only allowed in the root module"), and the module
# itself must stay import-free so callers can use it as a child module. The real
# apply is verified manually once per project; see "Testing" in README.md.
run "plan_minimal" {
  command = plan

  module {
    source = "./examples/minimal"
  }
}
