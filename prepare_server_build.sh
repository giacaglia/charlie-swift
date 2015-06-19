#!/bin/bash

# this script expects to be run as ./bin/prepare_server_build.sh from the Lola root directory.
# note that it does NOT currently enforce this, however.

# first rewrite the Info.plist so that the bundle ID becomes net.blade.charlie_enterprise
# note that this should really exit 1; if failure.
echo "Rewriting bundle ID to net.blade.charlie_enterprise"
sed 's/net.blade.charlie/net.blade.charlie_enterprise/' charlie/Info.plist > charlie/Info.plist.tmp && mv charlie/Info.plist.tmp charlie/Info.plist

# now rewrite the project file to reference the Blade enterprise certificate

echo "Rewriting provisioning profile to Enterprise Distribution"
sed 's/PROVISIONING_PROFILE.*=.*".*";/PROVISIONING_PROFILE = "8e81b484-5c02-43bf-86c5-57b109b6a850";/' charlie.xcodeproj/project.pbxproj > charlie.xcodeproj/project.pbxproj.tmp && mv charlie.xcodeproj/project.pbxproj.tmp charlie.xcodeproj/project.pbxproj
