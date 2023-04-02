#!/bin/bash
# This script is in charge of withdrawing the rewards to an indicated wallet, then it will be in charge of delegating it to a valoperaddress.

#*******This is an Alpha version, we will update the script periodically. Use it at your own risk, we will not be responsible for any loss due to misuse.*****

#----------------------------------------------------------------
#This script is created by validators GPvalidator.
#----------------------------------------------------------------
# Export variable 

export PATH=$PATH:/usr/local/bin/
export PATH=$PATH:/usr/local/go/bin/
echo "                       --------------------------------------------------------------------------------------------      "
echo "                       | This script is for withdrawing rewards and then choosing whether to delegate them or not |"
echo "                       --------------------------------------------------------------------------------------------      "
# Variables to Celestia
CLI=""
ADDRESS=""
VALOPER=""
AMOUNT=""
OPTION=""
FEE=400
TOKEN=utia
CHAIN_ID=blockspacerace-0
DELEGATED=""


read -p "Path of your celestia-appd, enter (1) for PATH default ($HOME/go/bin/celestia-appd) or enter (2) for custom PATH: " OPTION
if [ $OPTION -eq 1 ]; then
        CLI=$HOME/go/bin/celestia-appd
fi 
if [ -e $CLI ]; then
        echo ""
else
        echo " The path does not exist, the program will close, try again "
        exit
fi
        if [ $OPTION -eq 2 ]; then
                read -p " Enter your custom path:  " CLI
fi

read -p " Enter your pubkey from the wallet adress:  " ADDRESS

read -p " Enter your valoperaddress:  " VALOPER

read -p " Enter the valoperaddress you want to delegate to:  " DELEGATED

echo "-------------------------------------------------------------------------------- "

# Whitdraw rewards to wallet address
 ${CLI} tx distribution withdraw-rewards $VALOPER --from $ADDRESS --commission --chain-id $CHAIN_ID -y --fees $FEE$TOKEN

if [ $? -eq 0 ]; then
        echo "-------------------------------------------------------------------------------- "
        echo "whitdraw sent successfully"
else
        echo "An error has occurred"
        exit
fi

echo "-------------------------------------------------------------------------------- "
echo ""

# Check the available balance
echo "                ---------------- "
echo "                  |Amount balance| "
echo "                ----------------  "

sleep 7
#$CLI query bank balances $ADDRESS
$CLI query bank balances $ADDRESS


if [ $? -eq 0 ]; then
        echo "whitdraw sent successfully"
else    
        echo "An error has occurred"
        exit
fi

echo "--------------------------------------------------- "

read -p "Do you want to delegate? (yes/no): " choice
if [ $choice == "yes" ]; then

# Get the balance of the address
BALANCE=$($CLI query bank balances ${ADDRESS} --chain-id ${CHAIN_ID} | grep 'amount' | awk '{print $3}' | tr -d '",')
# Calculate the amount to delegate

read -p "Do you want to delegate all or a specific amount? (all/specific): " choice
if [ $choice == "all" ]; then
    AMOUNT="-all"
else
    #ask for the amount to delegate
    read -p "Enter the amount you want to delegate: " AMOUNT
fi

AMOUNT=`expr $BALANCE - $FEE`


#echo -e "${AMOUNT}" | read -p " Enter the amount to Celestia you want to delegate:  " AMOUNT
echo "--------------------------------------------------- "

#CLI delegate

data=$(date)
celestia=`$CLI tx staking delegate $DELEGATED $AMOUNT$TOKEN --from=$ADDRESS --fees ${FEE}${TOKEN} --chain-id=$CHAIN_ID`

if [ $? -eq 0 ]; then
        echo "------------------------------------- "
        echo "|     transaction completed         | "
        echo "------------------------------------- "
else
        echo " A problem has occurred " 
fi

echo " $celestia " 
echo " ======== $data ========
mkdir -p $HOME/txid 

$celestia TXHASH === amount whitdraw: $AMOUNT $TOKEN" >> $HOME/txid/txid.txt
else
    echo "Delegation skipped"
fi

	
