#!/bin/bash

AWS_REGION=eu-west-1
test=$1
shift
stack=test$(date +"%Y%m%dT%H%M%S")
echo $stack
ansible-playbook -i $test play.yml -c local -e stack_name=$stack \
 -e account_id=$(aws sts get-caller-identity | jq -r '.Account') \
 -e region=$AWS_REGION\
 -e env=test \
 -e envFull=test \
 -e domain=test.com \
 -e subnet_name=APP \
 -t instances \
 $@


IP=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --filters "Name=tag:aws:cloudformation:stack-name,Values=$stack" --region $AWS_REGION | jq -r '.Reservations[].Instances[0].PublicIpAddress')
sleep 120 # wait for cloud-init to finish
inspec exec $test/test.rb -t ssh://ec2-user@$IP
aws cloudformation delete-stack --stack-name $stack --region $AWS_REGION
