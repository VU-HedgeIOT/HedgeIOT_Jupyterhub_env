# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

# Configuration file for JupyterHub
import os
from dockerspawner import DockerSpawner

c = get_config()

# We rely on environment variables to configure JupyterHub so that we
# avoid having to rebuild the JupyterHub container every time we change a
# configuration parameter.

# Spawn containers from this image
c.DockerSpawner.image = os.environ["DOCKER_NOTEBOOK_IMAGE"]

# JupyterHub requires a single-user instance of the Notebook server, so we
# default to using the `start-singleuser.sh` script included in the
# jupyter/docker-stacks *-notebook images as the Docker run command when
# spawning containers.  Optionally, you can override the Docker run command
# using the DOCKER_SPAWN_CMD environment variable.
spawn_cmd = os.environ.get("DOCKER_SPAWN_CMD", "start-singleuser.sh")
c.DockerSpawner.cmd = spawn_cmd

# Connect containers to this Docker network
network_name = os.environ["DOCKER_NETWORK_NAME"]
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.network_name = network_name

# Explicitly set notebook directory because we'll be mounting a volume to it.
# Most jupyter/docker-stacks *-notebook images run the Notebook server as
# user `jovyan`, and set the notebook directory to `/home/jovyan/work`.
# We follow the same convention.
notebook_dir = os.environ.get("DOCKER_NOTEBOOK_DIR") or "/home/jovyan/work"
c.DockerSpawner.notebook_dir = notebook_dir


class MyDockerSpawner(DockerSpawner):
    def start(self):
        # Get the current working directory
        cwd = os.environ.get("JUPYTERHUB_CWD")
        # Construct the absolute path to the desired directory
        data_dir = os.path.join(cwd, "shared_data")
        # Define the volume
        self.volumes[data_dir] = {
            "bind": "/home/jovyan/work/shared_data",
            "mode": "ro",
        }
        self.volumes['jupyterhub-user-{username}'] = {'bind': '/home/jovyan/work', 'mode': 'rw'}
        return super().start()
# Increase time to spawn
c.Spawner.http_timeout = int(60)
# Spawn single-user servers as Docker containers
c.JupyterHub.spawner_class = MyDockerSpawner
# Remove containers once they are stopped
c.DockerSpawner.remove = False

# For debugging arguments passed to spawned containers
c.DockerSpawner.debug = True

# Set pull policy to only pull if image is not present locally
c.DockerSpawner.pull_policy = "ifnotpresent"

# User containers will access hub by container name on the Docker network
c.JupyterHub.hub_ip = "jh"
c.JupyterHub.hub_port = 8080
# c.DockerSpawner.host_ip = "0.0.0.0"
c.JupyterHub.bind_url = "http://0.0.0.0:8000/jh"
c.JupyterHub.base_url = "/jh"

# Persist hub data on volume mounted inside container
c.JupyterHub.cookie_secret_file = "/data/jupyterhub_cookie_secret"
c.JupyterHub.db_url = "sqlite:////data/jupyterhub.sqlite"

# Authenticate users with Native Authenticator
c.JupyterHub.authenticator_class = "nativeauthenticator.NativeAuthenticator"

# Allow anyone to sign-up without approval
c.NativeAuthenticator.open_signup = True

c.Authenticator.allow_all = True
c.Authenticator.admin_users = ["admin"]


