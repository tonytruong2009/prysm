### TL;DR

- **Git Tag**: Use the tag `v0.1.0-devnet` from the Prysm repository: [https://github.com/kleomedes/prysm](https://github.com/kleomedes/prysm).
- **Genesis File**: Replace with [this genesis file](https://raw.githubusercontent.com/kleomedes/prysm/refs/heads/main/network/prysm-devnet-1/genesis.json).
- **Grab some tokens**: https://prysm-devnet-faucet.kleomedes.network/
- **Peer**: ```bash b377fd0b14816eef8e12644340845c127d1e7d93@dns.kleomed.es:26656```

---

### Tutorial: Setting Up a Cosmos SDK Node for Prysm

This guide assumes you have experience with Linux and blockchain node management. We will cover the steps to install Go 1.22.3, clone and compile the Prysm repository using the `v0.1.0-devnet` tag, initialize the node with the correct `chain-id`, replace the `genesis.json` file, and set up the node as a systemd service.

### 1. Install Golang 1.22.3

Since Go is required to compile Cosmos SDK nodes, the first step is installing Go.

1.1. **Update your package index**:
```bash
sudo apt update && sudo apt upgrade -y
```

1.2. **Download and install Go 1.22.3**:
```bash
wget https://go.dev/dl/go1.22.3.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz
```

1.3. **Set up Go environment variables**:
Add the following line to your shell profile (e.g., `~/.bashrc` or `~/.zshrc`):
```bash
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
source ~/.bashrc
```

1.4. **Verify Go installation**:
```bash
go version
```
Expected output:
```
go version go1.22.3 linux/amd64
```

### 2. Clone and Build Prysm

2.1. **Install prerequisites**:
```bash
sudo apt install -y git make gcc
```

2.2. **Clone the Prysm repository**:
```bash
git clone https://github.com/kleomedes/prysm
cd prysm
```

2.3. **Check out the `v0.1.0-devnet` tag**:
```bash
git checkout tags/v0.1.0-devnet
```

2.4. **Compile the `prysmd` binary**:
```bash
make install
```
This will download dependencies, build the binary, and install it in `$GOPATH/bin`.

2.5. **Verify installation**:
```bash
prysmd version
```

### 3. Initialize the Node

Now that the `prysmd` binary is installed, initialize your node with the appropriate `chain-id`.

3.1. **Initialize the node**:
```bash
prysmd init <node-name> --chain-id prysm-devnet-1
```
Replace `<node-name>` with your preferred node name.

### 4. Replace the `genesis.json` File

The initialized node comes with a default `genesis.json`, which needs to be replaced with the official Prysm devnet version.

4.1. **Download the official `genesis.json`**:
```bash
curl -o ~/.prysmd/config/genesis.json https://raw.githubusercontent.com/kleomedes/prysm/refs/heads/main/network/prysm-devnet-1/genesis.json
```

### 5. Set Up `prysmd` as a Systemd Service

Running the node as a systemd service ensures that it will automatically restart on failure and after system reboots.

5.1. **Create a systemd service file**:
```bash
sudo nano /etc/systemd/system/prysmd.service
```

5.2. **Add the following content**:
```ini
[Unit]
Description=Prysm Daemon
After=network-online.target

[Service]
User=<your-username>
ExecStart=/home/<your-username>/go/bin/prysmd start
Restart=on-failure
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
```
Replace `<your-username>` with your actual Linux username.

5.3. **Reload systemd to apply the new service**:
```bash
sudo systemctl daemon-reload
```

5.4. **Enable the service to start on boot**:
```bash
sudo systemctl enable prysmd
```

5.5. **Start the `prysmd` service**:
```bash
sudo systemctl start prysmd
```

### 6. Monitoring the Node

To verify that your node is running correctly, use the following commands:

6.1. **Check the status of the service**:
```bash
sudo systemctl status prysmd
```

6.2. **View logs in real-time**:
```bash
journalctl -fu prysmd
```
