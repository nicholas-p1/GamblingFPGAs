#!/bin/bash
rm -f out.txt

IP=18.132.52.158:3000
SRC="http://${1}:${2}@${IP}/poker/fpgaData"

DATAIN=$(curl $SRC)

echo $DATAIN

echo $DATAIN | ./checkError

if ! [ $? ] 
then
    echo "Server responded with an error message: \"${DATAIN}\". Terminating Request."
    exit 1
fi

echo $DATAIN | nios2-terminal | ./readResponse > out.txt&

sleep 1.5

killall nios2-terminal

DATAOUT=$(cat out.txt)

echo $DATAOUT

echo $DATAOUT | ./checkError

if ! [ $? ] 
then
    echo "FPGA responded with invalid output: \"${DATAIN}\". Terminating Request."
    exit 1
fi

curl --header "Content-Type: application/json; charset=UTF-8" \
    --request POST \
    --data "${DATAOUT}" \
    $SRC
