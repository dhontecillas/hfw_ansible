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
