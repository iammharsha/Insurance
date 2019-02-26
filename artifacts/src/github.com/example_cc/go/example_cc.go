/*
Copyright IBM Corp. 2016 All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"encoding/json"
	"fmt"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/peer"
)

type Policy struct {
	PatientName string
	PolicyID    string // Entities
	Phno        int
	Total       int
	HospitalID  string
	Amount      int
}

var logger = shim.NewLogger("insurance")

// SimpleChaincode example simple Chaincode implementation
type SimpleChaincode struct {
}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("########### insurance Init ###########")

	_, args := stub.GetFunctionAndParameters()
	var num, tot int // Asset holdings
	var err error
	num, err = strconv.Atoi(args[2])
	if err != nil {
		return shim.Error("Expecting integer value for asset holding")
	}
	tot, err = strconv.Atoi(args[3])
	if err != nil {
		return shim.Error("Expecting integer value for asset holding")
	}
	// Initialize the chaincode
	var policy := Policy{PatientName: args[0], PolicyID: args[1], Phno: num, Total: tot, HospitalID: "", Amount: 0}
	policyAsBytes, _ := json.Marshal(policy)

	// Write the state to the ledger
	err = stub.PutState(PolicyID, policyAsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)

}

// Transaction makes payment of X units from A to B
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	logger.Info("########### insurance Invoke ###########")

	function, args := stub.GetFunctionAndParameters()

	if function == "delete" {
		// Deletes an entity from its state
		return t.delete(stub, args)
	}

	if function == "query" {
		// queries an entity state
		return t.query(stub, args)
	}
	if function == "move" {
		// Deletes an entity from its state
		return t.move(stub, args)
	}

	logger.Errorf("Unknown action, check the first argument, must be one of 'delete', 'query', or 'move'. But got: %v", args[0])
	return shim.Error(fmt.Sprintf("Unknown action, check the first argument, must be one of 'delete', 'query', or 'move'. But got: %v", args[0]))
}

func (t *SimpleChaincode) move(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// must be an invoke
	var hospiID, PolicyID string
	var Amt int // Transaction value
	var err error

	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3, function followed by 2 names and 1 value")
	}

	// Get the state from the ledger
	// TODO: will be nice to have a GetAllState call to ledger
	PolicyIDbytes, err := stub.GetState(PolicyID)
	if err != nil {
		return shim.Error("Failed to get state")
	}
	if PolicyIDbytes == nil {
		return shim.Error("Entity not found")
	}
	var policy := Policy{}
	PolicyID = args[0]
	hospiID = args[1]
	Amt, err = strconv.Atoi(args[2])

	json.Unmarshal(policyIDBytes, &policy)

	// Perform the execution

	if err != nil {
		return shim.Error("Invalid transaction amount, expecting a integer value")
	}
	policy.Total = policy.Total - Amt
	policy.HospitalID = hospiID
	policy.Amount = Amt
	policyAsBytes, _ = json.Marshal(car)
	APIstub.PutState(PolicyID, policyAsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	logger.Infof("Avail Balance= Total\n", policy.Total)

	return shim.Success(nil)
}

// Deletes an entity from state
func (t *SimpleChaincode) delete(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	A := args[0]

	// Delete the key from the state in ledger
	err := stub.DelState(A)
	if err != nil {
		return shim.Error("Failed to delete state")
	}

	return shim.Success(nil)
}

// Query callback representing the query of a chaincode
func (t *SimpleChaincode) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	var PolicyID string // Entities
	var err error

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting name of the person to query")
	}

	PolicyID = args[0]

	// Get the state from the ledger
	PolicyAsbytes, err := stub.GetState(A)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	if PolicyAsbytes == nil {
		jsonResp := "{\"Error\":\"Nil amount for " + PolicyID + "\"}"
		return shim.Error(jsonResp)
	}
	policy := Policy{}
	json.Unmarshal(policyIDBytes, &policy)

	jsonResp := "{\"PatientID\":\"" + policy.PolicyID + "\",\"HospitalID\":\"" + policy.HospitalID + "\",\"PatientName\":\"" + policy.PatientName + "\",\"Phone Number\":\"" + policy.Phno + "\",\"Balance\":\"" + policy.Total + "\"\"Last Bill Amount\":\"" + policy.Amount + "\"}"
	logger.Infof("Query Response:%s\n", jsonResp)
	return shim.Success(Avalbytes)
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		logger.Errorf("Error starting Simple chaincode: %s", err)
	}
}
