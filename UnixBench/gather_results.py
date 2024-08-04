import os
import re
import sys
from collections import defaultdict

def process_benchmark_results(directory):
    # Regular expressions to match the different log formats
    pattern1 = re.compile(r'COUNT\|(\d+)\|1\|lps')
    pattern2 = re.compile(r'Copy done: \d+ in \d+\.\d+, score (\d+)')
    pattern3 = re.compile(r'MWIPS\s+(\d+\.\d+)')

    # Store scores in a dictionary
    scores = defaultdict(lambda: defaultdict(list))

    # Process each file in the directory
    for filename in os.listdir(directory):
        if filename.endswith('.log'):
            variant, benchmark, _ = filename.split('_')
            filepath = os.path.join(directory, filename)
            
            with open(filepath, 'r') as file:
                content = file.read()
                
                if pattern1.search(content):
                    score = int(pattern1.search(content).group(1))
                    scores[variant][benchmark].append(score)
                    
                elif pattern2.search(content):
                    copy_score = int(pattern2.search(content).group(1))
                    scores[variant][benchmark].append(copy_score)
                    
                elif pattern3.search(content):
                    mwips_score = float(pattern3.search(content).group(1))
                    scores[variant][benchmark].append(mwips_score)

    # Write the averages to new files
    for variant, benchmarks in scores.items():
        for benchmark, score_list in benchmarks.items():
            avg_score = sum(score_list) / len(score_list)
            output_filename = f'{variant}_{benchmark}_avg'
            with open(os.path.join(directory, output_filename), 'w') as output_file:
                    output_file.write(f'{avg_score}\n')

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python process_benchmarks.py /path/to/benchmark/results")
        sys.exit(1)
    
    directory = sys.argv[1]
    process_benchmark_results(directory)
