#!/bin/bash

# Define some color variables
GREEN='\033[1m\033[32m'
ORANGE='\033[1m\033[38;5;214m'
PURPLE='\033[1m\033[38;5;140m'
PEACH='\e[1;38;2;255;204;153m'
BLUE='\e[1;1;34m'
NC='\033[0m' # No Color

# Show APK Compare Tool text in middle
clear
echo ""
COLUMNS=$(tput cols)
title="APK Compare Tool"
printf "${PURPLE}%*s\n${NC}" $(((${#title} + $COLUMNS) / 2)) "$title"
echo ""

# Set the names and paths of the apk files using positional parameters
first_apk="$1"
second_apk="$2"

# Set the name and path of the log file with a timestamp
log_file="$(date +%Y-%m-%d_%H-%M-%S).log"

# Check if both files exist
if [ -f "$first_apk" ] && [ -f "$second_apk" ]; then
    # Check if apktool and diff tool are available
    if command -v apktool >/dev/null 2>&1 && command -v diff >/dev/null 2>&1; then
        # Decode the apk files using apktool
        echo -e "${GREEN}Decompiling both APK files...${NC}"
        echo ""
        apktool d -f -o first_apk "$first_apk" >/dev/null 2>&1
        apktool d -f -o second_apk "$second_apk" >/dev/null 2>&1

        # Ask the user which changes they want to compare
        echo -e "${ORANGE}Which changes do you want to compare?${NC}"
        echo "1. Resources"
        echo "2. Smali"
        echo "3. Everything"
        read -p "Enter your choice: " choice

        # Display only those changes based on user input
        if [ $choice -eq 1 ]; then
            output=$(diff --color=always -r first_apk/res second_apk/res)
            if [ -z "$output" ]; then
                echo ""
                echo -e "${BLUE}No changes were found in resources.${NC}"
                echo ""
            else
                echo "$output" | tee resources_changes_$log_file
                echo ""
                echo -e "${GREEN}Logs of the comparison result have been saved!${NC}"
                echo ""
            fi
        elif [ $choice -eq 2 ]; then
            output=$(diff --color=always -r first_apk/smali second_apk/smali)
            if [ -z "$output" ]; then
                echo ""
                echo -e "${BLUE}No changes were found in smali.${NC}"
                echo ""
            else
                echo "$output" | tee smali_changes_$log_file
                echo ""
                echo -e "${GREEN}Logs of the comparison result have been saved!${NC}"
                echo ""
            fi
        elif [ $choice -eq 3 ]; then
            output=$(diff --color=always -r first_apk second_apk)
            if [ -z "$output" ]; then
                echo ""
                echo -e "${BLUE}No changes were found.${NC}"
                echo ""
            else
                echo "$output" | tee every_changes_$log_file
                echo ""
                echo -e "${GREEN}Logs of the comparison result have been saved!${NC}"
                echo ""
            fi
        else
            echo "Invalid input."
        fi

        # Delete the decoded folders
        rm -rf first_apk second_apk

    else
        # Echo a message if one or both tools are not available
        echo -e "${PEACH}Apktool or diff tool not found. Please make sure you have both tools in your system.${NC}"
    fi
else
    # Echo a message if one or both files do not exist
    echo -e "${PEACH}One or both apk files do not exist.${NC}"
fi
