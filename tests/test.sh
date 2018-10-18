#!/bin/bash

function finish {
  echo "Cleaning up stack"
  aws cloudformation delete-stack --stack-name $stack --region $AWS_REGION
}
trap finish EXIT

AWS_REGION=eu-west-1
test=$1
shift
stack=test$(date +"%Y%m%dT%H%M%S")
echo $stack
cmd="ansible-playbook -i tests/$test play.yml -c local -e stack_name=$stack \
 -e account_id=$(aws sts get-caller-identity | jq -r '.Account') \
 -e region=$AWS_REGION\
 -e target=aws \
 -e env=test \
 -e envFull=test \
 -e domain=test.com \
 -e subnet_name=APP"
echo $cmd
$cmd $@

IP=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --filters "Name=tag:aws:cloudformation:stack-name,Values=$stack" --region $AWS_REGION | jq -r '.Reservations[].Instances[0].PublicIpAddress')
echo "Provisioned $IP, waiting 2m for cloud-init"

while ! ssh -o StrictHostKeyChecking=no ec2-user@$IP "ls /var/lib/cloud/instance/boot-finished" ; do
  echo .
  sleep 5
done

if [[ -e tests/$test.rb ]]; then
  if ! inspec exec tests/$test.rb -t ssh://ec2-user@$IP; then
      ssh ec2-user@$IP
  fi
fi