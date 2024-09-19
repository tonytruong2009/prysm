# Takes a default genesis and creates a new modified genesis file.
#
# sh network/prysm-1/from_scratch.sh
#

CHAIN_ID=prysm-1

make install

export HOME_DIR=$(eval echo "${HOME_DIR:-"~/.prysm"}")

rm -rf $HOME_DIR && echo "Removed $HOME_DIR"

prysmd init moniker --chain-id=$CHAIN_ID --default-denom=uprysm --home $HOME_DIR

update_genesis () {
    cat $HOME_DIR/config/genesis.json | jq "$1" > $HOME_DIR/config/tmp_genesis.json && mv $HOME_DIR/config/tmp_genesis.json $HOME_DIR/config/genesis.json
}

update_genesis '.app_version="1.0.0"'

update_genesis '.consensus["params"]["block"]["max_gas"]="100000000000"' # 100bn
update_genesis '.consensus["params"]["abci"]["vote_extensions_enable_height"]="1"'

# auth
update_genesis '.app_state["auth"]["params"]["max_memo_characters"]="512"'

update_genesis '.app_state["bank"]["denom_metadata"]=[
        {
            "base": "uprysm",
            "denom_units": [
            {
                "aliases": [],
                "denom": "uprysm",
                "exponent": 0
            },
            {
                "aliases": [],
                "denom": "PRYSM",
                "exponent": 6
            }
            ],
            "description": "Denom metadata for Prysm Token (uprysm)",
            "display": "PRYSM",
            "name": "PRYSM",
            "symbol": "PRYSM"
        }
]'

update_genesis '.app_state["crisis"]["constant_fee"]={"denom": "uprysm","amount": "1000000000"}'

update_genesis '.app_state["distribution"]["params"]["community_tax"]="0.000000000000000000"' # 0%

update_genesis '.app_state["gov"]["params"]["min_deposit"]=[{"denom":"uprysm","amount":"100000000"}]'
update_genesis '.app_state["gov"]["params"]["max_deposit_period"]="259200s"'
update_genesis '.app_state["gov"]["params"]["min_deposit_ratio"]="0.100000000000000000"' # 10%
update_genesis '.app_state["gov"]["params"]["voting_period"]="432000s"' # 5 days
update_genesis '.app_state["gov"]["params"]["expedited_voting_period"]="172800s"' # 2 days
update_genesis '.app_state["gov"]["params"]["expedited_min_deposit"]=[{"denom":"uprysm","amount":"1000000000"}]'
update_genesis '.app_state["gov"]["params"]["expedited_threshold"]="0.510000000000000000"' # 50% instead of 66.7%

update_genesis '.app_state["mint"]["minter"]["inflation"]="0.100000000000000000"'
update_genesis '.app_state["mint"]["minter"]["annual_provisions"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["params"]["mint_denom"]="uprysm"'
update_genesis '.app_state["mint"]["params"]["inflation_rate_change"]="0.000000000000000000"'
update_genesis '.app_state["mint"]["params"]["inflation_max"]="0.100000000000000000"'
update_genesis '.app_state["mint"]["params"]["inflation_min"]="0.100000000000000000"'
update_genesis '.app_state["mint"]["params"]["blocks_per_year"]="18934560"' # 2s blocks (( 6s blocks = 6311520 per year ))

update_genesis '.app_state["slashing"]["params"]["signed_blocks_window"]="30000"'
update_genesis '.app_state["slashing"]["params"]["min_signed_per_window"]="0.010000000000000000"'
update_genesis '.app_state["slashing"]["params"]["downtime_jail_duration"]="60s"'
update_genesis '.app_state["slashing"]["params"]["slash_fraction_double_sign"]="0.050000000000000000"' # 5%
update_genesis '.app_state["slashing"]["params"]["slash_fraction_downtime"]="0.000000000000000000"'

update_genesis '.app_state["staking"]["params"]["bond_denom"]="uprysm"' # unbonding time at 1814400s (21 days)
update_genesis '.app_state["staking"]["params"]["min_commission_rate"]="0.000000000000000000"'
update_genesis '.app_state["staking"]["params"]["max_validators"]=50'

update_genesis '.app_state["tokenfactory"]["params"]["denom_creation_fee"]=[]'
update_genesis '.app_state["tokenfactory"]["params"]["denom_creation_gas_consume"]="250000"'

## === GENESIS ACCOUNTS ===

# base / core accounts for the operations of this chain.
prysmd genesis add-genesis-account prysm10r39fueph9fq7a6lgswu4zdsg8t3gxlq3pwgwj 500000000uprysm --append # Reece 'Just incase shit its the fan' wallet [Will be returned to CPool after successful launch, incase of gov props needed]

## === GENESIS / INTERNAL DISTRIBUTION ===
prysmd genesis add-genesis-account prysm10r39fueph9fq7a6lgswu4zdsg8t3gxlq3pwgwj 100uprysm --vesting-amount 100uprysm --vesting-end-time=1725027635 --append # TODO: team

# TODO: Airdrop allocations if applicable
# prysmd fast-add-genesis-account ./airdrop/FINAL_ALLOCATION.json --home=$HOME_DIR


# iterate through the gentx directory, print the files
# https://github.com/strangelove-ventures/bech32cli
for filename in network/prysm-1/gentx/*.json; do
    echo "Processing $filename"
    addr=`cat $filename | jq -r .body.messages[0].validator_address | xargs -I {} bech32 transform {} dragon`
    raw_coin=`cat $filename | jq -r .body.messages[0].value` # { "denom": "uprysm", "amount": "1000000" }
    coin=$(echo $raw_coin | jq -r '.amount + .denom') # make coin = 1000000uprysm
    prysmd genesis add-genesis-account $addr $coin --append
done
prysmd genesis collect-gentxs --gentx-dir network/prysm-1/gentx --home $HOME_DIR

# Move genesis to this directory
prysmd genesis validate
cp $HOME_DIR/config/genesis.json ./network/$CHAIN_ID/genesis.json

# If genesis is to large, compress
# tar -czvf ./network/$CHAIN_ID/genesis.json.tar.gz ./network/$CHAIN_ID/genesis.json
# rm ./network/$CHAIN_ID/genesis.json # too large

