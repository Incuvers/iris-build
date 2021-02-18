FROM snapcraft/ubuntu-base

LABEL Christian Sargusingh "https://github.com/cSDes1gn"

ENV DEBIAN_FRONTEND=noninteractive

# Set the work directory and create the folder to copy source code into
WORKDIR /srv

# Generate locale.
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8
# install required pip and apt dependancies
COPY apt-pkgs.txt /srv/apt-pkgs.txt
RUN xargs -a apt-pkgs.txt sudo apt install -y --no-install-recommends
COPY requirements.txt /srv/requirements.txt
RUN python3 -m pip install -r requirements.txt

# install snapcraft and core images for arm64
RUN snap install snapcraft --classic
RUN snap install core18 --classic
RUN snap install core20 --classic

# https://vsupalov.com/build-docker-image-clone-private-repo-ssh-key/
# add ssh key to github repository credentials on build
ARG SSH_PRIVATE_KEY
RUN mkdir /root/.ssh/
RUN echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa
RUN chmod 0700 /root/.ssh/id_rsa
# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
RUN ssh -T git@github.com || true

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
COPY .env /srv/.env
COPY build.sh /srv/build.sh
COPY s3_push.py /srv/s3_push.py
COPY snap/ /srv/snap/
COPY secrets/ /srv/secrets/

# ENTRYPOINT [ "/build.sh" ]
