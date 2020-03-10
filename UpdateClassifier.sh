#!/bin/bash

# Wait that classifier is in ready state
while [ "$STATUS" != "ready" ]
do
  STATUS=`curl -s -X GET "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers/$CLASSIFIER?api_key=$API_KEY&version=2016-05-20" | python -c "import json,sys;obj=json.load(sys.stdin);print obj['status'];"`
  echo "Not ready. Waiting 10s."
  sleep 10s
done

for i in {0..10}; do

  CLASS_LIST=`ls train/*.zip | awk -v first="$(($i*9+10 + 1))" -v last="$(($i*9+10 + 9))" 'NR >=first && NR <=last {split($0,a,"."); split(a[1],a,"/"); printf " -F " a[2] "_positive_examples=@" $0 }' -  `

  COMMAND="curl -X POST $CLASS_LIST https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers/$CLASSIFIER?api_key=$API_KEY&version=2016-05-20"
  echo $COMMAND
  $COMMAND

  # wait the retrained timestamp is not void or has been updated
  while [ "$RETRAINED" == "" ] || [ "$RETRAINED" == "$TIMESTAMP" ]
  do
    RETRAINED=`curl -s -X GET "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classifiers/$CLASSIFIER?api_key=$API_KEY&version=2016-05-20" | python -c "import json,sys;obj=json.load(sys.stdin);print obj['retrained'];"`
    echo "Waiting update. Waiting 10s."
    sleep 20s
  done

  TIMESTAMP=$RETRAINED
  echo "New timestamp $TIMESTAMP"
done
