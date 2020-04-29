```
$ git clone https://github.com/json-c/json-c
$ cd json-c
$ PROJECT_ROOT=$PWD
$ mkdir tis && cd tis
$ mkdir build && cd build
$ VALGRIND=1 cmake ../.. -DCMAKE_EXPORT_COMPILE_COMMANDS=On
$ sed -i config.h -e '/HAVE_XLOCALE_H/d' \
                  -e '/HAVE_USELOCALE/d'
$ make
$ make USE_VALGRIND=0 test
```

```
$ tis-prepare all-symbol-table
[INFO] Summary: 2+38/40 (100%) [OK+CACHED]   0/40 (0%) [SKIPPED]   0/40 (0%) [FAIL]
```

$ sed -i compile_commands.json -e "s=$PROJECT_ROOT=../..=g" \
                               -e '/"directory"/s/.*/  "directory": ".",/'

```
$ cd $PROJECT_ROOT/tis
$ tis-prepare tis-config test1.config -- --interpreter
$ tis-analyzer -tis-config-load test1.config_generated \
               -tis-config-select 1 \
               --interpreter
```

```
$ cd $PROJECT_ROOT
$ git clean -fxd
$ tis-analyzer -tis-config-load tis.config -tis-config-select 1 --interpreter
```

Some tests requires `TIS_ADVANCED_FLOAT=1`:
- `test_cast`
