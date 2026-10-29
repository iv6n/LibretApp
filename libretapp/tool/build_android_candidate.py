"""Build an offline Android QA bundle, or a store candidate with verified gates.

Never uploads to Play Console. QA signing never reads the private upload key.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse
from verify_offline_release import inspect_bundle

ROOT = Path(__file__).resolve().parents[1]
GATES = ('suite', 'regressions', 'migrations', 'android_min', 'android_current',
         'android_16kb', 'physical_accessibility', 'permissions_denied',
         'force_stop_recovery', 'performance', 'install_and_upgrade')


def source_digest():
    digest = hashlib.sha256()
    paths = []
    for directory in ('lib', 'assets', 'test', 'integration_test', 'android/app/src', 'tool', 'supabase'):
        paths.extend(p for p in (ROOT / directory).rglob('*') if p.is_file()
                     and not {'__pycache__', 'node_modules', '.git'}.intersection(p.parts)
                     and p.name != 'GeneratedPluginRegistrant.java')
    paths.extend(ROOT / p for p in ('pubspec.yaml', 'pubspec.lock',
        'android/app/build.gradle.kts', 'android/build.gradle.kts',
        'android/settings.gradle.kts', 'android/gradle.properties'))
    for path in sorted(set(paths)):
        if not path.exists():
            continue
        digest.update(path.relative_to(ROOT).as_posix().encode())
        digest.update(b'\0')
        digest.update(path.read_bytes())
    return digest.hexdigest()


def validate_metadata(metadata):
    for key in ('LIBRET_RESPONSIBLE_NAME', 'LIBRET_SUPPORT_EMAIL', 'LIBRET_PRIVACY_URL'):
        value = metadata.get(key, '').strip()
        if len(value) < 4 or re.search(r'placeholder|pendiente|ejemplo|example|ficticio|your.?name|todo|changeme', value, re.I):
            raise ValueError(f'{key}: falta un dato real.')
    email = metadata['LIBRET_SUPPORT_EMAIL']
    if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', email):
        raise ValueError('El correo de soporte no es vÃ¡lido.')
    url = urlparse(metadata['LIBRET_PRIVACY_URL'])
    if url.scheme != 'https' or not url.hostname or url.username or url.password:
        raise ValueError('La privacidad requiere una URL HTTPS pÃºblica.')
    for host in (url.hostname, email.split('@')[-1]):
        if host == 'localhost' or host.endswith(('.test', '.invalid', '.localhost')):
            raise ValueError('Los dominios de prueba no son datos de tienda.')


CONNECTED_GATES = ('sms_flow', 'sms_quotas', 'account_isolation', 'two_phone_restore',
    'backup_interruptions', 'automatic_background', 'automatic_battery_network_reboot',
    'simultaneous_restore', 'account_deletion_app_web', 'deletion_recovery', 'rls_executed',
    'update_certificate', 'billing_validated')


def validate_store(metadata, evidence, digest, last_code, flavor='offline', config_digest=None):
    validate_metadata(metadata)
    if last_code is None or last_code < 0:
        raise ValueError('Indica --last-play-code con el cÃ³digo real de Console (0 si no hay versiones).')
    if evidence.get('sourceSha256') != digest:
        raise ValueError('La evidencia no corresponde al cÃ³digo actual.')
    if flavor == 'connected' and (evidence.get('flavor') != flavor or evidence.get('configurationSha256') != config_digest):
        raise ValueError('La evidencia no corresponde a la configuración connected.')
    gates = GATES + (CONNECTED_GATES if flavor == 'connected' else ())
    pending = [key for key in gates if evidence.get('checks', {}).get(key) is not True]
    if pending:
        raise ValueError('AceptaciÃ³n tÃ©cnica pendiente: ' + ', '.join(pending))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mode', choices=('qa', 'store'), required=True)
    parser.add_argument('--metadata', type=Path)
    parser.add_argument('--flavor', choices=('offline','connected'), default='offline')
    parser.add_argument('--config', type=Path, help='Public Supabase/CAPTCHA configuration; never server credentials')
    parser.add_argument('--evidence', type=Path)
    parser.add_argument('--last-play-code', type=int)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--flutter', default=shutil.which('flutter') or 'flutter')
    parser.add_argument('--validate-only', action='store_true')
    args = parser.parse_args()
    metadata = json.loads(args.metadata.read_text(encoding='utf-8')) if args.metadata else {}
    if set(metadata) - {'LIBRET_RESPONSIBLE_NAME', 'LIBRET_SUPPORT_EMAIL', 'LIBRET_PRIVACY_URL'}:
        raise ValueError('El archivo de metadatos solo debe contener responsable, soporte y privacidad.')
    evidence = json.loads(args.evidence.read_text(encoding='utf-8')) if args.evidence else {}
    config = json.loads(args.config.read_text(encoding='utf-8')) if args.config else {}
    if set(config) - {'SUPABASE_URL','SUPABASE_ANON_KEY','LIBRET_CAPTCHA_URL'}:
        raise ValueError('Solo se permiten URL, clave pública Supabase y URL CAPTCHA.')
    key = config.get('SUPABASE_ANON_KEY', '')
    if key.startswith('sb_secret_'):
        raise ValueError('No se permiten secretos de servidor en la app.')
    if key.count('.') == 2:
        import base64
        payload = json.loads(base64.urlsafe_b64decode(key.split('.')[1] + '==='))
        if payload.get('role') != 'anon':
            raise ValueError('Solo se permite la clave anon pública.')
    if args.flavor == 'offline' and config:
        raise ValueError('El candidato offline no acepta configuración de servicios.')
    if args.mode == 'store' and args.flavor == 'connected':
        if any(not config.get(k) for k in ('SUPABASE_URL','SUPABASE_ANON_KEY','LIBRET_CAPTCHA_URL')):
            raise ValueError('Falta configuración pública de ensayo/producción validada.')
        for name in ('SUPABASE_URL','LIBRET_CAPTCHA_URL'):
            url = urlparse(config[name])
            if url.scheme != 'https' or not url.hostname or url.username or url.password:
                raise ValueError('Las URL públicas requieren HTTPS sin credenciales.')
    config_digest = hashlib.sha256(json.dumps(config, sort_keys=True).encode()).hexdigest()
    digest = source_digest()
    if args.mode == 'store':
        validate_store(metadata, evidence, digest, args.last_play_code, args.flavor, config_digest)
    if args.validate_only:
        print(json.dumps({'mode': args.mode, 'sourceSha256': digest, 'readyForStore': False}))
        return 0
    version_line = next(line for line in (ROOT / 'pubspec.yaml').read_text(encoding='utf-8').splitlines() if line.startswith('version:'))
    version, code = version_line.split(':', 1)[1].strip().split('+')
    code = max(int(code), (args.last_play_code or 0) + 1)
    args.out.mkdir(parents=True, exist_ok=True)
    defines = {**metadata, **config, 'LIBRET_APP_VERSION': f'{version}+{code}',
        'LIBRETAPP_OFFLINE_PILOT': str(args.flavor == 'offline').lower(),
        'LIBRETAPP_PUBLIC_RELEASE': 'true',
        'LIBRETAPP_ENABLE_PHONE_AUTH': str(args.flavor == 'connected').lower(),
        'LIBRETAPP_ENABLE_CLOUD_BACKUP': str(args.flavor == 'connected').lower(),
        'LIBRETAPP_ENABLE_SYNC': 'false'}
    define_path = args.out.resolve() / 'public-build-parameters.json'
    define_path.write_text(json.dumps(defines, indent=2), encoding='utf-8')
    env = os.environ.copy()
    # Android builds do not need Windows desktop plugin symlinks. This is a
    # process-local Flutter feature override; it changes no machine settings.
    env['FLUTTER_WINDOWS'] = 'false'
    env['LIBRETAPP_QA_SIGNING'] = str(args.mode == 'qa').lower()
    # On this Windows host AF_UNIX bind succeeds but connect fails. OpenJDK's
    # PipeImpl falls back to TCP when bind fails. Scope the workaround to this
    # child process; neither app permissions nor machine settings are changed.
    if os.name == 'nt':
        unavailable = args.out.resolve() / 'af-unix-disabled-not-a-directory'
        unavailable.write_text('Use TCP loopback for the build process.', encoding='ascii')
        env['JAVA_TOOL_OPTIONS'] = env.get('JAVA_TOOL_OPTIONS', '') + f' -Djdk.net.unixdomain.tmpdir="{unavailable}"'
    # Let Flutter refresh platform registrants in release mode. Reusing the
    # debug registrant can reference integration_test while Gradle correctly
    # excludes dev-only plugins from the release build.
    command = [args.flutter, '--no-version-check', 'build', 'appbundle', '--release', '--flavor', args.flavor,
        f'--build-name={version}', f'--build-number={code}', f'--dart-define-from-file={define_path}']
    started = datetime.now(timezone.utc)
    with (args.out / 'build.log').open('w', encoding='utf-8') as log:
        subprocess.run(command, cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    bundle = ROOT / f'build/app/outputs/bundle/{args.flavor}Release/app-{args.flavor}-release.aab'
    if datetime.fromtimestamp(bundle.stat().st_mtime, timezone.utc) < started:
        raise ValueError('No se generÃ³ un AAB nuevo.')
    if source_digest() != digest:
        raise ValueError('El cÃ³digo cambiÃ³ durante la compilaciÃ³n; vuelve a generar el candidato.')
    candidate_bundle = args.out.resolve() / f'LibretApp-{version}+{code}-{args.flavor}-{args.mode}.aab'
    shutil.copy2(bundle, candidate_bundle)
    manifest = ROOT / f'build/app/intermediates/merged_manifests/{args.flavor}Release/process{args.flavor.title()}ReleaseManifest/AndroidManifest.xml'
    subprocess.run([sys.executable, str(ROOT / 'tool/verify_offline_release.py'), str(candidate_bundle),
        '--flavor', args.flavor, '--manifest', str(manifest), '--out', str(args.out / 'bundle-inspection.json'),
        '--minimum-version-code', str(code)], cwd=ROOT, check=True)
    libraries, signed = inspect_bundle(candidate_bundle)
    jarsigner = shutil.which('jarsigner')
    if not jarsigner and env.get('JAVA_HOME'):
        jarsigner = str(Path(env['JAVA_HOME']) / 'bin' / ('jarsigner.exe' if os.name == 'nt' else 'jarsigner'))
    if not jarsigner:
        raise ValueError('Java 17 con jarsigner es necesario para verificar la firma.')
    with (args.out / 'signature-verification.log').open('w', encoding='utf-8') as log:
        subprocess.run([jarsigner, '-verify', str(candidate_bundle)], stdout=log, stderr=subprocess.STDOUT, check=True)
    bundle_digest = hashlib.sha256(candidate_bundle.read_bytes()).hexdigest()
    report = {'mode': args.mode, 'flavor': args.flavor,
        'configurationSha256': config_digest,
        'servicesConfigured': bool(config),
        'readyForStore': args.mode == 'store' and evidence.get('acceptedBundleSha256') == bundle_digest,
        'version': f'{version}+{code}', 'sourceSha256': digest,
        'bundleSha256': hashlib.sha256(candidate_bundle.read_bytes()).hexdigest(),
        'bundle': str(candidate_bundle), 'createdAt': datetime.now(timezone.utc).isoformat(),
        'signing': 'disposable QA/debug key' if args.mode == 'qa' else 'private upload key',
        'externalPlaySteps': 'Console verification, listing and declarations, pre-launch report and applicable closed testing remain external.'}
    (args.out / 'candidate.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, subprocess.CalledProcessError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
