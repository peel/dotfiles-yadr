#!/usr/bin/bash

# Open an issue in each maven-convention following project
#
# Example:
# ghi_opens "some issue"

function ghi_opens(){
    for_projects ghi open "[$project] $1"
}

ghi_opens $@