docker-compose -f artifacts/docker-compose.yaml down

# generate genesis block for orderer
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsOrdererGenesis -outputBlock ./artifacts/channel/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputCreateChannelTx ./artifacts/channel/mychannel.tx -channelID mychannel
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./artifacts/channel/InsuranceMSPanchors.tx -channelID mychannel -asOrg InsuranceMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./artifacts/channel/HospitalMSPanchors.tx -channelID mychannel -asOrg HospitalMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./artifacts/channel/PatientMSPanchors.tx -channelID mychannel -asOrg PatientMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

docker-compose -f artifacts/docker-compose.yaml up -d

PORT=4000 node app
