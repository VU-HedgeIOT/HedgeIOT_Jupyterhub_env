# Jupyterhub XAI/Linked Data Development Environment [WORK IN PROGRESS!]

## Installation

Make sure you have Docker and Docker Compose installed.

```bash
git clone https://github.com/matercomus/BScP_jupyterhub_env
cd BScP_jupyterhub_env
export PWD=$(pwd)
DOCKER_BUILDKIT=0 docker compose build jh
docker compose up -d
```

## Usage
1. In your browser go to https://hedge-iot.labs.vu.nl/jh
1. Click Sign-Up, create a new user...
1. Log in

## /work directory

In the file tree, you will see /work directory.
This directory is private for your user and is persistent meaning you can save your work and come back later

Inside /work there is also /shared_data. This read-only folder is accessible to all users and is used to share files with all users.
You can copy these files into your /work directory to save and edit.

While in /shared_data, you may also clone [BScP_NBs](https://github.com/matercomus/BScP_NBs) which is a set of notebooks that demonstrates how to use jupyter notebooks and the Knowledge Engine to create solutions for Heterogeneous IoT data and IoT interoperability.

## TODO

1. Secure graphDB
1. Add github cli to user containers.
1. Fix KE connection to the HedgeIOT KD.
