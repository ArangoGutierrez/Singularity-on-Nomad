job "version" {
  datacenters = ["highwind"]

  type = "batch"

  group "version" {
    task "v" {
      driver = "exec"

      config {
        command = "/usr/local/bin/singularity"
        args    = ["--version"]
      }
    }
  }
}
