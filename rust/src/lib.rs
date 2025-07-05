//! FFI bindings for the ever-crypto library
//! 
//! This module provides C-compatible functions that can be called from Dart/Flutter
//! through FFI to access XChaCha20Poly1305 and Kyber1024 cryptographic operations.

use std::ptr;
use std::slice;

use ever_crypto::{
    XChaChaCrypto, XChaChaKey, XChaChaNonce,
    KyberCrypto, KyberPublicKey, KyberSecretKey, 
    kyber::KyberCiphertext,
};

/// Error codes for FFI functions
#[repr(C)]
pub enum FFIError {
    Success = 0,
    InvalidInput = -1,
    EncryptionError = -2,
    DecryptionError = -3,
    KeyError = -4,
    MemoryError = -5,
}

/// Result structure for key generation
#[repr(C)]
pub struct FFIKeyResult {
    pub data: *mut u8,
    pub len: usize,
    pub error: FFIError,
}

/// Result structure for encryption/decryption operations
#[repr(C)]
pub struct FFIDataResult {
    pub data: *mut u8,
    pub len: usize,
    pub error: FFIError,
}

/// Result structure for Kyber key pair generation
#[repr(C)]
pub struct FFIKyberKeyPair {
    pub public_key: *mut u8,
    pub public_key_len: usize,
    pub secret_key: *mut u8,
    pub secret_key_len: usize,
    pub error: FFIError,
}

/// Result structure for Kyber encapsulation
#[repr(C)]
pub struct FFIKyberEncapsulateResult {
    pub shared_secret: *mut u8,
    pub shared_secret_len: usize,
    pub ciphertext: *mut u8,
    pub ciphertext_len: usize,
    pub error: FFIError,
}

// Helper function to create a boxed slice and return pointer and length
fn create_boxed_slice(data: Vec<u8>) -> (*mut u8, usize) {
    let len = data.len();
    let ptr = Box::into_raw(data.into_boxed_slice()) as *mut u8;
    (ptr, len)
}

/// Generate a random XChaCha20Poly1305 key
#[no_mangle]
pub extern "C" fn xchacha_generate_key() -> FFIKeyResult {
    let key = XChaChaKey::generate();
    let key_bytes = key.as_bytes().to_vec();
    let (ptr, len) = create_boxed_slice(key_bytes);
    
    FFIKeyResult {
        data: ptr,
        len,
        error: FFIError::Success,
    }
}

/// Generate a random XChaCha20Poly1305 nonce
#[no_mangle]
pub extern "C" fn xchacha_generate_nonce() -> FFIKeyResult {
    let nonce = XChaChaNonce::generate();
    let nonce_bytes = nonce.as_bytes().to_vec();
    let (ptr, len) = create_boxed_slice(nonce_bytes);
    
    FFIKeyResult {
        data: ptr,
        len,
        error: FFIError::Success,
    }
}

/// Encrypt data with XChaCha20Poly1305
#[no_mangle]
pub extern "C" fn xchacha_encrypt(
    key_ptr: *const u8,
    key_len: usize,
    nonce_ptr: *const u8,
    nonce_len: usize,
    plaintext_ptr: *const u8,
    plaintext_len: usize,
    aad_ptr: *const u8,
    aad_len: usize,
) -> FFIDataResult {
    if key_ptr.is_null() || nonce_ptr.is_null() || plaintext_ptr.is_null() {
        return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::InvalidInput,
        };
    }

    let key_slice = unsafe { slice::from_raw_parts(key_ptr, key_len) };
    let nonce_slice = unsafe { slice::from_raw_parts(nonce_ptr, nonce_len) };
    let plaintext_slice = unsafe { slice::from_raw_parts(plaintext_ptr, plaintext_len) };
    
    let key = match XChaChaKey::from_bytes(key_slice) {
        Ok(k) => k,
        Err(_) => return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let nonce = match XChaChaNonce::from_bytes(nonce_slice) {
        Ok(n) => n,
        Err(_) => return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let aad = if aad_ptr.is_null() {
        None
    } else {
        Some(unsafe { slice::from_raw_parts(aad_ptr, aad_len) })
    };
    
    match XChaChaCrypto::encrypt(&key, &nonce, plaintext_slice, aad) {
        Ok(ciphertext) => {
            let (ptr, len) = create_boxed_slice(ciphertext);
            FFIDataResult {
                data: ptr,
                len,
                error: FFIError::Success,
            }
        }
        Err(_) => FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::EncryptionError,
        },
    }
}

