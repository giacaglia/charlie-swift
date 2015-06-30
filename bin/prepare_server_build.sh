#!/bin/bash

# this script expects to be run as ./bin/prepare_server_build.sh from the Charlie root directory.
# note that it does NOT currently enforce this, however.

# first rewrite the Info.plist so that the bundle ID becomes net.blade.charlieEnterprise
# note that this should really exit 1; if failure.
echo "Rewriting bundle ID to net.blade.charlieEnterprise"
sed 's/net.blade.charlie/net.blade.charlieEnterprise/' charlie/Info.plist > charlie/Info.plist.tmp && mv charlie/Info.plist.tmp charlie/Info.plist

# Unit Test building hack - changes bundle ID of unit tests to net.blade.charlieEnterprise
# This should be removed/improved
# note that this should really exit 1; if failure.
echo "Rewriting bundle ID to net.blade.charlieEnterprise"
sed 's/net.blade.charlieTests/net.blade.charlieEnterprise/' charlieTests/Info.plist > charlieTests/Info.plist.tmp && mv charlieTests/Info.plist.tmp charlieTests/Info.plist

# now rewrite the project file to reference the Blade enterprise certificate

echo "Rewriting provisioning profile to Enterprise Distribution"
sed 's/PROVISIONING_PROFILE.*=.*".*";/PROVISIONING_PROFILE = "b3858d95-61ba-47c6-88ed-a30319058ad6";/' charlie.xcodeproj/project.pbxproj > charlie.xcodeproj/project.pbxproj.tmp && mv charlie.xcodeproj/project.pbxproj.tmp charlie.xcodeproj/project.pbxproj
