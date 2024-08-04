#!/bin/bash

THIS_DIR=$(dirname "$(readlink -f "$0")")
PROG_DIR=$THIS_DIR/pgms
TEST_DIR=$THIS_DIR/testdir
TMP_DIR=$THIS_DIR/tmp

# Define the number of repeats
LONG_REPEATS=10
SHORT_REPEATS=3

# Define the compatible benchmarks with their parameters
declare -A BENCHMARK_COMMANDS
BENCHMARK_COMMANDS=(
    ["arithoh"]="arithoh 10"                                      # 10 seconds, long repeats
    ["short"]="short 10"                                          # 10 seconds, long repeats
    ["int"]="int 10"                                              # 10 seconds, long repeats
    ["long"]="long 10"                                            # 10 seconds, long repeats
    ["float"]="float 10"                                          # 10 seconds, long repeats
    ["double"]="double 10"                                        # 10 seconds, long repeats
    ["whetstone-double"]="whetstone-double"                       # no params,  long repeats
    ["execl"]="execl 30"                                          # 30 seconds, short repeats
    ["fstime"]="fstime -c -t 30 -d ${TMP_DIR} -b 1024 -m 2000"    # def params, short repeats
    ["pipe"]="pipe 10"                                            # 10 seconds, long repeats
    ["syscall"]="syscall 10"                                      # 10 seconds, long repeats
    ["dhry2reg"]="dhry2reg 10"                                    # 10 seconds, long repeats
    ["hanoi"]="hanoi 20"                                          # 20 seconds, short repeats
    ["fsbuffer"]="fstime -c -t 30 -d ${TMP_DIR} -b 256 -m 500"    # def params, short repeats
    ["fsdisk"]="fstime -c -t 30 -d ${TMP_DIR} -b 4096 -m 8000"    # def params, short repeats
)
# "context1"  : does not work because of process creation
# "spawn"     : does not work because of process creation
# "sysexec"   : does not work because of process creation
# "shell1"    : does not work because of process creation
# "shell4"    : does not work because of process creation
# "shell8"    : does not work because of process creation
# "grep"    : does not work because of process creation

# Define the number of repeats for each benchmark
declare -A BENCHMARK_REPEATS
BENCHMARK_REPEATS=(
    ["arithoh"]=$LONG_REPEATS
    ["short"]=$LONG_REPEATS
    ["int"]=$LONG_REPEATS
    ["long"]=$LONG_REPEATS
    ["float"]=$LONG_REPEATS
    ["double"]=$LONG_REPEATS
    ["whetstone-double"]=$LONG_REPEATS
    ["execl"]=$SHORT_REPEATS
    ["fstime"]=$SHORT_REPEATS
    ["pipe"]=$LONG_REPEATS
    ["syscall"]=$LONG_REPEATS
    ["dhry2reg"]=$LONG_REPEATS
    ["hanoi"]=$SHORT_REPEATS
    ["fsbuffer"]=$SHORT_REPEATS
    ["fsdisk"]=$SHORT_REPEATS
)
