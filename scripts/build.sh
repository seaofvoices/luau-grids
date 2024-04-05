#!/bin/sh

set -e

scripts/build-single-file.sh .darklua-bundle.json build/luau-grids.lua
scripts/build-single-file.sh .darklua-bundle-dev.json build/debug/luau-grids.lua
scripts/build-roblox-model.sh .darklua.json build/luau-grids.rbxm
scripts/build-roblox-model.sh .darklua-dev.json build/debug/luau-grids.rbxm
