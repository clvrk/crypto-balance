#!/usr/bin/env bash
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
#	-c | --base
#		Base currency. Default: USDT
#	-i | --include-base
#		Include base asset in total balance.
#	-l | --include-locked
#		Include locked assets in total balance.
#	-f | --api-file
#		File to read API- & secret keys from. For an example on how this file
#		should be formatted, have a look at the readme.
#	--prfx-up
#		String to pre- or append for upwards trend. Default: "▴ "
#	--prfx-down
#		String to pre- or append for downwards trend. Default: "▾ "

TMPDIR="$HOME/.cache/crypto-balance"
TMPFILE="${TMPDIR}/balance.tmp"

if [[ ! -d "$TMPDIR" ]]; then
	mkdir -p "$TMPDIR"
fi

BASE_FIAT="USDT"
PRFX_UP="▴ "
PRFX_DOWN="▾ "

#Parse command line parameters
i=1
while [[ -n ${!i} ]]; do
	j=$(($i+1))
	#echo "$i: ${!i}, val: ${!j}"
	case ${!i} in
		"-p") ;&
		"--provider")
			PROVIDER="${!j}"
			i=$(($j+1))
			;;
		"-w") ;&
		"--wallet")
			WALLET="${!j}"
			i=$(($j+1))
			;;
		"-c") ;&
		"--fiat")
			BASE_FIAT="${!j}"
			i=$(($j+1))
			;;
		"-i") ;&
		"--include-base")
			INCLUDE_BASE=1
			i=$j
			;;
		"-l") ;&
		"--include-locked")
			INCLUDE_LOCKED=1
			i=$j
			;;
		"-f") ;&
		"--api-file")
			API_FILE="${!j}"
			i=$(($j+1))
			;;
		"--prfx-up")
			PRFX_UP="${!j}"
			i=$(($j+1))
			;;
		"--prfx-down")
			PRFX_DOWN="${!j}"
			i=$(($j+1))
			;;
	esac
done

#Parse API keys and secrets from API-file
while read -r LINE
do
	REGEX='^(.+):(.+),(.+)'
	if [[ $LINE =~ $REGEX ]]
	then
		API_KEY=${BASH_REMATCH[2]}
		API_SECRET=${BASH_REMATCH[3]}
	fi
done < "$API_FILE"

#Parse parameters
function calculateBalance() {
	RESULT=0

	while read -r LINE
	do
		RESULT=$(echo "$RESULT + $LINE" | bc)

		#echo "$LINE" >&2
	done < <(echo "$1")

	echo "$RESULT"
}

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

		WALLETS=$(echo -n "$PRICES $RESPONSE" | jq -r -s --arg BASE_FIAT "$BASE_FIAT" --arg INCLUDE_BASE "$INCLUDE_BASE" --arg INCLUDE_LOCKED "$INCLUDE_LOCKED" \
			'.[0] as $prices | .[1].balances[] |
			 .asset as $asset | (.free | tonumber) as $free | (.locked | tonumber) as $locked |
			 select ($free > 0 or $locked > 0) |
			 ($free + $locked) as $balance |
			 if ($INCLUDE_BASE == "1" and $asset == $BASE_FIAT) then
			 	$balance
			 else
			 	$prices[] |
			 	if .symbol == $asset + $BASE_FIAT then
					$balance * (.price | tonumber)
			 	elif .symbol == $BASE_FIAT + $asset then
					$balance / (.price | tonumber)
			 	else
					empty
			 	end
			end
			')
		;;
esac

if [[ -n $WALLETS ]]; then
	BALANCE=$(calculateBalance "$WALLETS")

	if (( $(echo "$BALANCE > $(cat $TMPFILE)" | bc) )); then
		PRFX=$PRFX_UP
	else
		PRFX=$PRFX_DOWN
	fi

	#Store previous balance to temporary file
	echo "$BALANCE" > $TMPFILE

	printf "%s%.2f" "${PRFX}" "${BALANCE}"
else
	echo -n "--"
fi
