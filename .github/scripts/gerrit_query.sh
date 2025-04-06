#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

# Usage: ./gerrit_query.sh <gerrit_url> <patchset_number> <ssh_user_name>

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <gerrit_url> <patchset_number> <ssh_user_name>"
  exit 1
fi

gerrit_url="$1"
cid_patch_set_no="$2"
ssh_user_name="$3"

extract_project() {
  echo "$1" | sed -E 's#.*/c/([^/]+/[^/]+)/\+.*#\1#'
}

extract_change_number() {
  echo "$1" | sed -E 's#.*/\+/([0-9]+).*#\1#'
}

extract_hostname() {
  echo "$1" | sed -E 's#https?://([^/]+)/.*#\1#'
}

gerrit_hostname=$(extract_hostname "$gerrit_url")
change_number=$(extract_change_number "$gerrit_url")
project=$(extract_project "$gerrit_url")

if [ -n "$cid_patch_set_no" ]; then
    ssh_command="ssh -p 29418 $ssh_user_name@$gerrit_hostname 'gerrit query --format=JSON project:$project change:$change_number owner:self is:open limit:1' --patch-sets"
else
    ssh_command="ssh -p 29418 $ssh_user_name@$gerrit_hostname 'gerrit query --format=JSON project:$project change:$change_number owner:self is:open limit:1' --current-patch-set"
fi

json_output=$(eval "$ssh_command" 2>/dev/null)

if [[ $? -ne 0 || -z "$json_output" ]]; then
  echo "Error: Gerrit query failed."
  exit 1
fi

# Parse with jq
GERRIT_BRANCH=$(echo "$json_output" | jq -r '.branch')
GERRIT_CHANGE_ID=$(echo "$json_output" | jq -r '.id')
GERRIT_CHANGE_URL=$(echo "$json_output" | jq -r '.url')
GERRIT_PATCHSET_NUMBER=$(echo "$json_output" | jq --argjson num "${cid_patch_set_no:-0}" -r 'if $num > 0 then .patchSets[$num - 1].number else .currentPatchSet.number end')
GERRIT_PATCHSET_REVISION=$(echo "$json_output" | jq --argjson num "${cid_patch_set_no:-0}" -r 'if $num > 0 then .patchSets[$num - 1].revision else .currentPatchSet.revision end')
GERRIT_REFSPEC=$(echo "$json_output" | jq --argjson num "${cid_patch_set_no:-0}" -r 'if $num > 0 then .patchSets[$num - 1].ref else .currentPatchSet.ref end')
GERRIT_PROJECT=$(echo "$json_output" | jq -r '.project' | sed 's#/#-#')
GERRIT_HOSTNAME=$(extract_hostname "$GERRIT_CHANGE_URL")

{
    echo "GERRIT_BRANCH=$GERRIT_BRANCH"
    echo "GERRIT_CHANGE_ID=$GERRIT_CHANGE_ID"
    echo "GERRIT_CHANGE_URL=$GERRIT_CHANGE_URL"
    echo "GERRIT_CHANGE_NUMBER=$change_number"
    echo "GERRIT_EVENT_TYPE=comment_added"
    echo "GERRIT_PATCHSET_NUMBER=$GERRIT_PATCHSET_NUMBER"
    echo "GERRIT_PATCHSET_REVISION=$GERRIT_PATCHSET_REVISION"
    echo "GERRIT_PROJECT=opendaylight/$GERRIT_PROJECT"
    echo "GERRIT_REFSPEC=$GERRIT_REFSPEC"
    echo "GERRIT_HOSTNAME=$GERRIT_HOSTNAME"
} > "$change_number.file"
