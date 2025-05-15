#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear


export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)

if [ -z "$ZONE" ]; then
    echo "${YELLOW_TEXT}${BOLD_TEXT} Default zone not found.${RESET_FORMAT}"
    read -p "${GREEN_TEXT}${BOLD_TEXT}Please enter the zone: ${RESET_FORMAT}" ZONE
fi

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])" 2>/dev/null)

if [ -z "$REGION" ]; then
    if [ -n "$ZONE" ]; then
        REGION=$(echo "$ZONE" | sed 's/-[a-z]$//')
        echo "${YELLOW_TEXT}${BOLD_TEXT} Default region not found. Deriving region from zone: ${GREEN_TEXT}$REGION${RESET_FORMAT}"
    else
        echo "${RED_TEXT}${BOLD_TEXT} Critical: Cannot determine region as zone is also not set. Please configure default zone/region or provide them.${RESET_FORMAT}"
    fi
fi

echo
echo "${GREEN_TEXT}${BOLD_TEXT} Lab Zone: ${WHITE_TEXT}$ZONE${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT} Lab Region: ${WHITE_TEXT}$REGION${RESET_FORMAT}"
echo

gcloud compute networks create labnet --subnet-mode=custom

gcloud compute networks subnets create labnet-sub \
   --network labnet \
   --region "$REGION" \
   --range 10.0.0.0/28

gcloud compute networks list

gcloud compute firewall-rules create labnet-allow-internal \
    --network=labnet \
    --action=ALLOW \
    --rules=icmp,tcp:22 \
    --source-ranges=0.0.0.0/0

gcloud compute networks create privatenet --subnet-mode=custom

gcloud compute networks subnets create private-sub \
    --network=privatenet \
    --region="$REGION" \
    --range 10.1.0.0/28

gcloud compute firewall-rules create privatenet-deny \
    --network=privatenet \
    --action=DENY \
    --rules=icmp,tcp:22 \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules list --sort-by=NETWORK

gcloud compute instances create pnet-vm \
--zone="$ZONE" \
--machine-type=n1-standard-1 \
--subnet=private-sub

gcloud compute instances create lnet-vm \
--zone="$ZONE" \
--machine-type=n1-standard-1 \
--subnet=labnet-sub

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT} SUBSCRIBE TO QWIKLAB EXPLORERS! ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@qwiklabexplorers${RESET_FORMAT}"
echo
