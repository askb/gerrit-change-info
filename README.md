<!--
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation
-->

# Export Gerrit change request information

The gerrit-change-info action takes the Gerrit change URL and patchset number
as input and returns information about the Gerrit change request, which other
releng reusable workflows then reuse as input.

## gerrit-change-info

## Usage Example

<!-- markdownlint-disable MD046 -->

```yaml
steps:
  - name: "Gerrit change information"
    id: gerrit
    uses: lfreleng-actions/gerrit-change-info@main
    with:
      GERRIT_CHANGE_URL: ${{ inputs.GERRIT_CHANGE_URL }}
      GERRIT_SSH_USER: ${{ vars.GERRIT_SSH_USER }}
      GERRIT_PATCHSET_NUMBER: ${{ inputs.GERRIT_PATCHSET_NUMBER }}
    secrets:
      GERRIT_SSH_PRIVKEY: ${{ secrets.GERRIT_SSH_PRIVKEY }}

```

<!-- markdownlint-enable MD046 -->

## Inputs

<!-- markdownlint-disable MD013 -->

| Variable Name          | Required | Description                 |
| ---------------------- | -------- | --------------------------- |
| GERRIT_CHANGE_URL      | Yes      | Gerrit change-request URL   |
| GERRIT_SSH_USER        | Yes      | SSH User name               |
| GERRIT_PATCHSET_NUMBER | False    | Gerrit patchset number      |
| GERRIT_SSH_PRIVKEY     | False    | Gerrit SSH user private key |

<!-- markdownlint-enable MD013 -->

## Outputs

<!-- markdownlint-disable MD013 -->

| Variable Name           | Description                           |
| ----------------------- | ------------------------------------- |
| GERRIT_BRANCH           | Gerrit branch                         |
| GERRIT_CHANGE_ID        | Gerrit change ID                      |
| GERRIT_CHANGE_URL       | Gerrit change URL                     |
| GERRIT_CHANGE_NUMBER    | Gerrit change number                  |
| GERRIT_EVENT_TYPE       | Gerrit event type                     |
| GERRIT_PATCHSET_NUMBER  | Gerrit change patchset revision number|
| GERRIT_PATCHSET_REVISION| Gerrit change patchset revision sha   |
| GERRIT_PROJECT          | Gerrit project                        |
| GERRIT_REFSPEC          | refspec of the Gerrit change request  |
| GERRIT_HOSTNAME         | Gerrit hostname                       |

<!-- markdownlint-enable MD013 -->

## Workflow output example

```console
GERRIT_BRANCH="master"
GERRIT_CHANGE_ID="Icbc94be813abd2dcfb3ad5bd9bed66ecf1847572"
GERRIT_CHANGE_URL="https://git.opendaylight.org/gerrit/c/releng/builder/+/111445"
GERRIT_CHANGE_NUMBER="111445"
GERRIT_EVENT_TYPE="comment_added"
GERRIT_PATCHSET_NUMBER="6"
GERRIT_PATCHSET_REVISION="887d670768f79896b48bda353ef473ae66b13dc7"
GERRIT_PROJECT="opendaylight/releng-builder"
GERRIT_REFSPEC="refs/changes/45/111445/6"
GERRIT_HOSTNAME="git.opendaylight.org"
```

## Implementation Details

Using an SSH connection to the Gerrit server, the gerrit-query CLI command
obtains and validates parameters required by downstream reusable
workflows.

## Notes

The purpose of the workflow reduces the large number of  manually entered
inputs by the end use requiring to trigger workflows.
