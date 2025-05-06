# isle-buildkit Release Process

## Monthly Release process steps

* On the second week of every month the ISLE release manager will organize:
  * A new release [discussions thread](https://github.com/Islandora-Devops/isle-buildkit/discussions) for communication between all ISLE maintainers and the community
    * The title will typically be something like `Release 1.0.0` etc with a message like `Determining what is to be included before we make 1.0.0 release.`
      * [Example](https://github.com/Islandora-Devops/isle-buildkit/discussions/193)
    * The Release manager will follow up with all maintainers for assignments.
  * A new release [project](https://github.com/Islandora-Devops/isle-buildkit/projects) for determining what work is to be done
    * The title will typically be something like `March / April 2022 - isle-buildkit 1.0.0 release`
      * [Example](https://github.com/Islandora-Devops/isle-buildkit/projects/2)
    * A list of outstanding PRs will be compiled and assigned

---

## PR & testing process

* When ISLE maintainers make a change via a git pull request (PR)
  * ISLE maintainer should then assign a testing resource (_either another ISLE maintainer, community member or ISLE Release Manager_)
  * PR creates new Docker images tag (TAG) using git commit hash
  * Assigned testing resource can test this by
    * `git clone git@github.com:Islandora-Devops/isle-dc.git`  to local laptop
    * `cd isle-dc`
    * `cp sample.env .env`
    * `vi / nano .env`
      * Change `TAG` to appropriate git commit hash
    * Run `make demo`
    * QC site and report back on Github issue if pass / fail

* Recommend the following for filing tickets / issues. Example below

### Example for isle-buildkit testing

```bash
Reporting results from testing process:

#### Test Environment

* OS: Ubuntu 20.04 LTS Desktop
* CPU: Intel i7-10510U (8 cores) @ 4.900 GHZ
* Mem: 32 GB

---

#### Test process / steps

When testing isle-buildkit
* `git clone git@github.com:Islandora-Devops/isle-buildkit.git` to local laptop
* `./gradlew build`

#### Results

Describe output, expectation and steps.

Include screenshots etc.
```

### Example for isle-dc testing

```bash
Reporting results from testing process:

#### Test Environment

* OS: Ubuntu 20.04 LTS Desktop
* CPU: Intel i7-10510U (8 cores) @ 4.900 GHZ
* Mem: 32 GB

---

    * `git clone git@github.com:Islandora-Devops/isle-dc.git`  to local laptop
    * `cd isle-dc`
    * `cp sample.env .env`
    * `vi / nano .env`
    * Change TAG to appropriate git commit hash
    * `make demo`
---

#### Results

Describe output, expectation and steps.

Include screenshots etc.
```
