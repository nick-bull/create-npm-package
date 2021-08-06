#!/bin/sh

__path_resolve() ( # Execute the function in a subshell to localize side effects.
  target=$1 fname= targetDir= CDPATH=

  { \unalias command; \unset -f command; } >/dev/null 2>&1

  # make zsh find *builtins* with `command` too.
  test -n "$ZSH_VERSION" && options[POSIX_BUILTINS]=on 

  while :; do # Resolve potential symlinks until the ultimate target is found.
      if ! test -L "$target" && ! test -e "$target"; then 
        command printf '%s\n' "ERROR: '$target' does not     exist." >&2;
        return 1;
      fi

      # Change to target dir; necessary for correct     resolution of target path.
      command cd "$(command dirname -- "$target")"

      fname=$(command basename -- "$target") # Extract filename.
      test "$fname" = '/' && fname='' # !! curiously, `basename /` returns '/'

      if test -L "$fname"; then
        # Extract [next] target path, which may be defined
        # *relative* to the symlink's own directory.
        # Note: We parse `ls -l` output to find the symlink target
        #       which is the only POSIX-compliant, albeit somewhat fragile, way.
        target=$(command ls -l "$fname")
        target=${target#* -> }

        continue
      fi

      break
  done

  targetDir=$(command pwd -P) # Get canonical dir. path
  # Output the ultimate target's canonical path.
  # Note that we manually resolve paths ending in /. and /.. to make sure we have a normalized pa    th.

  if test "$fname" = '.'; then
    command printf '%s\n' "${targetDir%/}"
  elif test "$fname" = '..'; then
    # Caveat: something like /var/.. will resolve to /private (assuming /var@ -> /private/var)
    # AFTER canonicalization.
    command printf '%s\n' "$(command dirname -- "${targetDir}")"
  else
    command printf '%s\n' "${targetDir%/}/$fname"
  fi
)

script_name="$(__path_resolve "$0")"
script_dir="$(dirname "${script_name}")"
package_dir="$(dirname "${script_dir}")"
package_parent_dir="$(dirname "${package_dir}")"

while IFS="" read -r line || [ -n "$line" ]; do
  conf_variable="${line%%=*}"
  conf_value="${line#*=}"

  test "${conf_variable}" = "PACKAGE_NAME" && package_name="${conf_value}"
  test "${conf_variable}" = "PACKAGE_SCOPE" && package_scope="${conf_value}"
  test "${conf_variable}" = "PACKAGE_DESCRIPTION" && package_description="${conf_value}"
  test "${conf_variable}" = "AUTHOR_USERNAME" && author_username="${conf_value}"

  echo "Replacing '<<${conf_variable}>>' with '${conf_value}'"
  
  find "${package_dir}" -type f \
    -exec sed -i 's|<<'"${conf_variable}"'>>|'"${conf_value}"'|g' {} \;
done < "${script_dir}"/config.txt

new_package_dir="${package_parent_dir}/${package_name}"

cd "${new_package_dir}"
rm -r "${new_package_dir}"/initialise

cat << EOF > "${new_package_dir}/README.md"
${package_description}

## Installation

\`\`\`
npm i @${package_scope}/${package_name}
\`\`\`

## Usage

\`\`\`
import {...} from '${package_scope}/${package_name}'

...
\`\`\`
EOF

npm i

git add .
git commit -m 'Initialised npm package'

git remote add origin git@github.com:"${author_username}"/"${package_name}".git

