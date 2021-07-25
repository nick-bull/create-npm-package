#!/bin/sh

# TODO: Change `./initialise/config.txt` to __argmap_parse

package_name="$1"
package_description="$2"

if test "${package_name}" != "${package_name%%[^-a-z]*}"; then
  echo "Package name '$1' contains invalid characters (non [-a-z])"
  exit 1
fi

cp -r ./npm-package ./"${package_name}"
cat << EOF > ./"${package_name}/initialise/config.txt"
PACKAGE_NAME=${package_name}
PACKAGE_DESCRIPTION=${package_description}
PACKAGE_SCOPE=nick-bull
GITHUB_USER=nick-bull
AUTHOR_URL=https://bull.dev
AUTHOR_NAME=Nick Bull
AUTHOR_EMAIL=nick@bull.dev
EOF

(
  cd ./"${package_name}"/initialise
  ./initialise.sh
)
