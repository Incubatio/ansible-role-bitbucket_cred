#!/bin/bash

function help {
  echo ""
  echo "/!\ Missing Param"
  echo ""
  echo "Usage:"
  echo "  ./deploy_key.sh -u=<user> -p=<password> -o=<owner> -r=<repository> list"
  echo "  ./deploy_key.sh -u=<user> -p=<password> -o=<owner> -r=<repository> add <ssh_key_path> (ex: /path/to/ssh_key)"
  echo "  ./deploy_key.sh -u=<user> -p=<password> -o=<owner> -r=<repository> del <pk> (ex: 12345, you can get pk from list)"
  exit
}

for i in "$@"
do
case $i in
    -u=*|--user=*)
    USER="${i#*=}"
    shift
    ;;
    -p=*|--password=*)
    PASSWORD="${i#*=}"
    shift
    ;;
    -o=*|--owner=*)
    OWNER="${i#*=}"
    shift
    ;;
    -r=*|--repository=*)
    REPO="${i#*=}"
    shift
    ;;
    *)
      # unknown option
    ;;
esac
done


url="https://api.bitbucket.org/1.0/repositories/$OWNER/$REPO/deploy-keys";

cmd=$1
param=$2

if [ -z "$USER" ] || [ -z "$PASSWORD" ] || [ -z "$OWNER" ] || [ -z "$REPO" ] ; then help; fi
cred=${USER}:${PASSWORD}

if [ -z "$cmd" ]; then cmd=list; fi

#echo "user: $USER"
#echo "owner: $OWNER"
#echo "repo: $REPO"
echo
echo "$cmd $url $param "
echo

if [ "$cmd" == "add" ]; then
  # Add a deploy key
  if [ -z "$param" ]; then help; fi
  #value=`cat ./files/example.pub`
  value=`cat $param`
  ts=`date +%s`
  label=BDK:${USER}@${REPO}_${ts}
  curl -D- -u $cred -X POST $url -H "Content-Type: application/json" --data "{ \"label\": \"$label\", \"key\":\"$value\"}"
fi

if [ "$cmd" == "list" ]; then
  # Get list of deploy key with their ids
  curl -D- -u $cred -X GET $url
fi

if [ "$cmd" == "del" ]; then
  # Use an id to remove a deploy-key
  if [ -z "$param" ]; then help; fi
  #curl -D- -u $user -X DELETE -H "Content-Type: application/json" $url/1592071
  curl -D- -u $cred -X DELETE -H "Content-Type: application/json" $url/$param
fi
