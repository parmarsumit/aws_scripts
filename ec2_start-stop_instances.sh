#!/bin/bash
#

# This script start and stop instances using tags and  crontab
export AWS_SECRET_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
export AWS_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
[ -z "$EC2_HOME" ] && export EC2_HOME="/opt/aws/apitools/ec2"
[ -z "$JAVA_HOME" ] && export JAVA_HOME="/usr/lib/jvm/jre"

ec2_describe_instances="/opt/aws/bin/ec2-describe-instances"
ec2_stop_instances="/opt/aws/bin/ec2-stop-instances"
ec2_start_instances="/opt/aws/bin/ec2-start-instances"

# Set your tag value or name indetify instances stop start
TAG_AUTO_START="AUTO-START"

REGION="sa-east-1"

DATE=`date +"%m-%d-%y"`


function ec2_action() {
    local action_command=$1
    if [ -z "$action_command" ]; then
        echo "Error get variable  (action_command)"
        exit 2	
    fi

    for IDS in  $TAG_AUTO_START;
    do 
        found_instance_ids=$(
            $ec2_describe_instances  --region "$REGION" |
                   grep -i $TAG_AUTO_START|awk '{
       for (f = 1; f <= NF; f++) { a[NR, f] = $f } 
     }
     NF > nf { nf = NF }
     END {
       for (f = 1; f <= nf; f++) {
           for (r = 1; r <= NR; r++) {
               printf a[r, f] (r==NR ? RS : FS)
           }
       }
    }'|grep "i-")
        $action_command \
            --region $REGION $found_instance_ids \
        -O $AWS_ACCESS_KEY -W $AWS_SECRET_KEY
        done

}

case $1 in
    stop)  ### stop actions
           echo -e "\n\n\n\n"
           echo "###########################"
           echo " STOPING instances - $(date)"
           echo "###########################"
           echo -e "\n\n"
           set -x
           ec2_action "$ec2_stop_instances"
           set +x
    ;;
    start) ### start actions
           echo -e "\n\n\n\n"
           echo "###########################"
           echo " STARTING instances - $(date)"
           echo "###########################"
           echo -e "\n\n"
           set -x
           ec2_action "$ec2_start_instances"
           set +x
    ;;
    *)     ### usage
           echo "Usage: $0 <start|stop>"
           exit 2
esac
