#!/bin/sh
#
# Script steps;
#   1. create 10 accounts and send 1000000 Lovelaces from Faucet to each account
#   2. run multiple-transactions-per-slot-2-accounts.sh script in parallel (10 times) using as
#      source one of the accounts created above
#
# Disclaimer:
#
#  The following use of shell script is for demonstration and understanding
#  only, it should *NOT* be used at scale or for any sort of serious
#  deployment, and is solely used for learning how the node and blockchain
#  works, and how to interact with everything.
#
REST_URL="http://127.0.0.1:8443/api"
CLI="jcli"
COLORS=1
FEE_CONSTANT=10
FEE_CERTIFICATE=0
FEE_COEFFICIENT=0
ADDRTYPE="--testing"
SLOT_DURATION="4"
TIMEOUT_NO_OF_BLOCKS=30
INITIAL_TIP=""
TX_COUNTER_SAME_SLOT="aa"
INITIAL_SRC_COUNTER=0
INITIAL_SOURCE_COUNTER=0

getTip() {
    echo $(${CLI} rest v0 tip get -h "${REST_URL}")
}

waitNewBlockCreated() {
    COUNTER=${TIMEOUT_NO_OF_BLOCKS}
    echo "  ##Waiting for new block to be created (timeout = $COUNTER blocks = $(( $COUNTER*$SLOT_DURATION ))s)"
    initialTip=$(getTip)
    actualTip=$(getTip)

    while [[ "${actualTip}" = "${initialTip}" ]]; do
        sleep ${SLOT_DURATION}
        actualTip=$(getTip)
        COUNTER=$((COUNTER-1))
        if [[ ${COUNTER} -lt 2 ]]; then
            echo "  ERROR: Waited $(( $COUNTER*$SLOT_DURATION ))s secs ($COUNTER*$SLOT_DURATION) and no new block created"
            exit 1
        fi
    done
    echo "New block was created - $(getTip)"
}

###
#   1. create Accounts depending on the number of parallel runs
###

for i in `seq 1 10`;
do
    ACCOUNT_SK=$(jcli key generate --type=ed25519extended)
    ACCOUNT_PK=$(echo ${ACCOUNT_SK} | jcli key to-public)
    ACCOUNT_ADDR=$(jcli address account ${ACCOUNT_PK} --testing)

    list_of_source_sks[i]=${ACCOUNT_SK}
    list_of_source_addrs[i]=${ACCOUNT_ADDR}
done

##
#   2. send funds form Faucet to the above created Accounts
##

for i in `seq 1 ${#list_of_source_sks[@]}`;
do
    echo " == Sending funds to Account no: $i"
    bash faucet-send-money.sh ${list_of_source_addrs[$i]} 1000000
    waitNewBlockCreated
done

###
#   3. run multiple-transactions-per-slot-2-accounts.sh script providing source account from above as argument
###
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[1]} 40 | tee script1Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[2]} 40 | tee script2Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[3]} 40 | tee script3Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[4]} 40 | tee script4Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[5]} 40 | tee script5Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[6]} 40 | tee script6Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[7]} 40 | tee script7Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[8]} 40 | tee script8Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[9]} 40 | tee script9Logs.txt &
bash multiple-transactions-per-slot-2-accounts.sh ${list_of_source_sks[10]} 40 | tee script10Logs.txt &


wait
echo all processes complete