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
  echo "Checking"
    ssh -o StrictHostKeyChecking=no ec2-user@$1 "ls /var/lib/cloud/instance/boot-finished" 2>&1 > /dev/null
}

KEY=$HOME/.ssh/id_rsa
test -e $KEY
if [[ ! -e "$KEY" ]]; then
  echo "No SSH Key found, generating"
  ssh-keygen -f $KEY -N ""
fi

ssh-add -L
ssh_agent_started="$?"
if [[ ! -v SSH_AUTH_SOCK || "$ssh_agent_started" != "0" ]]; then
  echo "Starting ssh-agent"
  eval $(ssh-agent -s)
fi

ssh-add $KEY
ssh-add -L

start=$(date +%s)
test=$1
shift
stack=test-$(echo $test | tr '_' '-')-$(date +"%Y%m%dT%H%M%S")
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

while ! is_cloudinit_finished $IP && [[ $((now - start)) -lt "120" ]] ; do
  echo .
  sleep 5
  now=$(date +%s)
done
is_cloudinit_finished $IP
connected="$?"
if [[ -e "tests/$test.rb"  && "$connected" == "0" ]]; then
  echo "Executing tests/$test.rb"
  inspec exec tests/$test.rb -t ssh://ec2-user@$IP
  tests="$?"
  if [[ "$tests" != "0" &&  "$-" == "i" ]]; then
      ssh ec2-user@$IP
  fi
fi

if [[ "$connected" != "0" || "$tests" != "0" ]]; then
  exit 1
fi