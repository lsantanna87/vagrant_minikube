#!/usr/bin/env bash

ENVIRONMENT=$1
AMI_TYPE=$2
DEBUG=$3
VIRTUAL_ENV=$4

if [ "" == "$ENVIRONMENT" ] || [ "" == "$AMI_TYPE" ]; then
    echo ""
    echo ""
    echo ""
    echo "  Usage: build-ami <ENV> <AMI_TYPE>"
    echo ""
    echo "                   <ENV>            development, c001, c002-stg, ..."
    echo "                   <AMI_TYPE>       asg, kafka, gocd_agent, gocd_server, hybrid, jumpbox"
    echo "                   <DEBUG>          (OPTIONAL) debug | false"
    echo "                   <VIRTUAL_ENV>    (OPTIONAL) venv"
    echo ""
    echo ""
    echo ""
    echo ""
    echo "  Examples:"
    echo "            ./build-ami.sh c001 jumpbox"
    echo "            ./build-ami.sh c001 asg"
    echo "            ./build-ami.sh c001 kafka"
    echo ""
    echo "  OPTIONAL:"
    echo "            ./build-ami.sh c001 kafka debug"
    echo "            ./build-ami.sh c001 kafka debug venv"
    echo "            ./build-ami.sh c001 kafka false venv"
    echo ""
    echo ""
    echo "  Note: Before using this script, make sure that you've set the AWS_PROFILE environment variable to an appropriate profile from your credentials file"
    exit
fi

if [ "$ENVIRONMENT" == "local" ]; then
  ansible-playbook -i inventories/$ENVIRONMENT -e env_name=$ENVIRONMENT local_$AMI_TYPE.yml
  exit
fi

if [ "$VIRTUAL_ENV" == "venv" ];
then
  virtualenv ~/virtualenvironment/new-hope
  source ~/virtualenvironment/new-hope/bin/activate
  pip install -r requirements.txt
fi

if [ "$DEBUG" == "debug" ];
then
  export ANSIBLE_DEBUG=True
  export ANSIBLE_LOG_PATH=~/ansible.log
  ansible-playbook -e env_name=$ENVIRONMENT --vault-password-file=~/.ssh/vault.txt generate_$2_ami.yml -vvvv
else
  ansible-playbook -e env_name=$ENVIRONMENT --vault-password-file=~/.ssh/vault.txt generate_$2_ami.yml
fi
