# hfw_ansible

Ansible playbook to prepare a server that can run apps based on the hfw library.

## Create a local environment to test the deployment

- [VirtualBox](./local/virtual_box/README.md)

## Prepare a server for deployment

Under the `ansible/server` there is the playbook to prepare the server with
some basic software:

- **nginx server**: to forward each domain for each deployed app and server
    the static files for those apps
- **postgresql**: to be shared across different apps running in the
    server
- **redis**: to have some cache and other functionality available for
    the apps
- **docker**: in order to run the apps in a dockerized way

```
eval `ssh-agent`
ssh-add hfw_local_server
cd ansible/server
source ./depl.sh [hosts_file] [extra_vars_file]
```

## Docker repository

### S3

Create a new user and provide attach a policy that gives it
access to the created bucket

Security policy for the created account

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": "arn:aws:s3:::S3_BUCKET_NAME"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::S3_BUCKET_NAME/*"
    }
  ]
}
```

## Deploy an app

An app consists of:
- docker image
- static assets

The docker image could serve the static files too, to simplify
the deployment, but we can leverage the existing nginx server
to deploy those files.


# How the server gets configured

## Nginx

A single instance is running for all the apps, and for each app an
entry into the `/etc/nginx/conf.d` directory is created.

For the access logs (the general nginx one and the per app access log)
a new formatter is set, to log the output in json format, so it can
be queried with the [`jq`](https://stedolan.github.io/jq/) tool, and
it can also be easily feed into grafana loki or some other service.

## Postgresql

A single instance is configured.

In order to bind postgres to the docker network interface, the systemd
unit is changed to wait for the docker unit to be started (instead of
waiting for the network unit).

## Redis

A single shared instance is configured.

In order to bind postgres to the docker network interface, the systemd
unit is changed to wait for the docker unit to be started (instead of
waiting for the network unit).

## App logs

A directory is created in `/var/log/apps/{{app_name}}`, ownerd by
the unprivileged user, so it can be mounted into the running container,
to write logs. This way, the `stdout` can be redirected to a file,
or additional log files can be written there (so, there is no
need to `docker exec -ti {{container}} /bin/sh` to look at them,
or check the docker stdout with `docker logs {{container}}`. And
those files can also be scrapped by a log reporting agent.
