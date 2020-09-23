#!/bin/bash
## Help Info
function fPrintHelp()
{
    echo "Usage: build-pkg.sh -v VERSION" 2>&1
    echo "Builds a macOS Installer Package containing the Trigger-EUI resources for deployment."
    echo "See README.md for details."
    echo ""
    echo "     -v VERSION     (Required) Specify a package version. An integer is best."
    echo "     -h             Print this help message. So helpful!"
    exit 1
}

##Sanity Check: Make sure Git is committed!
if [[ -n "$(git status --porcelain)" ]]; then
  echo >&2
  echo "Error: You have uncommitted changes. Please commit or revert them before proceeding." >&2
  echo >&2
  exit 1
fi

# Process build arguments. You can set a default Version here, if you'd like.
VERSION=""
while getopts “:vh” opt; do
  case $opt in
    v)
        VERSION=${OPTARG}
    ;;
    h)
        fPrintHelp
    ;;
    ?)
        echo "Invalid option: -${OPTARG}."
        echo
        fPrintHelp
  esac
done

## Sanity Check - they gave us a version, right?
if [[ "$VERSION" == "" ]] 
then
    echo >&2
  echo "Error: A Version string must be specified with -v. Run with -h for more info." >&2
  echo >&2
  exit 1
fi


## Do the thing

printf "Building Trigger-EUI Resource Bin Package (Package Version: $VERSION)"
echo "------------------------------------------------------------------------------"
printf "\n"

# Fail early, talk often. https://www.peterbe.com/plog/set-ex
set -ex

# Build the site
yarn build
# Now export the static version to the build dir
next export -o build
# Add a version file
echo "$VERSION" > build/version

# Now we have our files. Package them.
packagesbuild TriggerEuiResourceBin.pkgproj -v
mv build/TriggerEuiResourceBin.pkg build/TriggerEuiResourceBin-R"$VERSION".pkg

echo "Done!"