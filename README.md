# Jupyterhub for Hedge-IOT


## Usage

1. In your browser go to https://jupyterhub.hedge-iot.labs.vu.nl/jh
1. Click Sign-Up, create a new user...
1. Log in

## /work directory

In the file tree, you will see /work directory.
This directory is private for your user and is persistent meaning you can save your work and come back later.

Inside /work there is also /shared_data. This read-only folder is accessible to all users and is used to share files with all users.
You can run them or copy these files into your /work directory to save and edit.

## Git and github

You may clone and work on code from your own repository from within the /work directory.
GitHub cli is installed in the user containers by default. This means you can easily add the ssh keys of your user container with gh auth login command.

## Pip and Conda

Both pip and conda are available for managing python modules and environments.

## Zombie notebooks

You may leave a notebook running between logins to juputerhub. But always save the results to a file since the output of cells might not be captured.


## Installation on host server

Make sure Docker and Docker Compose are installed.

```bash
git clone https://github.com/matercomus/BScP_jupyterhub_env
cd BScP_jupyterhub_env
export PWD=$(pwd)
# Build the custom JupyterLab image first
docker compose --profile build-only build custom-jupyterlab
DOCKER_BUILDKIT=0 docker compose build jh
docker compose up -d
```

### Troubleshooting

If users cannot spawn containers with "ImageNotFound" error for `custom-jupyterlab`:

1. Build the custom image: `docker compose --profile build-only build custom-jupyterlab`
2. Restart JupyterHub: `docker compose restart jh`

The `pull_policy = "ifnotpresent"` configuration prevents unnecessary image pulls when the image exists locally.

While in /shared_data, you may also clone [HegdeIOT_Jupyterhub_NBs](https://github.com/VU-HedgeIOT/HegdeIOT_Jupyterhub_NBs) which is a set of notebooks that demonstrates how to use jupyter notebooks and the Knowledge Engine to create solutions for Heterogeneous IoT data and IoT interoperability.

## Connecting to Knowledge Engine

(We assume a KE instance is running where you setup or know the login credentials)
Create a .env file with the following content:

```bash
HOST_IP=
KE_URL=http://${HOST_IP}/knowledge-engine/rest
KE_USER=
KE_PASS=
```


For any questions please contact r.m.siebes'@'vu.nl
