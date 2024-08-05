#!/usr/bin/bash

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
RES_DIR=$THIS_DIR/results

CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

# Create results directory if it doesn't exist
mkdir -p $RES_DIR

BIND0="numactl --cpunodebind=0 --membind=0"

# Source the benchmarks configuration
source $THIS_DIR/unixbench_config.sh

# Native execution
export UB_BINDIR=$THIS_DIR/pgms
make clean && make

# Loop over the benchmarks and execute them
for benchmark in "${!BENCHMARK_COMMANDS[@]}"; do
    command=${BENCHMARK_COMMANDS[$benchmark]}
    repeats=${BENCHMARK_REPEATS[$benchmark]}
    
    for ((i = 1; i <= repeats; i++)); do
        result_file="$RES_DIR/native_${benchmark}_${i}.log"
        echo "Native --- Running benchmark: $benchmark with parameters: $command"
        $BIND0 $PROG_DIR/$command > $result_file 2>&1
        echo "Saved results in $result_file"
    done
done

# Gramine-SGX execution
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1

# Loop over the benchmarks and execute them
for benchmark in "${!BENCHMARK_COMMANDS[@]}"; do
    command=${BENCHMARK_COMMANDS[$benchmark]}
    repeats=${BENCHMARK_REPEATS[$benchmark]}
    
    for ((i = 1; i <= repeats; i++)); do
        result_file="$RES_DIR/gramine-sgx_${benchmark}_${i}.log"
        echo "Gramine SGX --- Running benchmark: $benchmark with parameters: $command"
        $BIND0 gramine-sgx $command > $result_file 2>&1
        echo "Saved results in $result_file"
    done
done

# Gramine-VM execution
TIMEOUT=120
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make

# Loop over the benchmarks and execute them
for benchmark in "${!BENCHMARK_COMMANDS[@]}"; do
    command=${BENCHMARK_COMMANDS[$benchmark]}
    repeats=${BENCHMARK_REPEATS[$benchmark]}
    
    for ((i = 1; i <= repeats; i++)); do
        result_file="$RES_DIR/gramine-vm_${benchmark}_${i}.log"
        echo "Gramine VM --- Running benchmark: $benchmark with parameters: $command"
        $BIND0 gramine-vm $command > $result_file 2>&1 & PID=$!
        
        sleep $TIMEOUT
        # Check if the process is still running
        if kill -0 $PID 2>/dev/null; then
            # Process is still running, send SIGINT
            kill -INT $PID
            # Wait a bit to see if the process terminates gracefully
            sleep 1
            # If it's still running, force kill
            if kill -0 $PID 2>/dev/null; then
                kill -KILL $PID
                echo "gramine-vm $command did not terminate, sent SIGKILL"
            fi
        fi
        # Wait for the process to finish and get its exit status
        wait $PID

        echo "Saved results in $result_file"
    done
done

# Gramine-TDX execution
TIMEOUT=120
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1

# Loop over the benchmarks and execute them
for benchmark in "${!BENCHMARK_COMMANDS[@]}"; do
    command=${BENCHMARK_COMMANDS[$benchmark]}
    repeats=${BENCHMARK_REPEATS[$benchmark]}
    
    for ((i = 1; i <= repeats; i++)); do
        result_file="$RES_DIR/gramine-tdx_${benchmark}_${i}.log"
        echo "Gramine TDX --- Running benchmark: $benchmark with parameters: $command"
        $BIND0 gramine-tdx $command > $result_file 2>&1 & PID=$!
        
        sleep $TIMEOUT
        # Check if the process is still running
        if kill -0 $PID 2>/dev/null; then
            # Process is still running, send SIGINT
            kill -INT $PID
            # Wait a bit to see if the process terminates gracefully
            sleep 1
            # If it's still running, force kill
            if kill -0 $PID 2>/dev/null; then
                kill -KILL $PID
                echo "gramine-tdx $command did not terminate, sent SIGKILL"
            fi
        fi
        # Wait for the process to finish and get its exit status
        wait $PID

        echo "Saved results in $result_file"
    done
done
