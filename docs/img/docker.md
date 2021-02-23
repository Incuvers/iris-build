# Notes on Docker and Snapd

Modified: 2021-02

The goal was to build a docker image for building core20 snaps on arm64 to be deployed on a rasberry pi to connect to this repositories github action. Unfortunately docker and snapcraft have some compatibility issues at the time of writing that restrict the scope of our snap build environment.

Docker does not support `snapd` and consequently snapcraft running inside the container instance therefore installing snaps inside the container is not supported. Inherently snapcraft and docker do not play well together due to the confinement requirements of snapcraft. To circumvent this we curl the snap files for `snapcraft`, `core18` and `core20` directly through snapcrafts api. This works for building snaps on `amd64` architectures only due to the fact that all the snaps available through snapcrafts api are built for `amd64`. However deploying the container on `arm64` rpi systems fail.

In the meantime we will have to wait until snapcraft's api has endpoints for `arm64` snaps, or until docker can support running `snapd` inside the container and install snaps directly.