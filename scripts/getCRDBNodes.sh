#!/usr/bin/env bash
in_region=$1
set -euo pipefail

# 1) List instance IDs with tag CRDB=true in the current region
INSTANCE_IDS=$(aws ec2 describe-instances \
  --region ${in_region} \
  --filters "Name=tag:CRDB,Values=true" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

for i in "${INSTANCE_IDS[@]}"; do
   echo "aws stop-instances --region ${in_region} --instance-ids ${i}"
done
