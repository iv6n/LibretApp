"""Issue a post-build receipt for the exact, reviewed Play upload bundle.

This does not upload or distribute the AAB. The accepted hash must be supplied
after building; the receipt is invalid if the AAB, source, evidence or Console
version code changes.
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from build_android_candidate import source_digest, validate_store
from verify_offline_release import inspect_bundle


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def json_sha256(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def validate_receipt_inputs(candidate, inspection, metadata, evidence,
                            accepted_hash, last_play_code, current_source):
    if candidate.get('mode') != 'store' or candidate.get('flavor') != 'offline':
        raise ValueError('Solo se acepta un AAB offline firmado para tienda.')
    if candidate.get('readyForStore') is not False:
        raise ValueError('El candidato debe estar pendiente antes de la constancia.')
    if not isinstance(accepted_hash, str) or len(accepted_hash) != 64 or any(
            char not in '0123456789abcdef' for char in accepted_hash.lower()):
        raise ValueError('Indica el SHA-256 completo del AAB ya generado.')
    if candidate.get('bundleSha256') != accepted_hash.lower():
        raise ValueError('El hash aceptado no corresponde al candidato.')
    if candidate.get('sourceSha256') != current_source:
        raise ValueError('El código cambió desde la compilación.')
    if candidate.get('metadataSha256') != json_sha256(metadata):
        raise ValueError('Los metadatos cambiaron desde la compilación.')
    validate_store(metadata, evidence, current_source, last_play_code)
    try:
        version_code = int(inspection['versionCode'])
        candidate_code = int(candidate['version'].rsplit('+', 1)[1])
    except (KeyError, ValueError, IndexError) as error:
        raise ValueError('Falta el código de versión verificado.') from error
    if version_code != candidate_code or version_code <= max(20, last_play_code):
        raise ValueError('El código debe superar al local 20 y al de Console.')
    if not inspection.get('checks') or not all(
            value is True for value in inspection['checks'].values()):
        raise ValueError('La inspección del AAB tiene comprobaciones pendientes.')
    required = {'applicationId', 'buildNumberIncreased', 'targetApi36',
                'testedMinimumApi28', 'distributionPermissions',
                'systemCloudBackupDisabled', 'signaturePresent',
                'native64BitAlignment16kb'}
    if not required.issubset(inspection['checks']):
        raise ValueError('La inspección del AAB está incompleta.')
    return version_code


def verify_candidate_files(candidate_path, candidate, inspection_path, inspection):
    directory = candidate_path.resolve().parent
    bundle = Path(candidate['bundle']).resolve()
    if bundle.parent != directory or bundle.suffix != '.aab':
        raise ValueError('El AAB debe estar junto al informe del candidato.')
    if sha256(bundle) != candidate.get('bundleSha256'):
        raise ValueError('El AAB cambió después de compilarse.')
    if sha256(inspection_path) != candidate.get('inspectionSha256'):
        raise ValueError('La inspección cambió después de compilarse.')
    if Path(inspection['bundle']).resolve() != bundle:
        raise ValueError('La inspección corresponde a otro AAB.')
    return bundle


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--metadata', type=Path, required=True)
    parser.add_argument('--evidence', type=Path, required=True)
    parser.add_argument('--last-play-code', type=int, required=True)
    parser.add_argument('--accepted-sha256', required=True)
    args = parser.parse_args()
    candidate_path = args.candidate.resolve()
    directory = candidate_path.parent
    candidate = json.loads(candidate_path.read_text(encoding='utf-8'))
    inspection_path = directory / 'bundle-inspection.json'
    inspection = json.loads(inspection_path.read_text(encoding='utf-8'))
    metadata = json.loads(args.metadata.read_text(encoding='utf-8'))
    evidence = json.loads(args.evidence.read_text(encoding='utf-8'))
    bundle = verify_candidate_files(candidate_path, candidate,
                                    inspection_path, inspection)
    bundle_hash = sha256(bundle)
    version_code = validate_receipt_inputs(candidate, inspection, metadata,
        evidence, args.accepted_sha256, args.last_play_code, source_digest())
    libraries, signed = inspect_bundle(bundle)
    if not signed or not libraries or not all(row['compatible16kb'] for row in libraries):
        raise ValueError('Firma o alineación nativa inválida.')
    jarsigner = shutil.which('jarsigner')
    if not jarsigner and os.environ.get('JAVA_HOME'):
        jarsigner = str(Path(os.environ['JAVA_HOME']) / 'bin' /
            ('jarsigner.exe' if os.name == 'nt' else 'jarsigner'))
    if not jarsigner:
        raise ValueError('Java con jarsigner es necesario para verificar la firma.')
    subprocess.run([jarsigner, '-verify', str(bundle)], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    receipt = {
        'readyForStore': True, 'bundleSha256': bundle_hash,
        'sourceSha256': candidate['sourceSha256'],
        'inspectionSha256': candidate['inspectionSha256'],
        'evidenceSha256': sha256(args.evidence),
        'metadataSha256': sha256(args.metadata),
        'lastPlayCode': args.last_play_code, 'versionCode': version_code,
        'acceptedAt': datetime.now(timezone.utc).isoformat(),
        'scope': 'Exact AAB for manual review; no Play upload performed.',
    }
    destination = directory / 'acceptance-receipt.json'
    destination.write_text(json.dumps(receipt, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(receipt, indent=2))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (KeyError, OSError, ValueError, subprocess.CalledProcessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
