#ifndef LIBRET_SECURE_API_H
#define LIBRET_SECURE_API_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

enum libret_status_code {
	LIBRET_OK = 0,
	LIBRET_ERR_INVALID_INPUT = 1,
	LIBRET_ERR_ALLOCATION_FAILED = 2,
	LIBRET_ERR_AUTH_FAILED = 3,
};

const char *libret_core_version(void);

int32_t libret_encrypt_v1(
		const uint8_t *plaintext,
		intptr_t plaintext_length,
		const uint8_t *key,
		intptr_t key_length,
		uint8_t **out_ciphertext,
		intptr_t *out_ciphertext_length,
		uint8_t **out_nonce,
		intptr_t *out_nonce_length,
		uint8_t **out_tag,
		intptr_t *out_tag_length);

int32_t libret_decrypt_v1(
		const uint8_t *ciphertext,
		intptr_t ciphertext_length,
		const uint8_t *key,
		intptr_t key_length,
		const uint8_t *nonce,
		intptr_t nonce_length,
		const uint8_t *tag,
		intptr_t tag_length,
		uint8_t **out_plaintext,
		intptr_t *out_plaintext_length);

int32_t libret_kdf_v1(
		const uint8_t *password,
		intptr_t password_length,
		const uint8_t *salt,
		intptr_t salt_length,
		int32_t iterations,
		intptr_t key_length,
		uint8_t **out_key,
		intptr_t *out_key_length);

void libret_free_buffer(uint8_t *buffer, intptr_t length);

#ifdef __cplusplus
}
#endif

#endif  // LIBRET_SECURE_API_H
