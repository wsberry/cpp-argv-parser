#!/usr/bin/env bash
#!/bin/bash

# ----------------------------------------------------------------------------------------
# Copyright (c) William Berry
# email: wberry.cpp@gmail.com
# github: https://github.com/wsberry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may freely use this source code and its projects in compliance with the License.
#
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License src distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------------------

# The following allows this script to be run within the scripts directory
# or from the project's root directory.
#
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
	if [[ -e "./scripts/core.sh" ]];
	then
		. "./scripts/core.sh"
		. "./scripts/network.sh"
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

# This name should come from the main CMakeLists.txt Script.
#
PROJECT_NAME="Command Line Parser Tests"

cmd_line_options="$1 $2 $3 $4"
option_clean="false"			# Clean the CMake generated projects.
option_build="false"			# Build from the CMake generated projects.
option_generate="false"			# Generate projects from CMake.

# The paths below are relative to 'ROOT_REPO_DIR'
#
APP_NAME="test-command-line-parser"

CMAKE_BIN_DIR="_bin"
CMAKE_BUILD_DIR="_build"
PROJECT_SRC_DIR="${ROOT_REPO_DIR}/source"
PROJECT_INC_DIR="${ROOT_REPO_DIR}/include"
CMAKE_BINARY_DIR="${ROOT_REPO_DIR}/${CMAKE_BUILD_DIR}"
CMAKE_INSTALL_DIR="${CMAKE_BINARY_DIR}/${CMAKE_BIN_DIR}"

# TODO:
#  macOS_CMAKE_APP_TARGET_PATH
#  WINDOWS_CMAKE_APP_DEBUG_PATH
#  WINDOWS_CMAKE_APP_RELEASE_PATH
#  WINDOWS_CMAKE_APP_DEFAULT_PATH
#
LINUX_CMAKE_APP_TARGET_PATH="${ROOT_REPO_DIR}/${CMAKE_BUILD_DIR}/source/test/cmd-line-parsing-tester/${APP_NAME}"

function eval_command_line_args()
{
  no_options_found="true"
  for option in ${cmd_line_options};
  do
    if [[ "-c" == "${option}" || "--clean" == "${option}" ]];
    then
      no_options_found="false"
      option_clean="true"

    elif [[ "-g" == "${option}" || "--generate" == "${option}" ]];
    then
      no_options_found="false"
      option_generate="true"

    elif [[ "-b" == "${option}" || "--build" == "${option}" ]];
    then
      no_options_found="false"
      option_build="true"

    elif [[ "-m" == "${option}" || "--make" == "${option}" ]];
    then
      no_options_found="false"
      option_build="true"
      option_clean="true"
      option_generate="true"
    fi
  done

  # If no options are provided assume generate and build only.
  #
  if [[ "true" == "${no_options_found}" ]];
  then
    option_build="true"
    option_generate="true"
  fi

  echo -e "${IWhite}Options:\n${IDefault}"
  echo -e "  option_build: ${option_build}"
  echo -e "  option_clean: ${option_clean}"
  echo -e "  option_generate: ${option_generate}"
}

# Always evaluat the command line options.
#
eval_command_line_args
  
function generate_or_build_projects()
{
	clear

	if [[ -d "${CMAKE_BINARY_DIR}" && "true" == "${option_clean}" ]];
	then
		  rm -frd "${CMAKE_BINARY_DIR}"
		  if [[ "false" == "${option_build}" && "false" == "${option_generate}" ]];
		  then
			  return 0
		  fi
	fi
	
	mkdir -p "${CMAKE_BINARY_DIR}"

	# Check if dependencies have been installed. If missing then an internet connection
	# is required. Note these libraries are only required for running the tests.
	#
  if [[ ! -d "${CMAKE_BINARY_DIR}/_deps/fmtlib" ]];
  then
    require_connection "https://github.com/wsberry"
  fi
  
  if [[ "true" == "${option_generate}" ]];
  then
    echo -e "\n${IYellow}---- Generating ${PROJECT_NAME}...${IDefault}."
    sleep 3

    # TODO: 
	#
	# 1. Create an option to select Ninja on all platforms.
	# 2. On linux users should be requested if they want to use Ninja
	#
    if [[ "darwin" == "${os_platform}" ]];
    then
      cmake -DCMAKE_BUILD_TYPE=Debug -G "Xcode" -B "${CMAKE_BINARY_DIR}" -S "./"

    elif [[ "linux" == "${os_platform}" ]];
    then
      if app_installed "ninja";
      then
        cmake -DCMAKE_BUILD_TYPE=Debug -G "Ninja" -B "${CMAKE_BINARY_DIR}" -S "./"
      else
        cmake -DCMAKE_BUILD_TYPE=Debug -B "${CMAKE_BINARY_DIR}" -S" ./"
      fi

    else
      #
      # Anything else including Windows
      #
      cmake -B"${CMAKE_BINARY_DIR}" -S"./"

    fi
  fi

  if [[ "true" == "${option_build}" ]];
  then
    reset_build_time
    echo -e "\n${IYellow}----Building ${PROJECT_NAME}...${IDefault}"
    sleep 3
		if [[ "windows" == "${os_platform}" ]];
		then
			  cmake --build "${CMAKE_BINARY_DIR}" --config Debug
			  cmake --build "${CMAKE_BINARY_DIR}" --config Release
		else
		    # TODO: Verify Other Platforms
		    cmake --build "${CMAKE_BINARY_DIR}"
		fi
		echo -e "\n\n"
		log_total_build_time
	fi

	# TODO: Open the build folder ???
	#
	if [[ "darwin" == "${os_platform}" ]];
	then
		open "${CMAKE_BINARY_DIR}"

	elif [[  "windows" == "${os_platform}" ]];
	then
		start "${CMAKE_BINARY_DIR}"

	elif [[  "linux" == "${os_platform}" ]];
	then
	  open "${CMAKE_BINARY_DIR}/source/test/cmd-line-parsing-tester"

	fi
}

generate_or_build_projects
