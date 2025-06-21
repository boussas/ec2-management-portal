#!/bin/bash

# === COLORS ===
RED="31"
GREEN="32"
CYAN="36"
BOLDRED="\e[1;${RED}m"
BOLDGREEN="\e[1;${GREEN}m"
BOLDCYAN="\e[1;${CYAN}m"
YELLOW="\e[33m"
RESET="\e[0m"

REGION="us-east-1"
INSTANCE_IDS=()
INSTANCE_NAMES=()

capitalize() {
  echo "${1^}"
}

load_instances_from_aws() {
  INSTANCE_IDS=()
  INSTANCE_NAMES=()

  local count=1
  while read -r id state name; do
    [[ -z "$name" || "$name" == "None" ]] && name="$id"
    state_fmt=$(capitalize "$state")

    printf "${BOLDGREEN}%d${RESET}- %s - ${YELLOW}%s${RESET}\n" "$count" "$name" "$state_fmt"

    INSTANCE_IDS[$count]="$id"
    INSTANCE_NAMES[$count]="$name"
    ((count++))
  done < <(
    aws ec2 describe-instances --region $REGION \
    --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`]|[0].Value]' \
    --output text
  )
  echo -e "${BOLDGREEN}0${RESET}- Back to Main Menu"
}

select_instance_prompt() {
  read -p "Enter instance number: " num
  [[ "$num" == "0" ]] && return 1

  id="${INSTANCE_IDS[$num]}"
  name="${INSTANCE_NAMES[$num]}"
  [[ -z "$id" ]] && echo -e "${BOLDRED}Invalid number!${RESET}" && sleep 2 && return 1
  return 0
}

start_instance() {
  while true; do
    clear
    echo -e "${BOLDCYAN}Start EC2 Instance:${RESET}"
    load_instances_from_aws
    select_instance_prompt || return

    current_state=$(aws ec2 describe-instances --region $REGION \
      --instance-ids "$id" \
      --query 'Reservations[0].Instances[0].State.Name' \
      --output text)

    if [ "$current_state" == "running" ]; then
      echo -e "${BOLDGREEN}$name ($id) is already running.${RESET}"
    else
      aws ec2 start-instances --region $REGION --instance-ids "$id" >/dev/null
      echo -e "${YELLOW}Starting $name ($id)...${RESET}"
    fi
    read -p "Press Enter to continue..."
    return
  done
}

stop_instance() {
  while true; do
    clear
    echo -e "${BOLDCYAN}Stop EC2 Instance:${RESET}"
    load_instances_from_aws
    select_instance_prompt || return

    current_state=$(aws ec2 describe-instances --region $REGION \
      --instance-ids "$id" \
      --query 'Reservations[0].Instances[0].State.Name' \
      --output text)

    if [ "$current_state" == "stopped" ]; then
      echo -e "${BOLDGREEN}$name ($id) is already stopped.${RESET}"
    else
      aws ec2 stop-instances --region $REGION --instance-ids "$id" >/dev/null
      echo -e "${YELLOW}Stopping $name ($id)...${RESET}"
    fi
    read -p "Press Enter to continue..."
    return
  done
}

reboot_instance() {
  while true; do
    clear
    echo -e "${BOLDCYAN}Reboot an EC2 Instance:${RESET}"
    load_instances_from_aws
    select_instance_prompt || return

    aws ec2 reboot-instances --region $REGION --instance-ids "$id"
    echo -e "${YELLOW}Rebooting '$name' ($id)...${RESET}"
    read -p "Press Enter to continue..."
    return
  done
}

view_instance_details() {
  while true; do
    clear
    echo -e "${BOLDCYAN}View EC2 Instance Details:${RESET}"
    load_instances_from_aws
    select_instance_prompt || return

    aws ec2 describe-instances --region $REGION --instance-ids "$id" \
      --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`]|[0].Value, State: State.Name, IP: PublicIpAddress, PrivateIP: PrivateIpAddress, Type: InstanceType, AZ: Placement.AvailabilityZone, LaunchTime: LaunchTime, ID: InstanceId}' \
      --output table

    read -p "Press Enter to continue..."
    return
  done
}

terminate_instance() {
  while true; do
    clear
    echo -e "${BOLDCYAN}Terminate EC2 Instance (Permanent):${RESET}"
    load_instances_from_aws
    select_instance_prompt || return

    echo -e "${BOLDRED}WARNING: This will permanently delete '$name' ($id)!${RESET}"
    read -p "Type 'YES' to confirm termination: " confirm
    if [[ "$confirm" == "YES" ]]; then
      aws ec2 terminate-instances --region $REGION --instance-ids "$id"
      echo -e "${BOLDGREEN}Instance terminated.${RESET}"
    else
      echo -e "${YELLOW}Termination cancelled.${RESET}"
    fi
    read -p "Press Enter to continue..."
    return
  done
}

check_instance_health() {
  while true; do
    clear
    echo -e "${BOLDCYAN}Check EC2 Instance Health:${RESET}"
    load_instances_from_aws
    select_instance_prompt || return

    aws ec2 describe-instance-status --region $REGION --instance-ids "$id" \
      --query 'InstanceStatuses[].{ID: InstanceId, System: SystemStatus.Status, Instance: InstanceStatus.Status, Reachability: InstanceStatus.Details[?Name==`reachability`]|[0].Status}' \
      --output table

    read -p "Press Enter to continue..."
    return
  done
}

main_menu() {
  while true; do
    clear
    echo -e "${BOLDCYAN}=============================="
    echo -e " EC2 Management Portal"
    echo -e "==============================${RESET}"
    echo -e "${BOLDGREEN}1.${RESET} List EC2 Instances"
    echo -e "${BOLDGREEN}2.${RESET} Start EC2 Instance"
    echo -e "${BOLDGREEN}3.${RESET} Stop EC2 Instance"
    echo -e "${BOLDGREEN}4.${RESET} Reboot EC2 Instance"
    echo -e "${BOLDGREEN}5.${RESET} View EC2 Instance Details"
    echo -e "${BOLDGREEN}6.${RESET} Terminate EC2 Instance"
    echo -e "${BOLDGREEN}7.${RESET} Check EC2 Instance Health"
    echo -e "${BOLDGREEN}8.${RESET} Exit"
    echo -e "=============================="
    read -p "Enter selection [1-8] > " choice

    case "$choice" in
      1) clear; load_instances_from_aws; read -p "Press Enter to continue..." ;;
      2) start_instance ;;
      3) stop_instance ;;
      4) reboot_instance ;;
      5) view_instance_details ;;
      6) terminate_instance ;;
      7) check_instance_health ;;
      8) echo -e "${BOLDGREEN}Goodbye!${RESET}"; exit 0 ;;
      *) echo -e "${BOLDRED}Invalid option!${RESET}"; sleep 1 ;;
    esac
  done
}

main_menu
