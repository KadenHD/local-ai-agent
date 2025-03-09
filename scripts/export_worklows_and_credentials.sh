#!/bin/bash
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
EXPORT_DIR="/export/$TIMESTAMP"
TEMP_DIR="$EXPORT_DIR/temp"
WORKFLOWS_DIR="$EXPORT_DIR/workflows"
CREDENTIALS_DIR="$EXPORT_DIR/credentials"
EXPORTED_WORKFLOWS="$TEMP_DIR/exported_workflows.json"
EXPORTED_CREDENTIALS="$TEMP_DIR/exported_credentials.json"
EXISTING_WF_IDS="$TEMP_DIR/existing_workflow_ids.txt"
EXISTING_CRED_IDS="$TEMP_DIR/existing_credential_ids.txt"
mkdir -p $TEMP_DIR $WORKFLOWS_DIR $CREDENTIALS_DIR
n8n export:workflow --all --output=$EXPORTED_WORKFLOWS
n8n export:credentials --all --output=$EXPORTED_CREDENTIALS
jq -r '.[].id' $EXPORTED_WORKFLOWS > $EXISTING_WF_IDS
jq -r '.[].id' $EXPORTED_CREDENTIALS > $EXISTING_CRED_IDS
for wf_id in $(cat $EXISTING_WF_IDS); do
    echo "Processing workflow ID: $wf_id"
    CURRENT_FILE="$WORKFLOWS_DIR/$wf_id.json"
    TEMP_FILE="$TEMP_DIR/$wf_id.json"
    n8n export:workflow --id "$wf_id" --output="$CURRENT_FILE"
    jq '.[0]' "$CURRENT_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CURRENT_FILE"
done
for cred_id in $(cat $EXISTING_CRED_IDS); do
    echo "Processing credential ID: $cred_id"
    CURRENT_FILE="$CREDENTIALS_DIR/$cred_id.json"
    TEMP_FILE="$TEMP_DIR/$cred_id.json"
    n8n export:credentials --id "$cred_id" --output="$CURRENT_FILE"
    jq '.[0]' "$CURRENT_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CURRENT_FILE"
done
rm -rf $TEMP_DIR
