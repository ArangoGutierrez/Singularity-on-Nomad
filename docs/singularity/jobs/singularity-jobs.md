# Running Nomad Jobs

With the Nomad servers and agents fully bootstrapped you now have the ability to submit and run [Nomad Jobs](https://www.nomadproject.io/docs/operating-a-job/index.html).

## Run the Example Jobs

Example Jobs under the jobs directory:

* `version` - Run a exec driver calling Singularity --version.

### Run the version Job

The `version` Job Check the Singularity version on host.

Execute a plan for the `version` Job:

```
nomad plan jobs/version.nomad
```

```
+ Job: "version"
+ Task Group: "example" (1 create)
  + Task: "version" (forces create)

Scheduler dry-run:
- All tasks successfully allocated.

Job Modify Index: 0
To submit the job with version verification run:

nomad run -check-index 0 jobs/version.nomad

When running the job with the check-index flag, the job will only be run if the
server side version matches the job modify index returned. If the index has
changed, another user has modified the job and the plan's results are
potentially invalid.
```

Submit and run the `version` Job:

```
nomad run jobs/version.nomad
```

```
==> Monitoring evaluation "XXXXXXXX"
    Evaluation triggered by job "version"
    Allocation "XXXXXXXX" created: node "XXXXXXXX", group "version"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "XXXXXXXX" finished with status "complete"
```

Check the status of the `version` Job:

```
nomad status version
```

```
ID            = version
Name          = version
Submit Date   = XX/XX/XX XX:XX:XX PDT
Type          = batch
Priority      = 50
Datacenters   = highwind
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
example     0       0         1        0       0         0

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created At
XXXXXXXX  XXXXXXXX  example     0        run      running  XX/XX/XX XX:XX:XX PDT
```

Retrieve and view the logs for the `version` Job:

```
nomad logs -job version
```

```
2.3.9-development.ge92fc6a8
```

> The nomad logs command requires remote access to the Nomad worker node running the Job. This works because of the consul cluster deployed before the nomad cluster

The `version` Job is set to run as batch.(Run until success or error exit)

Stop and purge the `version` Job:

```
nomad stop -purge version
```

```
==> Monitoring evaluation "XXXXXXXX"
    Evaluation triggered by job "version"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "XXXXXXXX" finished with status "complete"
```
<!--
EOF!
-->
