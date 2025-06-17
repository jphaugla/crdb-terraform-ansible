#!/usr/bin/env bash
set -euo pipefail

in_region=$1

# 1) Grab the instance IDs (will be whitespace-separated)
raw_ids=$(aws ec2 describe-instances \
  --region "${in_region}" \
  --filters "Name=tag:CRDB,Values=true" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

# turn that string into an array
read -r -a ids <<< "$raw_ids"

if [ ${#ids[@]} -eq 0 ]; then
  echo "No running CRDB nodes found in ${in_region}"
  exit 0
fi

# 2) For each ID, print the exact stop command
for instance_id in "${ids[@]}"; do
  echo "aws ec2 stop-instances --region ${in_region} --instance-ids ${instance_id}"
done

