### TL;DR

- **Git Tag**: Use the tag `v0.1.0-devnet` from the Prysm repository: [https://github.com/kleomedes/prysm](https://github.com/kleomedes/prysm).
- **Genesis File**: Replace with [this genesis file](https://raw.githubusercontent.com/kleomedes/prysm/refs/heads/main/network/prysm-devnet-1/genesis.json).
- **Grab some tokens**: https://prysm-devnet-faucet.kleomedes.network/
- **Peer**: ```b377fd0b14816eef8e12644340845c127d1e7d93@dns.kleomed.es:26656```

---

### Tutorial: Setting Up a Cosmos SDK Node for Prysm

This guide assumes you have experience with Linux and blockchain node management. We will cover the steps to install Go 1.22.3, clone and compile the Prysm repository using the `v0.1.0-devnet` tag, initialize the node with the correct `chain-id`, replace the `genesis.json` file, and set up the node as a systemd service.

### 1. Update & install dependencies
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 aria2 pv gcc unzip -y

```
### 2. Install Go
```bash
cd $HOME
VER="1.22.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
go version
```
### 3. Set Vars
```bash
MONIKER="Put_Moniker_name"
echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile
echo "export PRYSM_CHAIN_ID="prysm-devnet-1"" >> $HOME/.bash_profile
echo "export PRYSM_PORT="29"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
### 4. Download Binary
```bash
cd $HOME
rm -rf prysm
git clone https://github.com/kleomedes/prysm prysm
cd prysm
git checkout v0.1.0-devnet
make install
prysmd version
```
### 5. Config and Init app
```bash
prysmd init $MONIKER --chain-id $PRYSM_CHAIN_ID
sed -i -e "s|^node *=.*|node = \"tcp://localhost:${PRYSM_PORT}657\"|" $HOME/.prysm/config/client.toml
sed -i -e "s|^keyring-backend *=.*|keyring-backend = \"os\"|" $HOME/.prysm/config/client.toml
sed -i -e "s|^chain-id *=.*|chain-id = \"prysm-devnet-1\"|" $HOME/.prysm/config/client.toml
```
### 6. Download Genesis file and Addrbook
```bash
wget -O $HOME/.prysm/config/genesis.json https://josephtran.co/prysm/genesis.json
wget -O $HOME/.prysm/config/addrbook.json https://josephtran.co/prysm/addrbook.json
```
### 7. Set custom port (Optional)
```bash
sed -i.bak -e "s%:1317%:${PRYSM_PORT}317%g;
s%:8080%:${PRYSM_PORT}080%g;
s%:9090%:${PRYSM_PORT}090%g;
s%:9091%:${PRYSM_PORT}091%g;
s%:8545%:${PRYSM_PORT}545%g;
s%:8546%:${PRYSM_PORT}546%g;
s%:6065%:${PRYSM_PORT}065%g" $HOME/.prysm/config/app.toml
sed -i.bak -e "s%:26658%:${PRYSM_PORT}658%g;
s%:26657%:${PRYSM_PORT}657%g;
s%:6060%:${PRYSM_PORT}060%g;
s%:26656%:${PRYSM_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${PRYSM_PORT}656\"%;
s%:26660%:${PRYSM_PORT}660%g" $HOME/.prysm/config/config.toml
```
### 8. Config Seeds and Peers
```bash
SEEDS="e3156873994bfbb1999bbf6e4a1ad9cb2f14139e@seed-prysm.j-node.net:29656"
PEERS="e3156873994bfbb1999bbf6e4a1ad9cb2f14139e@seed-prysm.j-node.net:29656,ff15df83487e4aa8d2819452063f336269958d09@prysm-testnet-peer.itrocket.net:25657,01e40fe961c9522936a8bb7ede533198614abf9f@[2a0e:dc0:2:2f71::1]:14256,e0daf1e5649feba5ba3787288e66e1c9921b2c4c@149.50.96.153:19756,50dcf516699f45351037d08c0074629a0748d446@[2a03:cfc0:8000:13::b910:277f]:14256,69509925a520c5c7c5f505ec4cedab95073388e5@136.243.13.36:29856,2334e9eb772d5aaf9c48a2885c41d5c33e911912@65.109.92.163:3020,88ad3a3b9b981f0bbb52d5c996d0f7e1aa9426fa@65.108.206.118:61256,66ea180127711b96e35683be6e6f1cffc2b04e0a@184.107.169.193:25656,f9758cec18d2af1cca6431a42ec5b68230ae12c8@149.102.142.113:40656,170bf5fa23b18d19148ca9a52dbdde485ad59f7b@65.109.79.185:15656,844f4b8382f6abf86ad13fcd2d384214605b094e@144.76.155.11:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.prysm/config/config.toml
```
### 9. Config Pruning & indexer
```bash
pruning="custom"
pruning_keep_recent="100"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.prysm/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.prysm/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.prysm/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.prysm/config/app.toml
```
```bash
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0uprysm\"/" $HOME/.prysm/config/app.toml
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.prysm/config/config.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.prysm/config/config.toml
```
### 10. Create service file
```bash
sudo tee /etc/systemd/system/prysmd.service > /dev/null <<EOF
[Unit]
Description=Prysm-testnet
After=network-online.target

[Service]
User=$USER
ExecStart=$(which prysmd) start --home $HOME/.prysm
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
### 11. Download snapshot
```bash
cd $HOME
sudo systemctl stop prysmd
cp $HOME/.prysm/data/priv_validator_state.json $HOME/.prysm/priv_validator_state.json.backup
rm -f prysm_snapshot.lz4
aria2c -x 16 -s 16 -k 1M https://josephtran.co/prysm/prysm_snapshot.lz4
prysmd tendermint unsafe-reset-all --home $HOME/.prysm
lz4 -dc prysm_snapshot.lz4 | pv | tar -xf - -C $HOME/.prysm
mv $HOME/.prysm/priv_validator_state.json.backup $HOME/.prysm/data/priv_validator_state.json
```
```bash
sudo systemctl daemon-reload
sudo systemctl enable prysmd
sudo systemctl start prysmd && sudo journalctl -fu prysmd -o cat
```
### 12. Check status
```bash
prysmd status | jq
```

```bash
prysmd status | jq '{ latest_block_height: .sync_info.latest_block_height, catching_up: .sync_info.catching_up }'
```
### 13. Check Block sync left
```bash
while true; do
 local_height=$(prysmd status | jq -r '.sync_info.latest_block_height');
  network_height=$(curl -s https://rpc-prysm.josephtran.xyz/status | jq -r '.result.sync_info.latest_block_height')
  blocks_left=$((network_height - local_height));

  echo -e "\033[1;38mYour node height:\033[0m \033[1;34m$local_height\033[0m | \033[1;35mNetwork height:\033[0m \033[1;36m$network_height\033[0m | \033[1;29mBlocks left:\033[0m \033[1;31m$blocks_left\033[0m";
  sleep 5;
done
```
### 14. Create Validator
- Add new wallet
```bash
prysmd keys add "Put_Wallet_name"
```
- Recover Wallet
```bash
prysmd keys add "Put_Wallet_name" --recover
```
- Faucet token with link : (https://prysm-devnet-faucet.kleomedes.network/)
- Check balances
```bash
prysmd q bank balances $(prysmd keys show "Put_Wallet_name" -a)
```
- Create Validator by validator.json file
```bash
cd $HOME
echo "{\"pubkey\":{\"@type\":\"/cosmos.crypto.ed25519.PubKey\",\"key\":\"$(prysmd comet show-validator | grep -Po '\"key\":\s*\"\K[^"]*')\"},
    \"amount\": \"1000000uprysm\",
    \"moniker\": \"Put_Moniker_name\",
    \"identity\": \"\",
    \"website\": \"\",
    \"security\": \"\",
    \"details\": \"\",
    \"commission-rate\": \"0.1\",
    \"commission-max-rate\": \"0.2\",
    \"commission-max-change-rate\": \"0.01\",
    \"min-self-delegation\": \"1\"
}" > validator.json
```
- Create Validator with .json file above
```bash
prysmd tx staking create-validator validator.json \
  --from "Put_Wallet_name" \
  --chain-id prysm-devnet-1 \
  --gas auto --gas-adjustment 1.5 \
  -y
```
*** You should backup the validator key to recover Validator when you need. File you need in here /.prysm/config/priv_validator_key.json
 
