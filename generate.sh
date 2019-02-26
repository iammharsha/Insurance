# generate genesis block for orderer
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsOrdererGenesis -outputBlock ./genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputCreateChannelTx ./mychannel.tx -channelID mychannel
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./InsuranceMSPanchors.tx -channelID mychannel -asOrg InsuranceMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./HospitalMSPanchors.tx -channelID mychannel -asOrg HospitalMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -configPath /home/harsha/fabric-samples/insurance1/artifacts/channel/ -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./PatientMSPanchors.tx -channelID mychannel -asOrg PatientMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
