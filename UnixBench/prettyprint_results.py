import os
import sys
from collections import defaultdict
from prettytable import PrettyTable

# Define the specific order of variants
VARIANT_ORDER = ['native', 'gramine-sgx', 'gramine-vm', 'gramine-tdx']

# Define a dictionary for renaming benchmarks
RENAME_BENCHMARKS = {
    "dhry2reg": "Dhrystone 2 using register variables",
    "whetstone-double": "Double-Precision Whetstone",
    "syscall": "System Call Overhead",
    "context1": "Pipe-based Context Switching",
    "pipe": "Pipe Throughput",
    "spawn": "Process Creation",
    "execl": "Execl Throughput",
    "execl": "Execl Throughput (10 seconds)",
    "fstime-w": "File Write 1024 bufsize 2000 maxblocks",
    "fstime-r": "File Read 1024 bufsize 2000 maxblocks",
    "fstime": "File Copy 1024 bufsize 2000 maxblocks",
    "fsbuffer-w": "File Write 256 bufsize 500 maxblocks",
    "fsbuffer-r": "File Read 256 bufsize 500 maxblocks",
    "fsbuffer": "File Copy 256 bufsize 500 maxblocks",
    "fsdisk-w": "File Write 4096 bufsize 8000 maxblocks",
    "fsdisk-r": "File Read 4096 bufsize 8000 maxblocks",
    "fsdisk": "File Copy 4096 bufsize 8000 maxblocks",
    "shell1": "Shell Scripts (1 concurrent)",
    "shell8": "Shell Scripts (8 concurrent)",
    "shell16": "Shell Scripts (16 concurrent)",
    "2d-rects": "2D graphics: rectangles",
    "2d-lines": "2D graphics: lines",
    "2d-circle": "2D graphics: circles",
    "2d-ellipse": "2D graphics: ellipses",
    "2d-shapes": "2D graphics: polygons",
    "2d-aashapes": "2D graphics: aa polygons",
    "2d-polys": "2D graphics: complex polygons",
    "2d-text": "2D graphics: text",
    "2d-blit": "2D graphics: images and blits",
    "2d-window": "2D graphics: windows",
    "ubgears": "3D graphics: gears",
    "C": "C Compiler Throughput",
    "arithoh": "Arithoh",
    "short": "Arithmetic Test (short)",
    "int": "Arithmetic Test (int)",
    "long": "Arithmetic Test (long)",
    "float": "Arithmetic Test (float)",
    "double": "Arithmetic Test (double)",
    "dc": "Dc: sqrt(2) to 99 decimal places",
    "hanoi": "Recursion Test -- Tower of Hanoi",
    "grep": "Grep a large file (system's grep)",
    "sysexec": "Exec System Call Overhead"
}

def collect_averages(directory):
    # Dictionary to store the averages
    results = defaultdict(lambda: defaultdict(float))

    # Process each file in the directory
    for filename in os.listdir(directory):
        if filename.endswith('_avg'):
            variant, benchmark = filename.rsplit('_', 1)[0].split('_', 1)
            filepath = os.path.join(directory, filename)
            
            with open(filepath, 'r') as file:
                content = file.read().strip()
                lines = content.split('\n')
                for line in lines:
                    if ' ' in line:
                        bench, avg_score = line.split()
                        benchmark = f'{benchmark}_{bench}'
                        avg_score = float(avg_score)
                    else:
                        avg_score = float(line)
                    
                    results[benchmark][variant] = avg_score

    return results

def pretty_print_table(results):
    # Get the list of benchmarks and variants
    benchmarks = sorted(results.keys())
    variants = VARIANT_ORDER

    # Create the table for absolute numbers
    table = PrettyTable()
    table.field_names = ["Benchmark"] + variants

    for benchmark in benchmarks:
        renamed_benchmark = RENAME_BENCHMARKS.get(benchmark, benchmark)
        row = [renamed_benchmark] + [f'{results[benchmark].get(variant, "-"):.3f}' if results[benchmark].get(variant, "-") != "-" else "-" for variant in variants]
        table.add_row(row)

    print("Absolute Numbers:")
    print(table)

def pretty_print_ratio_table(results):
    # Get the list of benchmarks and variants
    benchmarks = sorted(results.keys())
    variants = VARIANT_ORDER

    # Create the table for performance ratios
    table = PrettyTable()
    table.field_names = ["Benchmark"] + variants[1:]  # Skip 'native' for ratio table

    for benchmark in benchmarks:
        if 'native' in results[benchmark]:
            native_score = results[benchmark]['native']
            renamed_benchmark = RENAME_BENCHMARKS.get(benchmark, benchmark)
            row = [renamed_benchmark]
            for variant in variants[1:]:
                score = results[benchmark].get(variant, '-')
                if score == '-':
                    row.append('-')
                else:
                    ratio = score / native_score
                    row.append(f'{ratio:.5f}x')
            table.add_row(row)

    print("Performance Ratios (relative to native):")
    print(table)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python print_benchmarks.py /path/to/benchmark/results")
        sys.exit(1)
    
    directory = sys.argv[1]
    results = collect_averages(directory)
    pretty_print_table(results)
    pretty_print_ratio_table(results)
