# Run only by the nightly integration workflow, against real cloud credentials.
# Requires a project where Identity Platform is not yet configured (or already imported).
run "apply_minimal" {
  command = apply

  module {
    source = "./examples/minimal"
  }
}
