## Running Go Celestia node docker setup

Follow [this guide](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic)
to authorize yourself in github's container registry.

Starting a Celestia network with single validator and bridge
```bash
# start the setup
docker compose -f ci/docker-compose.yml up --build --force-recreate -d

# get webtransport bootstrap address
docker compose -f ci/docker-compose.yml logs bridge-0 | grep -o '/ip4.*172.*webtransport.*'

# and to stop it
docker compose -f ci/docker-compose.yml down
```

## Running lumina in browser

```bash
# install dependencies
sudo apt-get install -y build-essential curl git npm

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install wasm-pack

# clone the repository
git clone https://github.com/zvolin/lumina

# clone libp2p
git clone https://github.com/libp2p/rust-libp2p
cd rust-libp2p
# apply patches with logs
git checkout c34668e2ca6ab6fad4e097fceeeccc1f4881b3d4
patch -p 1 <../lumina/libp2p-patch

cd ../lumina
git checkout wt-stream-stopsend-repro

# compile lumina to wasm
wasm-pack build node-wasm
# build the local webpage
cd cli/js
npm i && npm run build
cd -
# run browser node
cargo run --features browser-node -- browser

# open localhost:9876 in firefox
# Click on 'Network' and choose 'Private'
# Paste the webtransport bootstrap addr in 'Bootnodes'
# If celestia docker setup was restarted, previous data needs to be cleaned. Go into dev console (ctrl-shift-c), click storage, indexeddb, localhost, delete everything with 'private' in name
# Open console
# Click start, wait for some time, hit stop and check logs
```
