#!/bin/sh
n8n import:credentials --separate --input=/backup/credentials
n8n import:workflow --separate --input=/backup/workflows
