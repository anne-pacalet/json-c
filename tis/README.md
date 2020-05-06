## Compilation

```
$ git clone https://github.com/json-c/json-c
$ cd json-c
$ PROJECT_ROOT=$PWD
$ mkdir tis && cd tis
$ mkdir build && cd build
$ cmake ../.. -DCMAKE_EXPORT_COMPILE_COMMANDS=On
$ sed -i config.h -e '/HAVE_XLOCALE_H/d' \
                  -e '/HAVE_USELOCALE/d'
$ make
$ make USE_VALGRIND=0 test
```


## Preparation

```
$ tis-prepare all-symbol-table
[INFO] Summary: 2+38/40 (100%) [OK+CACHED]   0/40 (0%) [SKIPPED]   0/40 (0%) [FAIL]
$ tis-prepare clean
```

To be able to use the `compile_commands.json` on GitHub,
the absolute paths have to be transformed into relative ones:

```
$ sed -i compile_commands.json -e "s=$PROJECT_ROOT=../..=g" \
                               -e '/"directory"/s/.*/  "directory": ".",/'
```

Now for each `test_XXX` test in `$PROJECT_ROOT/test/*.expected`,
write a `test_XXX.config` file and generate `test_XXX.config_generated`:

```
$ cd $PROJECT_ROOT/tis
$ tis-prepare tis-config test_XXX.config -- --interpreter
$ tis-analyzer -tis-config-load test_XXX.config_generated --interpreter
```

## Tests

Now a `tis.config` file can be added in `$PROJECT_ROOT`
that include all the `test_XXX.config_generated`.
One test can be run with:

```
$ cd $PROJECT_ROOT
$ git clean -fxd
$ tis-analyzer --interpreter
               -tis-config-load tis.config -tis-config-select-by-name test_XXX
```

Some tests requires `TIS_ADVANCED_FLOAT=1`:
- `test_cast`
- `test_parse`
- `test_set_value`

Even with `TIS_ADVANCED_FLOAT=1`, some tests stop because they need
`__builtin_isnan`:
- `test_double_serializer`
- `test_float`
- `test_parse`

### Fixes

- TAAS-426: should always set `TIS_ADVANCED_FLOAT=1`.
- PR-3760: define `tis_nan`.
- should be add `bsearch` in our libc (in `tis_stubs.c` at the meoment).
- `__builtin_isnan` is also in `tis_stubs.c`. Fixed by PR-3760?

- default machdep problem that was not gcc (fixed in PR-3755).

## Check

The `$PROJECT_ROOT/tests/test_XXX.expected` files provide
the expected outut on stdout.

*TODO*: would be better to directly get stdout from `tis_printf`
using a new option to set `Builtins_lib_tis_printf.set_output_formatter`
as the GUI does.

### Fixes

- TRUS-2099: wrong result on `tis_strtoull_interpreter("-0")`
- TRUS-2098: erro was not set by strtod builtin. DONE

## Script run.sh

The `run.sh` script makes it easier to repeat all the steps:

```
$ cd $PROJECT_ROOT/tis
$ rm *.config_generated
$ ./run.sh
```

## Coverage

```
$ tis-analyzer -tis-config-load empty.config \
               -save empty.state -info-csv-all empty > empty.log
$ tis-aggregate coverage json-c.aggreg > json-c.coverage
```
