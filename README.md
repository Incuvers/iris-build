# Iris Build Action
[![shellcheck](https://github.com/Incuvers/iris-build-action/actions/workflows/shellcheck.yaml/badge.svg?branch=master)](https://github.com/Incuvers/iris-build-action/actions/workflows/shellcheck.yaml) [![yamllint](https://github.com/Incuvers/iris-build-action/actions/workflows/yamllint.yaml/badge.svg?branch=master)](https://github.com/Incuvers/iris-build-action/actions/workflows/yamllint.yaml)

![img](/docs/img/Incuvers-black.png)

Modified: 2021-03

## Action Runner Brief
The code in this repository is executed as defined by the [action.yaml](action.yaml) file in the root of this repository. This action can be invoked in another repositories build-spec by pointing to this action (see [Action Usage](#action-usage). This action is not deployed to a server directly and instead is pulled by the github action runner when the build-spec requires this action. This way subsequent updates to this build action on the target branch will be automatically be pulled by the build server so it is always running the latest source code.

## Iris Build Deployment
To deploy the iris build server visit the Incuvers:automation follow the setup instructions and launch the iris build server deployment playbook:
```bash
make ib-deploy
```

## LXD Container
LXD container github action for building core20 snap applications on the ard64 architecture for use on the Incuvers Realtime Imaging System (IRIS) platform.

## Docker Container
Dockerized github action for building core20 snap applications for the Incuvers Realtime Imaging System (IRIS) platform. This build method is deprecated. See the notes on docker [here](/docs/docker.md).

## Action Usage
```yaml
snap-build:
  name: iris snap
  runs-on: [self-hosted, linux, ARM64]
  steps:
    - name: Start IRIS Build Server
      uses: Incuvers/iris-build-action@master
      env:
        SLACK_IDENTIFIER: ${{ secrets.SLACK_NOTIFICATIONS }}
        ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        ACCESS_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
```
