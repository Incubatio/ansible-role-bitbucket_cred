#!/bin/bash

function help {
  echo ""
  echo "/!\ Missing Param"
  echo ""
  echo "Usage:"
  echo "  ./deploy_key.sh -u=<user> -a=<account> -p=<project> list"
  echo "  ./deploy_key.sh -u=<user> -a=<account> -p=<project> add <ssh_key_path> (ex: /path/to/ssh_key)"
  echo "  ./deploy_key.sh -u=<user> -a=<account> -p=<project> del <pk> (ex: 12345, you can get pk from list)"
  exit
}

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    shift
    ;;
    -a=*|--account=*)
    ACCOUNT="${i#*=}"
    shift
    ;;
    -p=*|--project=*)
    PROJECT="${i#*=}"
    shift
    ;;
    *)
      # unknown option
    ;;
esac
done


url="https://api.bitbucket.org/1.0/repositories/$ACCOUNT/$PROJECT/deploy-keys";

cmd=$1
param=$2

if [ -z "$USER" ] || [ -z "$ACCOUNT" ] || [ -z "$PROJECT" ] ; then help; fi

if [ -z "$cmd" ]; then cmd=list; fi

#echo "user: $USER"
#echo "account: $ACCOUNT"
#echo "project: $PROJECT"
echo
echo "$cmd $url $param "
echo

if [ "$cmd" == "add" ]; then
  # Add a deploy key
  if [ -z "$param" ]; then help; fi
  #value=`cat ./files/example.pub`
  value=`cat $param`
  label=deploy@$PROJECT
  curl -D- -u $USER -X POST $url -H "Content-Type: application/json" --data "{ \"label\": \"$label\", \"key\":\"$value\"}"
fi

if [ "$cmd" == "list" ]; then
  # Get list of deploy key with their ids
  curl -D- -u $USER -X GET $url
fi

if [ "$cmd" == "del" ]; then
  # Use an id to remove a deploy-key
  if [ -z "$param" ]; then help; fi
  #curl -D- -u $user -X DELETE -H "Content-Type: application/json" $url/1592071
  curl -D- -u $USER -X DELETE -H "Content-Type: application/json" $url/$param
fi
