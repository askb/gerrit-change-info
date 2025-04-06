#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

# Usage: ./extract_ssh_inputs.sh <gerrit_url>

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <gerrit_url>"
  exit 1
fi

gerrit_url="$1"

# Extract hostname from URL
extract_hostname() {
  echo "$1" | sed -E 's#https?://([^/]+)/.*#\1#'
}

# Extract username from URL if embedded (not in your current format)
# Otherwise expect it from action input
# extract_username() {
#   echo "$1" | sed -E 's#.*//([^@]+)@.*#\1#'
# }

# Extract project from URL
extract_project() {
  echo "$1" | sed -E 's#.*/c/([^/]+/[^/]+)/\+.*#\1#'
}

# Extract change number
extract_change_number() {
  echo "$1" | sed -E 's#.*/\+/([0-9]+).*#\1#'
}

gerrit_hostname=$(extract_hostname "$gerrit_url")
project=$(extract_project "$gerrit_url")
change_number=$(extract_change_number "$gerrit_url")

{
  echo "GERRIT_HOSTNAME=$gerrit_hostname"
  echo "GERRIT_PROJECT=$project"
  echo "GERRIT_CHANGE_NUMBER=$change_number"
} > gerrit_ssh_info.env
