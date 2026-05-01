{
  description = "SoftHSMv2 development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.callPackage ./default.nix { };
          softhsm = pkgs.callPackage ./default.nix { };
          softhsm-with-tests = pkgs.callPackage ./default.nix { doCheck = true; };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Build tools
            autoconf
            automake
            libtool
            pkg-config

            # Cryptographic backend (OpenSSL)
            openssl

            # Optional dependencies
            sqlite
            p11-kit
            cppunit

            # Utilities for testing
            opensc  # provides pkcs11-tool
          ];

          shellHook = ''
            # Setup SoftHSM configuration
            SOFTHSM_DIR="$PWD/.softhsm-dev"
            mkdir -p "$SOFTHSM_DIR/tokens"

            export SOFTHSM2_CONF="$SOFTHSM_DIR/softhsm2.conf"

            if [ ! -f "$SOFTHSM2_CONF" ]; then
              cat > "$SOFTHSM2_CONF" << EOF
# SoftHSM v2 configuration file (development)
directories.tokendir = $SOFTHSM_DIR/tokens
objectstore.backend = file
log.level = INFO
EOF
              echo "Created SoftHSM configuration at: $SOFTHSM2_CONF"
            fi

            echo "SoftHSMv2 development environment"
            echo "=================================="
            echo ""
            echo "SoftHSM config: $SOFTHSM2_CONF"
            echo "Token directory: $SOFTHSM_DIR/tokens"
            echo ""
            echo "Manual build steps:"
            echo "  1. sh autogen.sh"
            echo "  2. ./configure [options]"
            echo "  3. make"
            echo "  4. make check  (run tests)"
            echo ""
            echo "Or use Nix to build:"
            echo "  nix build               (build without tests)"
            echo "  nix build .#softhsm-with-tests  (build with tests)"
            echo ""
            echo "Common configure options:"
            echo "  --with-crypto-backend=openssl"
            echo "  --with-migrate           (requires SQLite3)"
            echo "  --with-objectstore-backend-db"
            echo "  --enable-ecc"
            echo "  --enable-gost"
            echo "  --enable-eddsa"
            echo ""
            echo "Available tools: pkcs11-tool, softhsm2-util (after build)"
            echo ""
          '';
        };
      }
    );
}
