"""Capture and interact with the dedicated Android pilot emulator via accessibility."""
import argparse
import json
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from pathlib import Path


def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--adb', required=True)
    parser.add_argument('--device', default='emulator-5554')
    parser.add_argument('--package', help='Require this app to be foreground before reading or tapping')
    parser.add_argument('--tap', action='append', help='Exact accessible text or description; repeat for sequential taps')
    parser.add_argument('--capture', required=True)
    parser.add_argument('--out', type=Path, default=Path('artifacts/directorio/android'))
    args = parser.parse_args()
    prefix = [args.adb, '-s', args.device]

    def run(*command):
        return subprocess.run(prefix + list(command), capture_output=True, check=True).stdout

    def require_package():
        if not args.package:
            return
        activities = run('shell', 'dumpsys', 'activity', 'activities').decode('utf-8', errors='replace')
        resumed = [line for line in activities.splitlines() if 'mResumedActivity:' in line]
        if not any(re.search(r'\b' + re.escape(args.package) + r'/', line) for line in resumed):
            raise RuntimeError(f'Expected {args.package} in the foreground; no capture or tap performed')

    def tree():
        require_package()
        run('shell', 'uiautomator', 'dump', '/sdcard/libret-ui.xml')
        return run('shell', 'cat', '/sdcard/libret-ui.xml')

    for target in args.tap or []:
        root = ET.fromstring(tree())
        matches = [node for node in root.iter('node') if target in (node.get('text'), node.get('content-desc')) or (node.get('content-desc') or '').split('\n')[0] == target]
        matches = list({node.get('bounds'): node for node in matches}.values())
        if len(matches) != 1:
            raise ValueError(f'Expected one accessible match for {target}, found {len(matches)}')
        x1, y1, x2, y2 = map(int, re.findall(r'\d+', matches[0].get('bounds')))
        require_package()
        run('shell', 'input', 'tap', str((x1 + x2) // 2), str((y1 + y2) // 2))
        time.sleep(1)
    args.out.mkdir(parents=True, exist_ok=True)
    data = tree()
    require_package()
    (args.out / f'{args.capture}.xml').write_bytes(data)
    (args.out / f'{args.capture}.png').write_bytes(run('exec-out', 'screencap', '-p'))
    root = ET.fromstring(data)
    print(json.dumps([{'text': node.get('text') or node.get('content-desc'), 'bounds': node.get('bounds')}
                      for node in root.iter('node') if node.get('text') or node.get('content-desc')], ensure_ascii=False))


if __name__ == '__main__':
    main()
