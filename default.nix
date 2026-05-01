{
  lib ? (import <nixpkgs> { }).lib,
  stdenv ? (import <nixpkgs> { }).stdenv,
  openssl ? (import <nixpkgs> { }).openssl,
  sqlite ? (import <nixpkgs> { }).sqlite,
  autoreconfHook ? (import <nixpkgs> { }).autoreconfHook,
  cppunit ? (import <nixpkgs> { }).cppunit,
  pkg-config ? (import <nixpkgs> { }).pkg-config,
  doCheck ? false,
}:

stdenv.mkDerivation rec {
  pname = "softhsm";
  version = "2.7.1-local";

  src = ./.;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ] ++ lib.optionals doCheck [ cppunit ];

  configureFlags = [
    "--with-crypto-backend=openssl"
    "--with-openssl=${lib.getDev openssl}"
    "--with-objectstore-backend-db"
    "--sysconfdir=$out/etc"
    "--localstatedir=$out/var"
    # The configure script checks for the sqlite3 command, but never uses it.
    # Provide an arbitrary executable file for cross scenarios.
    "ac_cv_path_SQLITE3=/"
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  inherit doCheck;

  strictDeps = true;

  postInstall = "rm -rf $out/var";

  meta = {
    homepage = "https://www.softhsm.org/";
    description = "Cryptographic store accessible through a PKCS #11 interface";
    longDescription = ''
      SoftHSM provides a software implementation of a generic
      cryptographic device with a PKCS#11 interface, which is of
      course especially useful in environments where a dedicated hardware
      implementation of such a device - for instance a Hardware
      Security Module (HSM) or smartcard - is not available.

      SoftHSM follows the OASIS PKCS#11 standard, meaning it should be
      able to work with many cryptographic products. SoftHSM is a
      programme of The Commons Conservancy.
    '';
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
  };
}
