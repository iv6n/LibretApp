"""Verify offline manifest and native ELF alignment in the actual Android bundle."""
import argparse
import json
import struct
import sys
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path


def inspect_bundle(bundle):
    libraries = []
    with zipfile.ZipFile(bundle) as archive:
        for name in archive.namelist():
            if not name.endswith('.so'):
                continue
            data = archive.read(name)
            if data[:4] != b'\x7fELF':
                raise ValueError(f'Invalid ELF: {name}')
            endian = '<' if data[5] == 1 else '>'
            is64 = data[4] == 2
            offset = struct.unpack_from(endian + ('Q' if is64 else 'I'), data, 32 if is64 else 28)[0]
            size, count = struct.unpack_from(endian + 'HH', data, 54 if is64 else 42)
            alignments = []
            for index in range(count):
                header = offset + index * size
                if struct.unpack_from(endian + 'I', data, header)[0] == 1:
                    alignments.append(struct.unpack_from(endian + ('Q' if is64 else 'I'), data, header + (48 if is64 else 28))[0])
            libraries.append({'library': name, 'alignments': alignments,
                              'compatible16kb': bool(alignments) and (not is64 or min(alignments) >= 16384)})
        signed = any(name.startswith('META-INF/') and name.endswith(('.RSA', '.EC', '.DSA'))
                     for name in archive.namelist())
    return libraries, signed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('bundle', type=Path)
    parser.add_argument('--flavor', choices=('offline','connected'), default='offline')
    parser.add_argument('--manifest', type=Path, required=True, help='Merged offline release manifest')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--minimum-version-code', type=int, default=6)
    args = parser.parse_args()
    android = '{http://schemas.android.com/apk/res/android}'
    root = ET.parse(args.manifest).getroot()
    permissions = sorted(node.get(android + 'name') for node in root.findall('uses-permission'))
    forbidden = {'android.permission.INTERNET', 'android.permission.ACCESS_FINE_LOCATION',
                 'android.permission.ACCESS_COARSE_LOCATION', 'android.permission.BLUETOOTH',
                 'android.permission.BLUETOOTH_ADMIN', 'android.permission.BLUETOOTH_CONNECT',
                 'android.permission.BLUETOOTH_SCAN'}
    if args.flavor == 'connected':
        forbidden.remove('android.permission.INTERNET')
    libraries, signed = inspect_bundle(args.bundle)
    checks = {
        'applicationId': root.get('package') == 'app.libret',
        'buildNumberIncreased': int(root.get(android + 'versionCode', '0')) >= args.minimum_version_code,
        'targetApi36': int(root.find('uses-sdk').get(android + 'targetSdkVersion', '0')) >= 36,
        'testedMinimumApi28': int(root.find('uses-sdk').get(android + 'minSdkVersion', '0')) == 28,
        'distributionPermissions': not forbidden.intersection(permissions) and (args.flavor != 'connected' or 'android.permission.INTERNET' in permissions),
        'systemCloudBackupDisabled': root.find('application').get(android + 'allowBackup') == 'false',
        'signaturePresent': signed,
        'native64BitAlignment16kb': bool(libraries) and all(row['compatible16kb'] for row in libraries),
    }
    report = {'bundle': str(args.bundle), 'versionName': root.get(android + 'versionName'),
              'versionCode': root.get(android + 'versionCode'), 'checks': checks,
              'permissions': permissions, 'libraries': libraries,
              'limits': 'Also verify the signature with jarsigner, APK ZIP alignment with zipalign -P 16, and run on a 16 KB device.'}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2), encoding='utf-8')
    for name, result in checks.items():
        print(f'{"PASS" if result else "FAIL"}: {name}')
    return 0 if all(checks.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
