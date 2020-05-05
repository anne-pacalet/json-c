#!/bin/bash

do_prepare=0
do_run=0
do_filter=1
do_diff=1

files=""
while [[ $# -gt 0 ]] ; do
  case "$1" in
    *)
      name="$1"
      if [ -f "$name.config" ] ; then
        files+=" $name.config"
        shift
      else
        echo "ERROR: file not found $name.config"
        exit 1
      fi
      ;;
  esac
done
if [ -z "$files" ] ; then
  files=$(ls *.config)
fi

for c in $files ; do
  name="${c/.config}"
  echo "Process $name"
  if [[ $do_prepare -ne 0 || ! -f ${c}_generated ]] ; then
    echo -n "  prepare..."
    out=$(TIS_ADVANCED_FLOAT=1 tis-prepare --no-color tis-config "$c" \
      -- --interpreter)
    ok='Successfully completed'
    if [[ ! ( "$out" =~ $ok ) ]] ; then
      echo "Failed to compute ${c}_generated"
      exit 1
    fi
    echo "ok."
    rm -f "$name.log"
  fi
  if [[ $do_run -ne 0 || ! -f "$name.state" || ! -f "$name.log" ]]; then
    echo -n "  analyze..."
    TIS_ADVANCED_FLOAT=1 tis-analyzer \
      -tis-config-load ../tis.config -tis-config-select-by-name "$name" \
      --interpreter -save "$name.state" > "$name.log"
    echo "ok."
    rm -f "$name.res"
  fi
  if [[ $do_filter -ne 0 || ! -f "$name.res" ]] ; then
    echo -n "  filter..."
    awk -f <(cat - <<-'END'
	/^\[value]/ { next; }
	/^\[kernel]/ { next; }
	/^\[tis-mkfs]/ { next; }
	/Too many arguments/,/ *main$/ { next; }
	/but format indicates/,/ *main$/ { next; }
	/register_new_file_in_dirent_niy/,/ *main$/ { next; }
	/initialization of volatile variable/ { next; }
	/integer overflow/ { next; }
	/overflow or underflow/ { next; }
	/invalid return value from json_c_visit/ {
           /* this is printed on stderr so not in .expected */
           next ;
           }
	/\[time]/ { printf "\n"; exit}
	/^$/ { c++ ; next; }
	{ if (c == 0) printf "\n";
          if (c >= 2) {
            for ( ; c >= 2; c -= 2) printf "\n";
            if (c == 1) printf "\n";
          }
          c = 0; printf ("%s", $0);
        }
END
    ) < "$name.log" > "$name.res"
    echo "ok."
    rm -f "$name.diff"
  fi
  if [[ $do_diff -ne 0 || ! -f "$name.diff" ]] ; then
    echo -n "  diff..."
    if [ -f "$name.todo" ] ; then
      # some differences with the expected file to be fixed
      oracle="$name.todo"
    elif [ -f "$name.oracle" ] ; then
      # some differences with the expected file but they are acceptable
      oracle="$name.oracle"
    else
      oracle="../tests/$name.expected"
    fi
    if diff "$oracle" "$name.res" > "$name.diff" ; then
      echo "ok"
    else
      echo "KO."
      echo "    See with: diff $oracle $name.res"
    fi
  fi
done
