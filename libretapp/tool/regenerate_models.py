"""Regenerate Isar models while preserving the separately maintained Drift file.

Do not filter build_runner output: the build graph can remove other generated
models. Drift's generator is intentionally absent from this Isar build graph.
"""
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DRIFT = ROOT / 'lib/core/persistence/drift_feature_database.g.dart'


def main():
    if not DRIFT.is_file():
        raise RuntimeError('Restore the tracked Drift generated file before regeneration.')
    preserved = DRIFT.read_bytes()
    try:
        result = subprocess.run(
            [shutil.which('dart') or 'dart', 'run', 'build_runner', 'build'],
            cwd=ROOT, check=False)
        return result.returncode
    finally:
        DRIFT.write_bytes(preserved)


if __name__ == '__main__':
    raise SystemExit(main())
