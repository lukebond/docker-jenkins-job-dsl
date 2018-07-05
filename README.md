# workshop-jenkins

A containerised Jenkins that works out of the box with LTS version, default
plugins, "hello world" Jenkinsfile pipeline and the ability to mount in your
own repository with a Jenkinsfile.

Began life as a fork of [https://github.com/marcelbirkner/docker-jenkins-job-dsl].

## Usage

To launch with the default "hello world" pipeline:

```
$ make run
```

To use your own local Git repository that has a Jenkinsfile in the root:

```
$ HOST_REPO_PATH=/absolute/path/to/repo make run
```

To stop and remove a running container:

```
$ make stop
```

NOTE: any changes you make to Jenkins itself will not be persisted, as the
Jenkins home directory is not mounted to the host (and is therefore not
persisted).

To run the container without even pulling down this repository:

```
$ docker container run -d --restart always \
  --publish 8080:8080 --name workshop-jenkins \
  controlplaneio/workshop-jenkins:latest
```

...to do the same but mount in a host repo, just add
`-v /absolute/path/to/repo:/opt/repo` to the `docker` invocation.

## Building

You should just be able to pull it from the Docker Hub, but if you want to
rebuild it then just run:

```
$ make build
```

## Cleaning

To stop a running container and remove the image:

```
$ make clean
```

Copyright 2018 ControlPlane Limited.
