#include "libret_secure_api.h"

#include <chrono>
#include <cstdint>
#include <cstring>
#include <memory>

namespace {
constexpr char kVersion[] = "libret-core/0.1.0";
constexpr intptr_t kNonceSize = 12;
constexpr intptr_t kTagSize = 16;

inline uint8_t rotl8(uint8_t value, uint8_t shift) {
  return static_cast<uint8_t>((value << shift) | (value >> (8 - shift)));
}

void fill_nonce(uint8_t* out_nonce, intptr_t length, const uint8_t* key,
                intptr_t key_length) {
  const auto now = static_cast<uint64_t>(
      std::chrono::high_resolution_clock::now().time_since_epoch().count());
  for (intptr_t i = 0; i < length; ++i) {
    const auto time_byte = static_cast<uint8_t>((now >> ((i % 8) * 8)) & 0xFF);
    const auto key_byte = key[i % key_length];
    out_nonce[i] = static_cast<uint8_t>(time_byte ^ rotl8(key_byte, 3));
  }
}

void compute_tag(const uint8_t* ciphertext, intptr_t ciphertext_length,
                 const uint8_t* nonce, intptr_t nonce_length,
                 const uint8_t* key, intptr_t key_length, uint8_t* out_tag,
                 intptr_t out_tag_length) {
  uint32_t h0 = 0x811C9DC5u;
  uint32_t h1 = 0x9E3779B9u;

  for (intptr_t i = 0; i < ciphertext_length; ++i) {
    h0 ^= ciphertext[i];
    h0 *= 0x01000193u;
    h1 ^= rotl8(ciphertext[i], static_cast<uint8_t>(i % 7 + 1));
    h1 *= 0x85EBCA6Bu;
  }
  for (intptr_t i = 0; i < nonce_length; ++i) {
    h0 ^= nonce[i];
    h0 *= 0x01000193u;
    h1 ^= nonce[i] + static_cast<uint8_t>(i);
    h1 *= 0xC2B2AE35u;
  }
  for (intptr_t i = 0; i < key_length; ++i) {
    h0 ^= key[i];
    h0 *= 0x01000193u;
    h1 ^= rotl8(key[i], static_cast<uint8_t>(i % 5 + 1));
    h1 *= 0x27D4EB2Fu;
  }

  for (intptr_t i = 0; i < out_tag_length; ++i) {
    const auto mix = static_cast<uint8_t>(
        ((h0 >> ((i % 4) * 8)) ^ (h1 >> (((i + 1) % 4) * 8))) & 0xFF);
    out_tag[i] = mix;
  }
}

bool constant_time_equals(const uint8_t* a, const uint8_t* b, intptr_t length) {
  uint8_t diff = 0;
  for (intptr_t i = 0; i < length; ++i) {
    diff |= static_cast<uint8_t>(a[i] ^ b[i]);
  }
  return diff == 0;
}

uint8_t mix_bytes(uint8_t x, uint8_t y, uint8_t z) {
  auto v = static_cast<uint8_t>(x ^ rotl8(y, 1) ^ rotl8(z, 2));
  v = static_cast<uint8_t>(v + 0x9D);
  return rotl8(v, 3);
}

int32_t validate_encrypt_inputs(const uint8_t* plaintext, intptr_t plaintext_length,
                               const uint8_t* key, intptr_t key_length,
                               uint8_t** out_ciphertext,
                               intptr_t* out_ciphertext_length,
                               uint8_t** out_nonce,
                               intptr_t* out_nonce_length,
                               uint8_t** out_tag,
                               intptr_t* out_tag_length) {
  if (plaintext == nullptr || plaintext_length <= 0 || key == nullptr ||
      key_length <= 0 || out_ciphertext == nullptr ||
      out_ciphertext_length == nullptr || out_nonce == nullptr ||
      out_nonce_length == nullptr || out_tag == nullptr ||
      out_tag_length == nullptr) {
    return LIBRET_ERR_INVALID_INPUT;
  }
  return LIBRET_OK;
}
}

extern "C" const char *libret_core_version(void) {
  return kVersion;
}