/// Decrypt data with XChaCha20Poly1305
#[no_mangle]
pub extern "C" fn xchacha_decrypt(
    key_ptr: *const u8,
    key_len: usize,
    nonce_ptr: *const u8,
    nonce_len: usize,
    ciphertext_ptr: *const u8,
    ciphertext_len: usize,
    aad_ptr: *const u8,
    aad_len: usize,
) -> FFIDataResult {
    if key_ptr.is_null() || nonce_ptr.is_null() || ciphertext_ptr.is_null() {
        return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::InvalidInput,
        };
    }

    let key_slice = unsafe { slice::from_raw_parts(key_ptr, key_len) };
    let nonce_slice = unsafe { slice::from_raw_parts(nonce_ptr, nonce_len) };
    let ciphertext_slice = unsafe { slice::from_raw_parts(ciphertext_ptr, ciphertext_len) };
    
    let key = match XChaChaKey::from_bytes(key_slice) {
        Ok(k) => k,
        Err(_) => return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let nonce = match XChaChaNonce::from_bytes(nonce_slice) {
        Ok(n) => n,
        Err(_) => return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let aad = if aad_ptr.is_null() {
        None
    } else {
        Some(unsafe { slice::from_raw_parts(aad_ptr, aad_len) })
    };
    
    match XChaChaCrypto::decrypt(&key, &nonce, ciphertext_slice, aad) {
        Ok(plaintext) => {
            let (ptr, len) = create_boxed_slice(plaintext);
            FFIDataResult {
                data: ptr,
                len,
                error: FFIError::Success,
            }
        }
        Err(_) => FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::DecryptionError,
        },
    }
}

/// Generate a Kyber1024 key pair
#[no_mangle]
pub extern "C" fn kyber_generate_keypair() -> FFIKyberKeyPair {
    let keypair = KyberCrypto::generate_keypair();
    
    let public_key_bytes = keypair.public_key.as_bytes().to_vec();
    let secret_key_bytes = keypair.secret_key.as_bytes().to_vec();
    
    let (public_key_ptr, public_key_len) = create_boxed_slice(public_key_bytes);
    let (secret_key_ptr, secret_key_len) = create_boxed_slice(secret_key_bytes);
    
    FFIKyberKeyPair {
        public_key: public_key_ptr,
        public_key_len,
        secret_key: secret_key_ptr,
        secret_key_len,
        error: FFIError::Success,
    }
}

/// Encapsulate a shared secret with Kyber1024
#[no_mangle]
pub extern "C" fn kyber_encapsulate(
    public_key_ptr: *const u8,
    public_key_len: usize,
) -> FFIKyberEncapsulateResult {
    if public_key_ptr.is_null() {
        return FFIKyberEncapsulateResult {
            shared_secret: ptr::null_mut(),
            shared_secret_len: 0,
            ciphertext: ptr::null_mut(),
            ciphertext_len: 0,
            error: FFIError::InvalidInput,
        };
    }
    
    let public_key_slice = unsafe { slice::from_raw_parts(public_key_ptr, public_key_len) };
    
    let public_key = match KyberPublicKey::from_bytes(public_key_slice) {
        Ok(pk) => pk,
        Err(_) => return FFIKyberEncapsulateResult {
            shared_secret: ptr::null_mut(),
            shared_secret_len: 0,
            ciphertext: ptr::null_mut(),
            ciphertext_len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let (shared_secret, ciphertext) = KyberCrypto::encapsulate(&public_key);
    
    let shared_secret_bytes = shared_secret.as_bytes().to_vec();
    let ciphertext_bytes = ciphertext.as_bytes().to_vec();
    
    let (shared_secret_ptr, shared_secret_len) = create_boxed_slice(shared_secret_bytes);
    let (ciphertext_ptr, ciphertext_len) = create_boxed_slice(ciphertext_bytes);
    
    FFIKyberEncapsulateResult {
        shared_secret: shared_secret_ptr,
        shared_secret_len,
        ciphertext: ciphertext_ptr,
        ciphertext_len,
        error: FFIError::Success,
    }
}

/// Decapsulate a shared secret with Kyber1024
#[no_mangle]
pub extern "C" fn kyber_decapsulate(
    ciphertext_ptr: *const u8,
    ciphertext_len: usize,
    secret_key_ptr: *const u8,
    secret_key_len: usize,
) -> FFIDataResult {
    if ciphertext_ptr.is_null() || secret_key_ptr.is_null() {
        return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::InvalidInput,
        };
    }
    
    let ciphertext_slice = unsafe { slice::from_raw_parts(ciphertext_ptr, ciphertext_len) };
    let secret_key_slice = unsafe { slice::from_raw_parts(secret_key_ptr, secret_key_len) };
    
    let ciphertext = match KyberCiphertext::from_bytes(ciphertext_slice) {
        Ok(ct) => ct,
        Err(_) => return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let secret_key = match KyberSecretKey::from_bytes(secret_key_slice) {
        Ok(sk) => sk,
        Err(_) => return FFIDataResult {
            data: ptr::null_mut(),
            len: 0,
            error: FFIError::KeyError,
        },
    };
    
    let shared_secret = KyberCrypto::decapsulate(&ciphertext, &secret_key);
    let shared_secret_bytes = shared_secret.as_bytes().to_vec();
    let (ptr, len) = create_boxed_slice(shared_secret_bytes);
    
    FFIDataResult {
        data: ptr,
        len,
        error: FFIError::Success,
    }
}

/// Free memory allocated by FFI functions
#[no_mangle]
pub extern "C" fn free_bytes(ptr: *mut u8, len: usize) {
    if !ptr.is_null() {
        unsafe {
            let _ = Box::from_raw(slice::from_raw_parts_mut(ptr, len));
        }
    }
} 