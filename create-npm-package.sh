#!/bin/sh

# TODO: Change `./initialise/config.txt` to __argmap_parse

__resolve_path() {
  if command -v realpath > /dev/null; then
    realpath -m "$@"
  elif command -v readlink > /dev/null; then
    readlink -s "$@"
  else
    echo "No path resolve command found"
    exit 1
  fi
}

package_name="$1"
package_description="$2"
package_parent_folder="${3:-.}"

package_out_folder="$(__resolve_path "${package_parent_folder}/${package_name}")"
mkdir -p "${package_out_folder}"

if test "${package_name}" != "${package_name%%[^-a-z]*}"; then
  echo "Package name '$1' contains invalid characters (non [-a-z])"
  exit 1
fi

cp -r ./npm-package/* "${package_out_folder}"
cat << EOF > "${package_out_folder}/initialise/config.txt"
PACKAGE_NAME=${package_name}
PACKAGE_DESCRIPTION=${package_description}
PACKAGE_SCOPE=nick-bull
GITHUB_USER=nick-bull
AUTHOR_URL=https://bull.dev
AUTHOR_NAME=Nick Bull
AUTHOR_EMAIL=nick@bull.dev
EOF

(
  cd "${package_out_folder}"/initialise
  ./initialise.sh
)

