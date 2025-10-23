#!/usr/bin/env bash

set -euxo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# create swift bindings
rm -rf ./bindings ./ios
mkdir -p ./bindings
mkdir -p ./ios
mkdir -p ./bindings/Headers

host_triple="$(rustc --version --verbose | grep host: | cut -d' ' -f 2)"

cargo build \
  --release \
  --lib \
  --bin uniffi-bindgen \
  --target "$host_triple" \
  --target aarch64-apple-ios \
  --target aarch64-apple-ios-sim

../target/"$host_triple"/release/uniffi-bindgen \
  generate \
  --library ../target/"$host_triple"/release/liblumina_node_uniffi.dylib \
  --language swift \
  --out-dir ./bindings

cat \
	./bindings/lumina_node_uniffiFFI.modulemap \
	./bindings/lumina_nodeFFI.modulemap \
	./bindings/celestia_typesFFI.modulemap \
	./bindings/celestia_grpcFFI.modulemap \
	./bindings/celestia_protoFFI.modulemap > ./bindings/Headers/module.modulemap

cp ./bindings/*.h ./bindings/Headers/

rm -rf ./ios/lumina.xcframework

# create xcode project
xcodebuild -create-xcframework \
  -library ../target/aarch64-apple-ios/release/liblumina_node_uniffi.a -headers ./bindings/Headers \
  -library ../target/aarch64-apple-ios-sim/release/liblumina_node_uniffi.a -headers ./bindings/Headers \
  -output "ios/lumina.xcframework"

cp ./bindings/*.swift ./ios/

rm -rf bindings
