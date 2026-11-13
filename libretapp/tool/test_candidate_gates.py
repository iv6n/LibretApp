"""Regression checks for the store generator; no builds or uploads occur."""
import unittest
import hashlib
import json
import tempfile
from pathlib import Path
from build_android_candidate import GATES, CONNECTED_GATES, validate_metadata, validate_store, validate_store_build
from accept_android_candidate import json_sha256, validate_receipt_inputs, verify_candidate_files


class CandidateGatesTest(unittest.TestCase):
    def setUp(self):
        # Test fixtures only; never written to a candidate or the app.
        self.metadata = {
            'LIBRET_RESPONSIBLE_NAME': 'Responsable de prueba',
            'LIBRET_SUPPORT_EMAIL': 'support@libret.invalid',
            'LIBRET_PRIVACY_URL': 'https://libret.invalid/privacy',
        }

    def test_missing_metadata_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_metadata({})

    def test_store_build_can_precede_final_evidence_but_needs_console_code(self):
        metadata = dict(self.metadata, LIBRET_SUPPORT_EMAIL='support@libret.dev',
                        LIBRET_PRIVACY_URL='https://libret.dev/privacy')
        validate_store_build(metadata, 0)
        with self.assertRaises(ValueError):
            validate_store_build(metadata, None)

    def test_test_domains_are_rejected(self):
        with self.assertRaises(ValueError):
            validate_metadata(self.metadata)

    def test_http_privacy_is_rejected(self):
        self.metadata['LIBRET_PRIVACY_URL'] = 'http://libret.invalid/privacy'
        with self.assertRaises(ValueError):
            validate_metadata(self.metadata)

    def test_pending_acceptance_and_stale_sources_are_rejected(self):
        # A syntax-valid fixture does not assert ownership or real approval.
        metadata = dict(self.metadata, LIBRET_SUPPORT_EMAIL='support@libret.dev',
                        LIBRET_PRIVACY_URL='https://libret.dev/privacy')
        for missing in GATES:
            checks = dict.fromkeys(GATES, True)
            checks[missing] = False
            with self.subTest(gate=missing), self.assertRaises(ValueError):
                validate_store(metadata, {'sourceSha256': 'current', 'checks': checks},
                               'current', 5)
        with self.assertRaises(ValueError):
            validate_store(metadata, {'sourceSha256': 'previous',
                'checks': dict.fromkeys(GATES, True)}, 'current', 5)
        with self.assertRaises(ValueError):
            validate_store(metadata, {'sourceSha256': 'current',
                'checks': dict.fromkeys(GATES, True)}, 'current', None)

    def test_connected_rejects_offline_and_changed_configuration_evidence(self):
        metadata = dict(self.metadata, LIBRET_SUPPORT_EMAIL='support@libret.dev',
                        LIBRET_PRIVACY_URL='https://libret.dev/privacy')
        evidence = {'sourceSha256': 'current', 'flavor': 'offline',
                    'configurationSha256': 'config',
                    'checks': dict.fromkeys(GATES + CONNECTED_GATES, True)}
        with self.assertRaises(ValueError):
            validate_store(metadata,evidence,'current',5,'connected','config')
        evidence['flavor'] = 'connected'
        with self.assertRaises(ValueError):
            validate_store(metadata,evidence,'current',5,'connected','changed-config')
        for gate in CONNECTED_GATES:
            pending = dict(evidence, checks=dict(evidence['checks'], **{gate:False}))
            with self.subTest(gate=gate), self.assertRaises(ValueError):
                validate_store(metadata,pending,'current',5,'connected','config')

    def test_post_build_acceptance_binds_exact_hash_and_console_code(self):
        metadata = dict(self.metadata, LIBRET_SUPPORT_EMAIL='support@libret.dev',
                        LIBRET_PRIVACY_URL='https://libret.dev/privacy')
        digest = 'a' * 64
        checks = {key: True for key in ('applicationId', 'buildNumberIncreased',
            'targetApi36', 'testedMinimumApi28', 'distributionPermissions',
            'systemCloudBackupDisabled', 'signaturePresent',
            'native64BitAlignment16kb')}
        inspection = {'versionCode': '22', 'checks': checks}
        evidence = {'sourceSha256': 'current', 'checks': dict.fromkeys(GATES, True)}
        candidate = {'mode': 'store', 'flavor': 'offline', 'readyForStore': False,
                     'bundleSha256': digest, 'sourceSha256': 'current',
                     'metadataSha256': json_sha256(metadata),
                     'version': '0.1.4+22'}
        self.assertEqual(validate_receipt_inputs(candidate, inspection, metadata,
            evidence, digest, 21, 'current'), 22)
        for changed_candidate, changed_inspection, changed_evidence, accepted, code, source in (
            (candidate, inspection, evidence, 'b' * 64, 21, 'current'),
            (candidate, inspection, evidence, digest, 22, 'current'),
            (candidate, inspection, evidence, digest, 21, 'changed'),
            (candidate, dict(inspection, checks=dict(checks, signaturePresent=False)), evidence, digest, 21, 'current'),
            (candidate, dict(inspection, checks=dict(checks, signaturePresent='false')), evidence, digest, 21, 'current'),
            (candidate, inspection, dict(evidence, checks=dict(evidence['checks'], suite=False)), digest, 21, 'current'),
            (dict(candidate, mode='qa'), inspection, evidence, digest, 21, 'current'),
        ):
            with self.assertRaises(ValueError):
                validate_receipt_inputs(changed_candidate, changed_inspection,
                    metadata, changed_evidence, accepted, code, source)

    def test_post_build_acceptance_rejects_modified_aab_and_inspection(self):
        with tempfile.TemporaryDirectory() as folder:
            directory = Path(folder)
            bundle = directory / 'candidate.aab'
            bundle.write_bytes(b'first bundle')
            inspection_path = directory / 'bundle-inspection.json'
            inspection = {'bundle': str(bundle)}
            inspection_path.write_text(json.dumps(inspection), encoding='utf-8')
            candidate_path = directory / 'candidate.json'
            candidate = {'bundle': str(bundle),
                'bundleSha256': hashlib.sha256(bundle.read_bytes()).hexdigest(),
                'inspectionSha256': hashlib.sha256(inspection_path.read_bytes()).hexdigest()}
            self.assertEqual(verify_candidate_files(candidate_path, candidate,
                inspection_path, inspection), bundle.resolve())
            bundle.write_bytes(b'modified bundle')
            with self.assertRaises(ValueError):
                verify_candidate_files(candidate_path, candidate,
                    inspection_path, inspection)
            bundle.write_bytes(b'first bundle')
            inspection_path.write_text('{}', encoding='utf-8')
            with self.assertRaises(ValueError):
                verify_candidate_files(candidate_path, candidate,
                    inspection_path, inspection)


if __name__ == '__main__':
    unittest.main()
