#!/bin/bash
set -exo

DATE=$(date +"%Y_%m_%d-%H-%M-%S")
TMP_DEST="/tmp/backups/$DATE"
DESTINATION=/opt/backups
DESTFILENAME="jira-backup-$DATE.tar.gz"
DESTFILE="$DESTINATION/$DESTFILENAME"

DBDATA=/var/docker-data/jira-home/export
JIRADATA=/var/docker-data/jira-home/data

S3BUCKET=jira-flux-backup

mkdir -p ${DESTINATION}
mkdir -p ${TMP_DEST}

# backup db
rsync -av $DBDATA $TMP_DEST

# backup data
rsync -av $JIRADATA $TMP_DEST

# tar and move to backups
tar cvzf $DESTFILE -C $TMP_DEST .

# upload to S3
aws s3api put-object --bucket $S3BUCKET --key $DESTFILENAME --body $DESTFILE

# clean up
rm -rf $TMP_DEST
