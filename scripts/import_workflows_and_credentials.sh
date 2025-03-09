#!/bin/bash
BACKUP_DIR=/backup
TEMP_DIR="$BACKUP_DIR/temp"
EXISTING_WF_IDS="$TEMP_DIR/existing_workflow_ids.txt"
EXISTING_CRED_IDS="$TEMP_DIR/existing_credential_ids.txt"
NEW_WORKFLOWS="$BACKUP_DIR/workflows"
NEW_CREDENTIALS="$BACKUP_DIR/credentials"
mkdir $TEMP_DIR
n8n export:workflow --all --output="$TEMP_DIR/exported_workflows.json"
n8n export:credentials --all --output="$TEMP_DIR/exported_credentials.json"
jq -r '.[].id' $TEMP_DIR/exported_workflows.json > $TEMP_DIR/existing_workflow_ids.txt
jq -r '.[].id' $TEMP_DIR/exported_credentials.json > $TEMP_DIR/existing_credential_ids.txt
id_exists() {
    grep -q "^$1$" "$2"
}
for file in "$NEW_WORKFLOWS"/*.json; do
    new_id=$(jq -r '.id' "$file")
    if id_exists "$new_id" "$EXISTING_WF_IDS"; then
        echo "Skipping workflow $new_id (already exists)"
    else
        n8n import:workflow --input="$file"
    fi
done
for file in "$NEW_CREDENTIALS"/*.json; do
    new_id=$(jq -r '.id' "$file")
    if id_exists "$new_id" "$EXISTING_CRED_IDS"; then
        echo "Skipping credential $new_id (already exists)"
    else
        n8n import:credentials --input="$file"
    fi
done
rm -rf $TEMP_DIR
