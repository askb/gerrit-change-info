#!/usr/bin/env bash

# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

# Usage: ./gerrit_api_query.sh <gerrit_url> <patchset_number>

#!/usr/bin/env bash
set -euo pipefail

GERRIT_URL="$1"
PATCHSET_NUMBER="${2:-}"

# Extract parts from the URL
GERRIT_HOSTNAME=$(echo "$GERRIT_URL" | awk -F/ '{print $3}')
GERRIT_PROJECT=$(echo "$GERRIT_URL" | awk -F/ '{for(i=1;i<=NF;i++) if ($i=="c") print $(i+1)"/"$(i+2)}')
GERRIT_CHANGE_NUMBER=$(echo "$GERRIT_URL" | grep -oP '\+/\K[0-9]+')

# Encode project path
ENCODED_PROJECT=$(echo "$GERRIT_PROJECT" | sed 's/\//%2F/g')

# Construct Gerrit REST API URL
GERRIT_API_URL="https://${GERRIT_HOSTNAME}/gerrit/changes/${ENCODED_PROJECT}~${GERRIT_CHANGE_NUMBER}/detail"

# Fetch and clean the JSON
RESPONSE=$(curl -s "$GERRIT_API_URL" | sed '1{/^)]}/d}')

# Parse with jq
GERRIT_BRANCH=$(echo "$RESPONSE" | jq -r '.branch')
GERRIT_CHANGE_ID=$(echo "$RESPONSE" | jq -r '.change_id')
GERRIT_PROJECT=$(echo "$RESPONSE" | jq -r '.project')
GERRIT_REFSPEC=$(echo "$RESPONSE" | jq -r '.revisions[].ref' | head -n1)
# GERRIT_REVISION=$(echo "$RESPONSE" | jq -r '.current_revision')
GERRIT_EVENT_TYPE="patchset-created"


# Optional: Select the desired patchset (revision)
if [[ -n "$PATCHSET_NUMBER" ]]; then
  GERRIT_REVISION=$(echo "$RESPONSE" | jq -r --arg num "$PATCHSET_NUMBER" '
    .revisions | to_entries[] |
    select(.value._number == ($num | tonumber)) |
    .key
  ')
else
  # Default to the latest patchset
  GERRIT_REVISION=$(echo "$RESPONSE" | jq -r '.current_revision')
fi

if [[ -z "$GERRIT_REVISION" || "$GERRIT_REVISION" == "null" ]]; then
  echo "Error: Patchset number $PATCHSET_NUMBER not found in change $GERRIT_CHANGE_NUMBER"
  exit 1
fi

# Export outputs
cat <<EOF > "${GERRIT_CHANGE_NUMBER}.file"
GERRIT_BRANCH=$GERRIT_BRANCH
GERRIT_CHANGE_ID=$GERRIT_CHANGE_ID
GERRIT_PROJECT=$GERRIT_PROJECT
GERRIT_CHANGE_URL=$GERRIT_URL
GERRIT_CHANGE_NUMBER=$GERRIT_CHANGE_NUMBER
GERRIT_PATCHSET_REVISION=$GERRIT_REVISION
GERRIT_EVENT_TYPE=$GERRIT_EVENT_TYPE
GERRIT_REFSPEC=$GERRIT_REFSPEC
GERRIT_HOSTNAME=$GERRIT_HOSTNAME
EOF