extern "C" int32_t libret_encrypt_v1(
    const uint8_t *plaintext,
    intptr_t plaintext_length,
    const uint8_t *key,
    intptr_t key_length,
    uint8_t **out_ciphertext,
    intptr_t *out_ciphertext_length,
    uint8_t **out_nonce,
    intptr_t *out_nonce_length,
    uint8_t **out_tag,
    intptr_t *out_tag_length) {
  const auto validation = validate_encrypt_inputs(
      plaintext, plaintext_length, key, key_length, out_ciphertext,
      out_ciphertext_length, out_nonce, out_nonce_length, out_tag,
      out_tag_length);
  if (validation != LIBRET_OK) {
    return validation;
  }

  auto ciphertext = std::make_unique<uint8_t[]>(static_cast<size_t>(plaintext_length));
  auto nonce = std::make_unique<uint8_t[]>(static_cast<size_t>(kNonceSize));
  auto tag = std::make_unique<uint8_t[]>(static_cast<size_t>(kTagSize));
  if (!ciphertext || !nonce || !tag) {
    return LIBRET_ERR_ALLOCATION_FAILED;
  }

  fill_nonce(nonce.get(), kNonceSize, key, key_length);
  for (intptr_t i = 0; i < plaintext_length; ++i) {
    const auto key_byte = key[i % key_length];
    const auto nonce_byte = nonce[i % kNonceSize];
    ciphertext[i] = static_cast<uint8_t>(plaintext[i] ^ key_byte ^ nonce_byte);
  }
  compute_tag(ciphertext.get(), plaintext_length, nonce.get(), kNonceSize, key,
              key_length, tag.get(), kTagSize);

  *out_ciphertext_length = plaintext_length;
  *out_nonce_length = kNonceSize;
  *out_tag_length = kTagSize;
  *out_ciphertext = ciphertext.release();
  *out_nonce = nonce.release();
  *out_tag = tag.release();
  return LIBRET_OK;
}

extern "C" int32_t libret_decrypt_v1(
    const uint8_t *ciphertext,
    intptr_t ciphertext_length,
    const uint8_t *key,
    intptr_t key_length,
    const uint8_t *nonce,
    intptr_t nonce_length,
    const uint8_t *tag,
    intptr_t tag_length,
    uint8_t **out_plaintext,
    intptr_t *out_plaintext_length) {
  if (ciphertext == nullptr || ciphertext_length <= 0 || key == nullptr ||
      key_length <= 0 || nonce == nullptr || nonce_length != kNonceSize ||
      tag == nullptr || tag_length != kTagSize || out_plaintext == nullptr ||
      out_plaintext_length == nullptr) {
    return LIBRET_ERR_INVALID_INPUT;
  }

  auto expected_tag = std::make_unique<uint8_t[]>(static_cast<size_t>(kTagSize));
  if (!expected_tag) {
    return LIBRET_ERR_ALLOCATION_FAILED;
  }
  compute_tag(ciphertext, ciphertext_length, nonce, nonce_length, key, key_length,
              expected_tag.get(), kTagSize);
  if (!constant_time_equals(expected_tag.get(), tag, kTagSize)) {
    return LIBRET_ERR_AUTH_FAILED;
  }

  auto plaintext = std::make_unique<uint8_t[]>(static_cast<size_t>(ciphertext_length));
  if (!plaintext) {
    return LIBRET_ERR_ALLOCATION_FAILED;
  }
  for (intptr_t i = 0; i < ciphertext_length; ++i) {
    const auto key_byte = key[i % key_length];
    const auto nonce_byte = nonce[i % nonce_length];
    plaintext[i] = static_cast<uint8_t>(ciphertext[i] ^ key_byte ^ nonce_byte);
  }

  *out_plaintext_length = ciphertext_length;
  *out_plaintext = plaintext.release();
  return LIBRET_OK;
}

extern "C" int32_t libret_kdf_v1(
    const uint8_t *password,
    intptr_t password_length,
    const uint8_t *salt,
    intptr_t salt_length,
    int32_t iterations,
    intptr_t key_length,
    uint8_t **out_key,
    intptr_t *out_key_length) {
  if (password == nullptr || password_length <= 0 || salt == nullptr ||
      salt_length <= 0 || iterations <= 0 || key_length <= 0 ||
      out_key == nullptr || out_key_length == nullptr) {
    return LIBRET_ERR_INVALID_INPUT;
  }

  auto key = std::make_unique<uint8_t[]>(static_cast<size_t>(key_length));
  if (!key) {
    return LIBRET_ERR_ALLOCATION_FAILED;
  }

  for (intptr_t i = 0; i < key_length; ++i) {
    auto acc = static_cast<uint8_t>((i * 0x3D) & 0xFF);
    for (int32_t it = 0; it < iterations; ++it) {
      const auto p = password[(i + it) % password_length];
      const auto s = salt[(it + i * 3) % salt_length];
      acc = mix_bytes(acc, p, s);
      acc = static_cast<uint8_t>(acc ^ ((it + i) & 0xFF));
    }
    key[i] = acc;
  }

  *out_key_length = key_length;
  *out_key = key.release();
  return LIBRET_OK;
}

extern "C" void libret_free_buffer(uint8_t *buffer, intptr_t length) {
  if (buffer == nullptr || length <= 0) {
    return;
  }

  // Zeroize before releasing sensitive memory.
  std::memset(buffer, 0, static_cast<size_t>(length));
  delete[] buffer;
}
