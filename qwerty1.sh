jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

export PATH=../bin:$PATH

starttimeq=$(date +%s)

function getTime(){
  #TIME=$(($(date +%s%N)/1000000))
  TIME=$(date +%s)
}

# Print the usage message
# Language defaults to "golang"
LANGUAGE="golang"

##set chaincode path
function setChaincodePath(){
	LANGUAGE="golang"
	CC_SRC_PATH="github.com/example_cc/go"
}

tt=0
rt=0

setChaincodePath

echo "POST request Enroll on Insurance  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Harish&orgName=insurance')
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"
echo
echo "POST request Enroll on Hospital ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jagan&orgName=hospital')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"
echo
echo "POST request Enroll on Patient ..."
echo
ORG3_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Belal&orgName=patient')
echo $ORG3_TOKEN
ORG3_TOKEN=$(echo $ORG3_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG3 token is $ORG3_TOKEN"
echo
echo
echo "POST request Create channel  ..."
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
echo
echo
sleep 5
echo "POST request Join channel on Insurance"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.insurance.example.com","peer1.insurance.example.com"]
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST request Join channel on Hospital"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.hospital.example.com","peer1.hospital.example.com"]
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST request Join channel on Patient"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.patient.example.com","peer1.patient.example.com"]
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST request Update anchor peers on Insurance"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/InsuranceMSPanchors.tx"
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST request Update anchor peers on Hospital"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/HospitalMSPanchors.tx"
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST request Update anchor peers on Patient"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels/mychannel/anchorpeers \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"configUpdatePath":"../artifacts/channel/PatientMSPanchors.tx"
}'
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo


echo "POST Install chaincode on Insurance"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.insurance.example.com\",\"peer1.insurance.example.com\"],
	\"chaincodeName\":\"mycc15\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST Install chaincode on Hospital"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG2_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.hospital.example.com\",\"peer1.hospital.example.com\"],
	\"chaincodeName\":\"mycc15\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

echo "POST Install chaincode on Patient"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG3_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.patient.example.com\",\"peer1.patient.example.com\"],
	\"chaincodeName\":\"mycc15\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo
echo "POST instantiate chaincode on Insurance"
echo
getTime
starttime=$TIME
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"mycc15\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"Lucy\",\"A123\",\"9876598765\",\"50000\"]
}"
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo
echo "GET query chaincode on peer1 of Org1"
echo
getTime
starttime=$TIME
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc15?peer=peer0.insurance.example.com&fcn=query&args=%5B%22A123%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
rt=$((rt+1))
getTime
endtime=$TIME
READ=$(( READ + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo
echo "Invoke Chaincode - Claim Insurance"
echo
getTime
starttime=$TIME
curl -s -X POST   http://localhost:4000/channels/mychannel/chaincodes/mycc15   -H "authorization: Bearer $ORG3_TOKEN"   -H "content-type: application/json"   -d "{
\"fcn\":\"move\",
\"args\":[\"A123\",\"H1\",\"100\"]
}"
tt=$((tt+1))
getTime
endtime=$TIME
TRANSACTION=$(( TRANSACTION + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo
echo "GET query chaincode on peer1 of Org1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc15?peer=peer0.insurance.example.com&fcn=query&args=%5B%22A123%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
rt=$((rt+1))
getTime
endtime=$TIME
READ=$(( READ + $(( endtime - starttime )) ))
execTime=$(( endtime - starttime ))
echo "Execution Time = $execTime s"
echo
echo

#echo "GET query Block by blockNumber"
#echo
#BLOCK_INFO=$(curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.patient.example.com" \
#  -H "authorization: Bearer $ORG3_TOKEN" \
#  -H "content-type: application/json")
#echo $BLOCK_INFO

# Assign previous block hash to HASH
#HASH=$(echo $BLOCK_INFO | jq -r ".header.previous_hash")
#echo $HASH

total=$(($(date +%s)-starttimeq))
tthroughput=$(( ( tt * 100 ) / TRANSACTION ))
rthroughput=$(( ( rt * 100 ) / READ ))
echo "Total execution time : $total secs ..."
echo
echo "Transaction Throughput= $tthroughput"
echo
echo "Read Throughput = $rthroughput"
echo
