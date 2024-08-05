# README for the experiments 

## Benchmark execution

### TLDR;
To execute the benchmarks:
1. Make sure you have `gramine-tdx` and `gramine-sgx` installed.
2. Adapt the paths of the [`run_unixbench_with_gramine.sh`](./run_unixbench_with_gramine.sh) script.
3. Run:
```
$ ./run_unixbench_with_gramine.sh
```
4. Get the average of the runs:
```
$ python3 gather_results.py ./results
```
5. Pretty-print the results (requires python's `prettytable` -- you can get it via `pip install prettytable` or `sudo apt install python3-prettytable`):
```
$ python3 prettyprint_results.py
```

### Adaptations & description of files

We design a script ([`run_unixbench_with_gramine.sh`](./run_unixbench_with_gramine.sh)) that orchestrates the execution of the available benchmarks for `gramine-vm` and `gramine-tdx`. 

In other words, it executes the benchmarks that do not required `fork` with their default settings.

The parameters of each benchmarks are set in [`unixbench_config.sh`](./unixbench_config.sh) which is sourced in the beginning.

We assume that this project is in a system where both `gramine-sgx` and `gramine-tdx` have been compiled in predefined directories.
The respective paths are set in the [`run_unixbench_with_gramine.sh`](./run_unixbench_with_gramine.sh) script. Feel free to adapt accordingly.

For ease of use, we enhance the [`Makefile`](./Makefile) to also consider the `manifest` for `gramine`.
The [manifest template](./unixbench.manifest.template) is provided with a default configuration to comply with the requirements of the benchmarks.

To compile the benchmark with `Gramine-SGX/TDX` support, simply run:
```
$ make SGX=1
```

## Results analysis
We provide 2 scripts for results analysis and pretty-printing:
1. [`gather_results.py`](./gather_results.py): takes as an argument the directory that contains the results (e.g., `./results`) and calculates the average among the runs for each variant and benchmark.
2. [`prettyprint_results.py`](./prettyprint_results.py): takes as an argument the directory that contains the **averaged** results (e.g., `./results`) from the previous step and pretty-prints 2 tables, 1 with the absolute scores and 1 with the relative percentage difference.
