
FROM ubuntu:xenial as intermediate

# Grab dependencies
RUN apt update
RUN apt dist-upgrade --yes
RUN apt install --yes \
      curl \
      jq \
      squashfs-tools \
      git

# Grab the core18 snap (for backwards compatibility) from the stable channel and
# unpack it in the proper place.
RUN curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core18' | jq '.download_url' -r) --output core18.snap
RUN mkdir -p /snap/core18
RUN unsquashfs -d /snap/core18/current core18.snap

# Grab the core20 snap (which snapcraft uses as a base) from the stable channel
# and unpack it in the proper place.
RUN curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core20' | jq '.download_url' -r) --output core20.snap
RUN mkdir -p /snap/core20
RUN unsquashfs -d /snap/core20/current core20.snap

# Grab the snapcraft snap from the stable channel and unpack it in the proper
# place.
RUN curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/snapcraft?channel=stable' | jq '.download_url' -r) --output snapcraft.snap
RUN mkdir -p /snap/snapcraft
RUN unsquashfs -d /snap/snapcraft/current snapcraft.snap

# Create a snapcraft runner (TODO: move version detection to the core of
# snapcraft).
RUN mkdir -p /snap/bin
RUN echo "#!/bin/sh" > /snap/bin/snapcraft
RUN snap_version="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)" && echo "export SNAP_VERSION=\"$snap_version\"" >> /snap/bin/snapcraft
RUN echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' >> /snap/bin/snapcraft
RUN chmod +x /snap/bin/snapcraft

# Add ssh key passing to intermediate build step to squash traces
# https://vsupalov.com/build-docker-image-clone-private-repo-ssh-key/
# add ssh key to github repository credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 0700 /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
# this is just a sanity check (remove after snapcraft pull on monitor works)
# RUN git clone git@github.com:Incuvers/monitor.git
# RUN rm -r monitor

# Multi-stage build, only need the snaps from the builder. Copy them one at a
# time so they can be cached.
FROM ubuntu:xenial
COPY --from=intermediate /snap/core18 /snap/core18
COPY --from=intermediate /snap/core20 /snap/core20
COPY --from=intermediate /snap/snapcraft /snap/snapcraft
COPY --from=intermediate /snap/bin/snapcraft /snap/bin/snapcraft

# Set the work directory and create the folder to copy source code into
WORKDIR /app

# Generate locale.
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8

# Set the proper environment.
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/snap/bin:$PATH"
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"
ENV SNAP_ARCH="arm64"
ENV SNAPCRAFT_BUILD_ENVIRONMENT="host"

# copy build source code
COPY .env /app/.env
COPY build.sh /app/build.sh
COPY s3_push.py /app/s3_push.py
COPY snap/ /app/snap/
COPY secrets/ /app/secrets/

# ENTRYPOINT [ "/build.sh" ]
