#!/usr/bin/env bash

set -e

# USAGE:
# - Set PLUGINS_DIR to wherever OpenplanetNext/Plugins lives
# ./build.sh [dev|release]
# Defaults to `dev` build mode.

export PLUGINS_DIR=${PLUGINS_DIR:-$HOME/win/Openplanet4/Plugins}

./build.sh $@
