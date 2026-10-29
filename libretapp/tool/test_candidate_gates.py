"""Regression checks for the store generator; no builds or uploads occur."""
import unittest
from build_android_candidate import GATES, CONNECTED_GATES, validate_metadata, validate_store


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


if __name__ == '__main__':
    unittest.main()
