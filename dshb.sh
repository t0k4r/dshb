#!/bin/bash

root_folder=$(pwd)
output_file="dshb.html"
custom_categories=()
open_file=false
sort_entries="no"
html_out=""

help_msg="dshb - directory search html browser
usage: dshb ...(flags)
 dshb -o out.html
 dshb -c scripts,.sh,.py,.js -o scripts.html 
flags:
 -h     help
 -r     root folder(default: $(pwd))
 -o     output file name(default: dshb.html)
 -c     custom category (name and extesions coma separated)
 -x     open file at the end with xdg-open
 -s     sort entries(default: no, values: asc,desc,no)"

html_start='<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
<style>
  img {
    height: 50px;
    width: 50px;
  }
table, th, td {
  border: 1px solid;
}
</style>

</head>
<body>'
html_end="</body>
</html>"

photos(){
  title="Photos"
  extensions=("png" "jpg" "jpeg" "webp")
  html_build="<h2>$title</h2><table><tr><td>name</td><td>date</td><td>path</td><td>preview</td></tr>"
  found=()
  for ext in "${extensions[@]}";do
    while read file; do
      found+=("$file")
    done < <(find "$root_folder" -type f -iname "*.$ext" -printf "%f\t%t\t%p\n")
  done
  if [ "$sort_entries" = "asc" ]; then
    IFS=$'\n' found=($(sort -f <<<"${found[*]}"))
  elif [ "$sort_entries" = "desc" ]; then
    IFS=$'\n' found=($(sort -f -r <<<"${found[*]}"))
  fi

  for file in "${found[@]}"; do
    IFS=$'\t' read -a line <<< "$file"
    html_build+="<tr><td>${line[0]}</td><td>${line[1]}</td><td><a href=file://${line[2]}>${line[2]}</a></td><td><img src=${line[2]}></td></tr>"
  done
  html_build+="</table>"
  html_out+=$html_build
}



custom(){
  IFS=',' read -a array <<< "$1"
  title="custom"
  extensions=()
  for i in "${!array[@]}"; do
    if [ "$i" = "0" ]; then
      title="${array[i]}"
    else
      extensions+=("${array[$i]}")
    fi
  done

  html_build="<h2>$title</h2><table><tr><td>name</td><td>date</td><td>path</td></tr>"
  found=()
  for ext in "${extensions[@]}";do
    while read file; do
      found+=("$file")
    done < <(find "$root_folder" -type f -iname "*.$ext" -printf "%f\t%t\t%p\n")
  done
  if [ "$sort_entries" = "asc" ]; then
    IFS=$'\n' found=($(sort -f <<<"${found[*]}"))
  elif [ "$sort_entries" = "desc" ]; then
    IFS=$'\n' found=($(sort -f -r <<<"${found[*]}"))
  fi

  for file in "${found[@]}"; do
    IFS=$'\t' read -a line <<< "$file"
    html_build+="<tr><td>${line[0]}</td><td>${line[1]}</td><td><a href=file://${line[2]}>${line[2]}</a></td></tr>"
  done
  html_build+="</table>"
  html_out+=$html_build
}

docsmusic(){
custom "Documents & Music,mp3,mp4,ogg,opus,wav,flac,webm,docx,doc,odt,pdf,md"
}

while getopts ":r:o:c:xs:h" opt; do
  case ${opt} in
    r )
      root_folder="$OPTARG"
      ;;
    o )
      output_file="$OPTARG"
      ;;
    c )
      custom_categories+=("$OPTARG")
      ;;
    x )
      open_file=true
      ;;
    s )
      sort_entries="$OPTARG"
      ;;
    h )
      echo "$help_msg"
      exit 
      ;;
    \? )
      echo "unknown: $OPTARG"
      exit 
      ;;
  esac
done

html_out+=$html_start
photos
docsmusic
for categ in "${custom_categories[@]}"; do
  custom $categ
done
html_out+=$html_end

echo $html_out > $output_file
if $open_file; then
  xdg-open $output_file
fi

