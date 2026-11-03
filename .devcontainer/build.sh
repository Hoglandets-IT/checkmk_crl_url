#!/bin/bash

NAME=$(python3 -c 'print(eval(open("package").read())["name"])')
VERSION=$(python3 -c 'print(eval(open("package").read())["version"])')
PLUGIN_DIR=$OMD_ROOT/local/lib/python3/cmk_addons/plugins/$NAME

rm /omd/sites/cmk/var/check_mk/packages/${NAME} \
   /omd/sites/cmk/var/check_mk/packages_local/${NAME}-*.mkp ||:

# Checkmk 2.5+ `mkp package` removes the packaged files and reinstalls them
# from the new mkp. With the plugin directory symlinked to the workspace this
# would delete the sources, so package from a temporary copy instead.
rm -rf "$PLUGIN_DIR"
cp -r "$WORKSPACE" "$PLUGIN_DIR"
trap 'rm -rf "$PLUGIN_DIR"; ln -s "$WORKSPACE" "$PLUGIN_DIR"' EXIT

mkp -v package package ||:

cp /omd/sites/cmk/var/check_mk/packages_local/$NAME-$VERSION.mkp .

mkp inspect $NAME-$VERSION.mkp
