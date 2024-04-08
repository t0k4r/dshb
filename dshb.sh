#!/usr/bin/env bash

# katalog HTML projekt

help_msg="dshb - directory search html browser
usage: dshb ...(flags)
 dshb -o=out.html
 dshb -n -c=scripts,.sh,.py -o=scripts.html 
flags:
 -r     root folder(default: $(pwd))
 -o     output file name(default: dshb.html)
 -c     custom category (name and extesions coma separated)
 -n     disable default categories
 -x     open file at the end with xdg-open
 -s     sort entries(default: no, values: asc,desc,no)"

find_tmpl="find --help"

help() {
    echo "$help_msg"
}
main() {
    help
}

main


