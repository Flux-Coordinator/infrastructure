#!/bin/bash
set -exo

DATE=$(date +"%Y_%m_%d-%H-%M-%S")
TMP_DEST="/tmp/backups/$DATE"
DESTINATION=/opt/backups
DESTFILENAME="jira-backup-full-$DATE.tar.gz"
DESTFILE="$DESTINATION/$DESTFILENAME"

DBFILES=/var/docker-data/postgres
JIRAAPP=/var/docker-data/jira-app
JIRAHOME=/var/docker-data/jira-home

S3BUCKET=jira-flux-backup

mkdir -p ${DESTINATION}
mkdir -p ${TMP_DEST}

# backup db and jira data
rsync -av $DBFILES $TMP_DEST
rsync -av $JIRAAPP $TMP_DEST
rsync -av $JIRAHOME $TMP_DEST

# tar and move to backups
tar cvzf $DESTFILE -C $TMP_DEST .

# upload to S3
aws s3api put-object --bucket $S3BUCKET --key $DESTFILENAME --body $DESTFILE

# clean up
rm -rf $TMP_DEST
