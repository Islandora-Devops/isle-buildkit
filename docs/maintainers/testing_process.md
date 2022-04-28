#### isle-buildkit testing

When testing isle-buildkit image releases or possible changes, a tester can:

* clone down the latest `isle-dc` to their local laptop / workstation
  * `git clone https://github.com/Islandora-Devops/isle-dc.git`

* Look up the last commit hash in the PR on the isle-buildkit Github.com PR page. 
  * In this example - we'll be using this PR [Allow containers to run without allocating a tty.](https://github.com/Islandora-Devops/isle-buildkit/commits/issue-174) and the value `79de15828971c10894c3cdf14eec431434c457ea` which is both the commit hash and the resulting [Docker image](https://hub.docker.com/u/islandora) / tag needed for testing.
  * In the image below one would click the overlapping squares icon to copy the full SHA of the commit.

**Example**

![Screenshot from 2022-04-28 15-00-42](https://user-images.githubusercontent.com/501554/165828803-088d6fe6-e9cf-4238-8cfe-d697fac64ef4.png)

Within the newly cloned `isle-dc` project
* Copy the `sample.env` to `.env` as you'll need to edit the TAG value for testing
  * `cp sample.env .env`
* Change **Line 65** within the new `.env` file to the test commit hash from above
  * `nano / vi .env`
  * e.g. `TAG=79de15828971c10894c3cdf14eec431434c457ea`

* Follow the instructions from the isle-dc [Getting Started](https://github.com/Islandora-Devops/isle-dc#getting-started) section and run the following
  * `make demo`

* QC the resulting site at [https://islandora.traefik.me](https://islandora.traefik.me)
  * Ensure that there aren't new errors in the Status page
  * If additional testing parameters are called out in the ticket, review and test.

* If everything passes or doesn't, update the PR / issue with the following style of response.

```bash
#### Test Environment

* OS: Ubuntu 20.04 LTS Desktop
* CPU: Intel i7-10510U (8 cores) @ 4.900 GHZ
* RAM: 32 GB

---

#### Steps taken to test

 * `git clone git@github.com:Islandora-Devops/isle-dc.git`  to local laptop
 * `cd isle-dc`
 * `cp sample.env .env`
 * `vi / nano .env`
    * Changed `TAG=` to `TAG=79de15828971c10894c3cdf14eec431434c457ea`
 * `make demo`
---

#### Results

Status = Working
@nigelgbanks @g7morris Process worked great. No errors to report.
```
