#!/usr/bin/env bash
#!/bin/bash

ROOT_REPO_DIR=$(cd "$(dirname "$0")" && pwd)

if [[ "${ROOT_REPO_DIR}" == *"scripts"* ]];
then
   #
   # remove substr '/scripts'
   #
   scripts="/scripts"
   ROOT_REPO_DIR="${ROOT_REPO_DIR/$scripts}"
fi

if [[ -e "core.sh" ]];
then
   . "core.sh"
   . "network.sh"
else
   if [[ -e "../scripts/core.sh" ]];
   then
      . "../scripts/core.sh"
      . "../scripts/network.sh"
   else
      echo -e "\n${TAB}Unable to find: './scripts/core.sh'\n"
      #
      # The following stops execution if the last command in the pipeline had an error.
      # Since the core.sh library was not found the script most likely cannot continue
      # without errors so the script process is aborted.
      #
      set -e
      exit 1
   fi
fi

if [[ "darwin" == "${os_platform}" ]];
then
   open "https://github.com/wsberry"

elif [[  "windows" == "${os_platform}" ]];
then
   start "https://github.com/wsberry"

elif [[  "linux" == "${os_platform}" ]];
then
   open "https://github.com/wsberry"

fi
    
