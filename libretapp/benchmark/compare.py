#!/usr/bin/env python3
"""Diff two bench_runner JSON result files.

    python benchmark/compare.py benchmark/results/before.json benchmark/results/after.json
"""
import json, sys


def load(path):
    data = json.loads(open(path, encoding='utf-8').read())
    return {(r['name'], r['scale']): r for r in data['results']}


def main():
    before, after = load(sys.argv[1]), load(sys.argv[2])
    name_w = max((len(n) for n, _ in before | after.keys()), default=40)

    print(f'{"benchmark".ljust(name_w)}  {"before":>10} {"after":>10} {"change":>9}')
    print('-' * (name_w + 34))

    for key in before:
        if key not in after:
            continue
        b, a = before[key]['median_us'], after[key]['median_us']
        delta = (a - b) / b * 100 if b else 0
        arrow = 'faster' if delta < 0 else 'slower'
        print(
            f'{key[0].ljust(name_w)}  {b/1000:8.2f}ms {a/1000:8.2f}ms '
            f'{abs(delta):7.1f}% {arrow}'
        )


if __name__ == '__main__':
    main()
