#!/bin/bash

echo "--- syncing 'podval-drive:/Books/Calibre Library'"
rclone --checksum --progress sync Calibre\ Library/ podval-drive:/Books/Calibre\ Library

echo "--- syncing 'podval-drive:/Books/Zotero'"
rclone --checksum --progress sync Zotero podval-drive:/Books/Zotero
