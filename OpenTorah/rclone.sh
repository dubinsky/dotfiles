#!/bin/bash

echo "--- syncing 'opentorah-drive:/alter-rebbe'"
rclone --checksum --progress sync ~/OpenTorah/alter-rebbe opentorah-drive:/alter-rebbe

echo "--- syncing 'opentorah-buckets:facsimiles.alter-rebbe.org'"
rclone --checksum --progress sync ~/OpenTorah/facsimiles.alter-rebbe.org/ opentorah-buckets:facsimiles.alter-rebbe.org
