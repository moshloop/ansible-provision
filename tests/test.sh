#!/bin/bash

AWS_REGION=eu-west-1

function finish {
  echo "Cleaning up stack"
  aws cloudformation delete-stack --stack-name $stack --region $AWS_REGION
}
trap finish EXIT

function get_ip() {
  aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --filters "Name=tag:aws:cloudformation:stack-name,Values=$1" --region $AWS_REGION | jq -r '.Reservations[].Instances[0].PublicIpAddress'
}

function is_cloudinit_finished() {
    ssh -o StrictHostKeyChecking=no ec2-user@$IP "ls /var/lib/cloud/instance/boot-finished" 2>&1 > /dev/null
}

if [[ ! -e ~/.ssh/.id_rsa ]]; then
  echo "No SSH found, generating"
  ssh-keygen -f ~/.ssh/id_rsa -N ""
fi

if [[ "$SSH_AUTH_SOCK" == "" ]]; then
  echo "Starting ssh-agent"
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/.id_rsa
fi

start=$(date +%s)
test=$1
shift
stack=test$(date +"%Y%m%dT%H%M%S")
echo "Cloudformation stack name: $stack"
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

IP=$(get_ip $stack)
echo "Provisioned $IP, waiting for up to 2m"

while is_cloudinit_finished $IP || [[ $((now - start)) -lt "120" ]] ; do
  echo .
  sleep 5
  now=$(date +%s)
done

if [[ -e tests/$test.rb && is_cloudinit_finished $IP ]]; then
  if ! inspec exec tests/$test.rb -t ssh://ec2-user@$IP; then
      ssh ec2-user@$IP
  fi
fi