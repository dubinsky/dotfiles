#!/bin/bash
# Public key for the YubiKey OpenPGP identity used by `yadm encrypt`.
# Private material stays on the YubiKey (serial 18600387). Decrypt needs the
# card; encrypt uses this public key only.
gpg --import --quiet "$HOME/.config/yadm/yubikey-openpgp.asc"
yadm config yadm.gpg-recipient 049DC4EF6FB97468
