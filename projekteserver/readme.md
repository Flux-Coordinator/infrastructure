# Installation
Jira installation with TLS and automated backup service.

## Jira & Nginx reverse proxy
### Prerequisites
Install Docker:

- Docker CE manual <https://docs.docker.com/install/linux/docker-ce/ubuntu/>
- Docker compose manual: <https://docs.docker.com/compose/install/#install-compose>

### Install location
- Docker-compose is started by the service `jira-nginx-docker/systemd/nginx-jira.service`.
- Copy the container `nginx` and the `docker-compose.yml` to `/opt/nginx-jira/` or change the paths inside the service.

### Systemd Services
```bash
cp jira-nginx-docker/systemd/* /lib/systemd/system/
systemctl enable nginx-jira.service
systemctl enable dehydrated.timer
systemctl start dehydrated.timer
systemctl start nginx-jira
```

### First startup
- After the first startup the certificates are loaded and stored in `/etc/dehydrated/certs/`.
- Adjust the Jira config `/var/docker-data/jira-app/conf/server.xml` by adding the last three lines:

```xml
<Connector port="8888"
   maxThreads="150"
   minSpareThreads="25"
   connectionTimeout="20000"

   enableLookups="false"
   maxHttpHeaderSize="8192"
   protocol="HTTP/1.1"
   useBodyEncodingForURI="true"
   redirectPort="8443"
   acceptCount="100"
   disableUploadTimeout="true"
   bindOnInit="false"

   scheme="https"
   proxyName="jira.flux-coordinator.com"
   proxyPort="443"
/>
```
- Then restart the containers:

```bash
systemctl stop nginx-jira
systemctl start nginx-jira
```
## Backup service
### Setup
- create an S3 bucket on Amazon AWS
- install pip `apt-get install python-pip`
- install AWS CLI: `pip install awscli`
- create config-file `~/.aws/credentials` containing the AWS credentials:
```
[default]
aws_access_key_id=foo
aws_secret_access_key=bar
```
- show all buckets: `aws s3api list-buckets`
- copy backup scripts to `/opt/backups`:
`cp /backup/backup-scripts/* /opt/backups/`
- [Jira backup/restore info](https://hub.docker.com/r/ivantichy/jira/)

### Systemd services
```bash
cp backup/systemd/* /lib/systemd/system/
systemctl enable jira-backup.timer
systemctl start jira-backup.timer
```