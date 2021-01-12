#!/bin/bash
# Author: Clark Stühmer
VERSION=0.1
# Description:
# 	Get available crypto balance.
# Synopsis:
#	sh crypto-balance.sh -p coinbase,binance -w all -c eur
# Parameters:
#	-p | --provider
#		A comma-seperated list of wallet provider to use. Available values are:
#		coinbase, binance
#	-w | --wallet
#		The wallet to parse. Available values are:
#		all, btc, eth, ltc, xlm
#	-c | --fiat
#		Fiat currency. Default: USD, all available values are:
#		usd, eur
#	-f | --api-file
#		File to read API- & secret keys from. For an example on how this file
#		should be formatted, have a look at the readme.
#	--up
#		String to pre- or append for upwards trend. Default: "▴ "
#	--down
#		String to pre- or append for downwards trend. Default: "▾ "

TMPFILE="./balance.tmp"

PRFX_UP="▴ "
PRFX_DOWN="▾ "

API_FILE="$HOME/Documents/Private/balance.txt"
PROVIDER="binance"

#Parse API keys and secrets from API-file
while read -r LINE
do
	REGEX="^(.+):(.+),(.+)"
	if [[ $LINE =~ $REGEX ]]
	then
		API_KEY=${BASH_REMATCH[2]}
		API_SECRET=${BASH_REMATCH[3]}
		#echo "Provider: ${BASH_REMATCH[1]}"
		#echo "API key: $API_KEY"
		#echo "API secret: $API_SECRET"
	fi
done < "$API_FILE"

#Parse parameters

#Call API
case $PROVIDER in
	"coinbase")
		API_ENDPOINT="https://coinbase.com"
		CB_SIGNATURE=$(echo "$(date +%s)" | openssl dgst -sha256 -hmac "$API_SECRET")

		curl "$API_ENDPOINT" \
			-H "CB-ACCESS-KEY: $API_KEY" \
			-H "CB-ACCESS-SIGN: $CB_SIGNATURE" \
			-H "CB-ACCESS-TIMESTAMP: $CB_TIMESTAMP"
		;;
	"binance")
		API_ENDPOINT="https://api.binance.com"

		#Get current prices
		PRICES=$(curl -s "${API_ENDPOINT}/api/v3/ticker/price")

		QUERY_STRING="timestamp=$(date +%s%3N)"
		BN_SIGNATURE=$(echo -n "$QUERY_STRING" | openssl dgst -sha256 -hmac "$API_SECRET" | sed -r 's/\(stdin\)=\s{1}//')

		RESPONSE=$(curl -s "${API_ENDPOINT}/api/v3/account?${QUERY_STRING}&signature=${BN_SIGNATURE}" \
			-H "X-MBX-APIKEY: $API_KEY")
		;;
esac

#Echo output
