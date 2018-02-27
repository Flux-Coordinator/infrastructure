# Installation
Jira installation with TLS and automated backup service.

## Jira & Nginx
### Setup
install Docker:

- Docker CE manual <https://docs.docker.com/install/linux/docker-ce/ubuntu/>
- Docker compose manual: <https://docs.docker.com/compose/install/#install-compose>

### Run Systemd Services
```bash
cp /jira-nginx-docker/systemd/* /lib/systemd/system/
systemctl enable nginx-jira.service
systemctl enable dehydrated.timer
systemctl start dehydrated.timer
systemctl start nginx-jira
```

## Backup service
### Setup
- create an S3 bucket on Amazon AWS
- install pip
```bash
apt-get install python-pip
```
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
cp /backup/systemd/* /lib/systemd/system/
systemctl enable jira-backup.timer
systemctl start jira-backup.timer
```