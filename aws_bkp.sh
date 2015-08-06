set -x
#!/bin/bash
#
# File: vol-snapshot.sh
TODAY=`date +%m-%d-%Y`
# File: vol-snapshot.sh
echo "================================================"
echo "Starting SNAPSHOT creation and deletion process for $TODAY"
echo ""
echo "The script will create a snapshot of every single volume"
echo "It will delete snapshots older than 3 days"
echo ""
echo "Setting ENVIRONMENTAL VARIABLES FOR ec2"
export JAVA_HOME=/usr/lib/jvm/jre
export AWS_SECRET_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export AWS_ACCESS_KEY= "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export EC2_HOME='/opt/aws/apitools/ec2'  # Make sure you use the API tools, not the     AMI tools
export EC2_BIN=$EC2_HOME/bin
export REGION=sa-east-1
export PATH=$PATH:$EC2_BIN
# Change days retetion
export OLD=`date +%Y-%m-%d --date '3 days ago'`
# To find the current location of JAVA_HOME, try env | grep JAVA_HOME
# It's necessary to put this environment variable in here because
# cron will not have access to your standard environment variables.

## Get Volumes
VOLUMES=`ec2-describe-instances --region $REGION |grep running|cut -f2|while read line; do ec2-describe-volumes --region $REGION|grep $line|cut -f 2;done`
echo "The volumes are: $VOLUMES"
echo ""

echo "===================================="
echo "Creating snapshots of volumes: $VOLUMES"
echo ""
for volume in $VOLUMES
do 
  ec2-create-snapshot --region $REGION  -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY -d "Creating     Snapshots for $TODAY" $volume
  MACHINE=`ec2-describe-instances --filter "block-device-mapping.volume-id=$volume" --region $REGION | grep Name| cut -f5`
  echo "BACKUP SUCCESS: Amazon EC2 | $MACHINE" >> /var/log/aws_bkp.log 
done

echo ""
echo "====================================="
echo "Deleting snapshots for $VOLUMES"
echo ""
for volume in $VOLUMES
do
OLDEST=`ec2-describe-snapshots --region $REGION -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY | grep $volume | grep $OLD | sed -e 's/.*snap/snap/' | sed -e 's/\t.*//'`
    if [ "$OLDEST" != "x" ]; then
      ec2-delete-snapshot --region $REGION -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY $OLDEST
      echo "SNAPSHOTS (3 DAYS AGO) DELETEDS: Amazon EC2"  >> /var/log/aws_bkp.log
    else
      echo "No other snapshots to delete using this script."
    fi
done
echo "The end of script."


date >> /var/log/aws_bkp.log
echo "#####################FINISHED DAY BACKUPS ##########################################" >> /var/log/aws_bkp.log
