#!/usr/bin/bash
# Minify images using TinyPNG

API_KEY=`cat "$(dirname $0)"/api.key`
API_URL=https://api.tinify.com/shrink

# directory to save minified files
output_dir=
# files to minify
files=()

show_help() {
  echo -e \
"Minify images using TinyPNG. Replace original files by default.
Support only png, jpg.
Usage: ./minify_image.sh [option] [file/directory]...
Options:
    -o [Output Dir]      save minified images in the specified directory
    -h, --help           display this help and exit
"
}

# parse and check output directory. Create if necessary
parse_output_dir() {
  if [[ "$1" = '-o' ]]; then
    # make sure end with '/'
    output_dir=${2%/}/
    if [[ -e "$output_dir" ]]; then
      if [[ ! -d "$output_dir" ]]; then
        echo "Error: $output_dir is not a directory"
        exit 1
      elif [[ ! -w "$output_dir" ]]; then
        echo "Error: $output_dir is not writable"
        exit 1
      fi
    else
      mkdir "$output_dir" || exit 1
    fi
  fi
}

# parse files and directory to an array of file. Exit if file or directory not exist
parse_files() {
  start=0
  if [[ -n "$output_dir" ]]; then
    start=2
  fi

  args=("$@")
  for (( i = $start; i <= $#; i++ )); do
    path=${args[$i]}
    if [[ -f "$path" ]]; then
      files+=($path)
    elif [[ -d "$path" ]]; then
      for file in "`find \"$path\" -type f -regex '.*\.\(png\|jpg\)'`"; do
        if [[ -n "$file" ]]; then
          files+=("$file")
        fi
      done
    fi
  done
}

# minify one image
minify_image() {
  local file=$1
  local response=`curl $API_URL -s --user api:$API_KEY --data-binary @"$file"`
  if [[ "$response" = *"\"error\""* ]]; then
    message=`echo "$response" | sed 's#.*"message":"\([^"]*\)".*#\1#'`
    if [[ -n "$message" ]]; then
      echo "$file: $message"
    else
      echo "$file: $response"
    fi
  else
    local url=`echo "$response" | sed 's#.*"url":"\([^"]*\)".*#\1#'`
    if [[ -n "$output_dir" ]]; then
      local output_path="$output_dir$file"
      local dir=`dirname $output_path`
      if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
      fi
    else
      local output_path=$file
    fi
    curl $url -sSo "$output_path" --user api:$API_KEY
    if [[ "$?" = "0" ]]; then
      echo "$file: success"
    else
      echo "$file: failed to download file"
    fi
  fi
}

if [[ "$#" = "0" || "$1" = "--help" || "$1" = "-h" ]]; then
  show_help
  exit
elif [[ -e "$API_KEY" ]]; then
  echo "An api key is needed"
fi

parse_output_dir $@
parse_files $@

export API_KEY
export API_URL
export output_dir
export -f minify_image

if [[ "${#files[@]}" -lt "1" ]]; then
  echo "No file to minify"
else
  echo ${files[@]} | xargs -r -n1 -P10 bash -c 'minify_image "$@"' _{}
fi
