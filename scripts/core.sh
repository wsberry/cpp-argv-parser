#!/usr/bin/env bash
#!/bin/bash
# -----------------------------------------------------------------------------------------
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
# -----------------------------------------------------------------------------------------

# TODO: Remove obsolete functions

SCRIPTDIR=$(cd "$(dirname "$0")" && pwd)

arg1=$1; arg1="${arg1,,}" #Note: to capitalize do "${arg1^^}"
arg2=$2; arg2="${arg2,,}"
arg3=$3; arg3="${arg3,,}"
arg4=$4; arg4="${arg4,,}"
arg5=$5; arg5="${arg5,,}"

declare command_line_args=("$arg1" "$arg2" "$arg3" "$arg4" "$arg5")

# use for debugging:
#
# echo "${TAB}Command Line:  $arg1 $arg2 $arg3 $arg4 $arg5"

# High Intensity Text Foreground Colors
#
IBlack='\033[0;90m'
IRed='\033[0;91m'
IGreen='\033[0;92m'
IYellow='\033[0;93m'
IBlue='\033[0;94m'
IPurple='\033[0;95m'
ICyan='\033[0;96m'
IWhite='\033[0;97m'
IDefault='\033[0m' # Resets the text foreground color to the default shell color.
IDefault='\033[0m'  
   
# Defaults for globally scoped variables:
#
TAB="  "
build_target=""
generate_projects_from_cmake=0
is_admin=false
is_setup_mode=false
is_verbose=off
os_platform="windows"
os_version="$(uname -s)"
output_target="/dev/null"
show_help=false
total_build_time=0;
static_lib_ext=".lib"
shared_lib_ext=".dll"
application_ext=".exe"
pdb_ext=".pdb"
debug_script=false

# Use to acquire the absolute path of a file or directory.
#
# Example:
#  absolute "./some_path"
#  echo "${absolute_path_}"
#  TODO: Confirm across windows, linux, and macOS
export absolute_path_=""
function absolute()
{
  #if is_os "linux" || is_os "darwin" && check_for_package_manager "brew";
  #then
  #  Homebrew coreutils must be installed for 'realpath'.
  #  absolute_path_=$(realpath "$1")
  #else
    #
    # The following should work on most systems including git bash on
    # Windows.
    #
    absolute_path_="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
  #fi
}

function prompt_to_continue()
{
    msg_prompt="$1"
	if [[ -z "$1" ]];
	then
		msg_prompt="${TAB}Enter any key to continue or 'Q/q' to quit: "
	fi
	
	while true; 
	do
		read -p "${msg_prompt}" q
		case $q in
		[Qq]* ) set -e && exit 0;;
		* ) break;;
		esac
	done
	echo -e "${IDefault}"
}

function app_installed()
{
  # note: dpkg -s and -l are not working (but it seems like they should);
  # i.e., what am I doing wrong: 'dpkg -s $1 &> /dev/null' ???
  #
  # if ! [ -x "$(command -v $1)" ];
  # then
  #   return 1
  # fi
  # return 0
  
  # TODO: Tested on: Windows [X], Linux [], macOS []
  type "$1" &> /dev/null;
}

# 'true' if user has admin.
#
function has_admin()
{
    # 'net session' will result in an access denied error if the user
	# does not have admin permissions.
	#
	net session > /dev/null 2>&1
	if [ $? -eq 0 ]; then
	    is_admin=true
		return 0
	else
		return 1
	fi
}

# Aborts script if user does not have admin.
#
function require_admin()
{
    # 'net session' will result in an access denied error if the user
	# does not have admin permissions.
	#
    net session > /dev/null 2>&1
    if [ $? -eq 0 ]; then 
      echo "user is administrator" &>/dev/null
    else 
      echo "\n\n${TAB}${IPurple}This script requires admin privileges.${IDefault}\n"
	  set -e
      exit 0 
    fi
}

function require_no_root_privileges()
{
    if (( $EUID == 0 )); 
	then
      clear
      echo -e "${TAB}${IPurple}This script requires options that should not be run as root; therefore 'sudo' should not be used.${IDefault}\n"
	  set -e
	  exit 0
    fi
}

function set_git_credential_helper() # $1 == seconds
{
    if [ "$WARN_ONCE" != "true" ]; then
        echo -e  "${IPurple}W A R N I NG${IYellow}"
        echo - e "${TAB}Git credentials will be cached while this script is running (up to $1 seconds)."
        echo - e "${TAB}The stored credentials never touch the disk, and are forgotten after a "
        echo - e "${TAB}configurable timeout. The cache is accessible over a Unix domain socket and"
        echo - e "${TAB}restricted to the current user by filesystem permissions.${IDefault}"
        sleep 5
        WARN_ONCE="true"
        if [[ "linux" == "${os_platform}" ]];
        then
          sudo git config credential.helper 'cache --timeout=$1'
        else
          git config credential.helper 'cache --timeout=$1'
        fi
    fi
}

function add_user_to_virtualbox_group()
{
	# make sure the virtual box group exists...
	# this will have no effect (other than adding a group)
	# when not running on virtual hosts.
	#
	sudo adduser $USER vboxsf
	sudo usermod -aG vboxsf $USER
}

function system_os
{
  case "$OSTYPE" in
  solaris*)
    os_platform="solaris"
    ;;
  darwin*)
    os_platform="darwin"
    static_lib_ext=".a"
    shared_lib_ext=".dylib"
    application_ext=".app"
    ;;
  linux*)
    os_platform="linux"
    static_lib_ext=".a"
    shared_lib_ext=".so"
    application_ext=""
    ;;
  bsd*)
    os_platform="bsd"
    ;;
  msys*)
    os_platform="windows"
    static_lib_ext=".lib"
    shared_lib_ext=".dll"
    application_ext=".exe"
    ;;
  *)
    echo -e "\n\n${TAB}${IRed}WARNING${IDefault}: Operating System, ${$OSTYPE}, was Not Recognized!\n\n"
    ;;
  esac
}

function brew_uinstall()
{
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
}

function brew_install()
{
    if [[ "windows" == "${os_platform}" ]];
	then
		echo -e " Request to install the brew package manager has been denied.\nThe Brew package manager is not supported on the Windows operating system.\n"
		return 1
	fi
	
    if ! app_installed "brew";
    then
      sudo apt update
      sudo apt-get install build-essential -y
      sudo apt install git -y
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      brew doctor
    fi

	if brew ls --versions $1 > /dev/null; 
	then
	  return 0
	else
	  return 1
	fi
}

function git_pull()
{
    if [[  "on" == "${is_verbose}" ]];
    then
        git pull
    else
        git pull -q
    fi
}

function git_fetch()
{
    if [[  "on" == "${is_verbose}" ]];
    then
        git fetch
    else
        git fetch -q
    fi
}

function abort_shell_execution()
{
    set -e
    exit $1
}

# This function processes the command line options and assigns /updates
# global variables as required by the user.
#
# [deprecated]
function get_command_line_options()
{
   args_count=0
   project_name=$1
   for arg in "${command_line_args[@]}"
   do
       if [[ "-all" == "$arg" || "-a" == "$arg"  ]];
       then
         build_target="Release;Debug"
         args_count=$(( $args_count + 1 ))
       elif [[ "-debug" == "$arg" || "-d" == "$arg"  ]];
       then
         build_target="Debug"
         args_count=$(( $args_count + 1 ))
       elif [[ "-release" == "$arg" || "-r" == "$arg"  ]];
       then
         build_target="Release"
         args_count=$(( $args_count + 1 ))
	   elif [[ "-debug_script" == "$arg" ]];
       then
         debug_script="true"
         args_count=$(( $args_count + 1 ))
       elif [[ "-v" == "$arg" || "-verbose" == "$arg" ]];
       then
         is_verbose=on
         output_target="/dev/stdout"
         args_count=$(( $args_count + 1 ))
       elif [[ "-g" == "$arg" || "-generate" == "$arg" ]];
       then
         generate_projects_from_cmake="generate"
         rm -rf "${BUILD_DIR}" #2> /dev/null
         args_count=$(( $args_count + 1 ))
       elif [[ "-u" == "$arg" || "-update" == "$arg" ]];
       then
          is_setup_mode=true
          args_count=$(( $args_count + 1 ))
       elif [[ "-setup" == "$arg" || "--setup" == "$arg" ]];
       then
          #
          # Everything is enabled in setup mode
          #
          is_setup_mode=true
          is_verbose=on
          build_target="Release;Debug"
          generate_projects_from_cmake="generate"
          output_target="/dev/stdout"
          args_count=$(( $args_count + 1 ))
       elif [[ "-h" == "$arg" || "--h" == "$arg" ]];
       then
         show_help=true
       fi
   done
   
    # Show help when the user has not provided any arguments on the command line.
    #
    if [[  "true" == "${show_help}" || "0" == "${args_count}" ]];
    then
        help
    fi

   return "${args_count}"
}

reset_build_time()
{
  # Note: 'SECONDS' is a bash shell feature.
  #
  SECONDS=0
  total_build_time=0
}

publish_build_time()
{
  a=SECONDS
  b=total_build_time
  total=$((a+b))
  echo -e "${TAB}${IWhite}Build Time: $((total / 60)) minutes and $((total % 60)) seconds.${IDefault}\n"
}

log_total_build_time()
{
  a=SECONDS
  b=total_build_time
  total=$((a+b))
  echo -e "${TAB}${IGreen}$1 Completed;${IWhite}Build Time: $((total / 60)) minutes and $((total % 60)) seconds.${IDefault}\n"
  echo -e "\tTotal Build Time: $((total)) seconds" >> build-time-tracking.log
}

# [deprecated]
function set_supported_project_ide()
{
    # Checks for various versions of visual studio that are used
    # by CMake when generating projects on windows.
    #
    # Only the default install paths are used. If you install VS in other places on 
    # your system then you will need to update these paths.
    #
    if [[ "${os_platform}" == *"windows"* ]];
    then
        if [[ $BuildPlatform == *"Visual Studio 16"* && -d  "C:\Program Files (x86)\Microsoft Visual Studio\2019" ]];
        then
            echo -e "Using Visual Studio 19..."
        elif [[ -d  "C:\Program Files (x86)\Microsoft Visual Studio\2017" ]];
        then
            BuildPlatform="Visual Studio 15 2017 Win64"
        elif [[ -d  "C:\Program Files (x86)\Microsoft Visual Studio\2015" ]];
        then
            BuildPlatform="Visual Studio 14 2015 Win64"
        else
            echo -e "---Visual Studio is required but was not found!\nThe CMake generators on your system are:\n"
            CMake -help-command -G
            echo -e "---Modify this script to use one of the installed project generators supported on your system."
            exit 0
        fi
        echo -e " Preparing to generate projects for '${BuildPlatform}'..."
    else
        echo -e "${IYellow} CMake IDE suppprt  for the ${os_platform} OS is not implemented."
        exit 0      
    fi
}

# [deprecated]
function set_build_environment()
{
    BUILD_DIR="${SOURCE_DIR}/_build/${BuildFolderName}"
    SOURCE_DIR="${SOURCE_DIR}" 
}

# [deprecated]
function build_debug()
{
	echo -e " ${IYellow}- Building Debug${IDefault}"
	cmake --build "$BUILD_DIR" --config "Debug" > $output_target
	report_build_time
}

# [deprecated]
function build_release()
{
	echo -e " ${IYellow}- Building Release${IDefault}"
	cmake --build "$BUILD_DIR" --config "Release" > $output_target
	report_build_time
}

# [deprecated]
function build_projects_using_cmake()
{
    # If build target (Debug, Release, or both) is empty then the user
    # just wants to generate and not build.
    #
    if [[  -z "${build_target}" ]];
    then
        return 0
    fi

    echo -e "\n ${IYellow}Building Projects:${IDefault}"
    initialize_build_time
    if [[ "Release;Debug" == "${build_target}" ]]; then
		build_release
		build_debug 
    elif [[ "Release" == "${build_target}" ]]; then
		build_release
    elif [[ "Debug" == "${build_target}" ]]; then
		build_debug
    fi

    report_total_build_time
}

# [deprecated]
function generate_visual_studio_projects_from_cmake()
{ 
    if [[ "generate" == "${generate_projects_from_cmake}" ]]; 
    then
        echo -e "${TAB}${IYellow}Generating Projects..."
		echo -e "${TAB}${ICyan}Build Platform: $BuildPlatform"
		echo -e "${TAB}PROJECT_SOURCE_DIR: $PROJECT_SOURCE_DIR${IDefault}"
		sleep 1
		
        # Note:
        #  Starting with VS 16 on Windows CMake requires an additional build flag (i.e. '-A' for architecture):
        #
        if [[ "${BuildPlatform}" == *"Visual Studio 16"* ]];
        then
            cmake -G"$BuildPlatform" -A "${Architecture}" -B"${BUILD_DIR}" -S"${PROJECT_SOURCE_DIR}" "-DCMAKE_CONFIGURATION_TYPES:STRING=Release;Debug"> $output_target
        else
            cmake -G"${BuildPlatform}" -B"${BUILD_DIR}" -S"${PROJECT_SOURCE_DIR}" "-DCMAKE_CONFIGURATION_TYPES:STRING=Release;Debug"> $output_target
        fi
    fi
}

# [deprecated]
function initialize_cmake_build_environment()
{
    system_os
    check_if_admin
    get_command_line_options
    set_build_environment
    set_supported_project_ide
    #
    # Create the build directory where projects will be generated
    #
    mkdir -p  "${BUILD_DIR}"
}

# TODO: An attempt at creating a spinner (not tested)...(see wait_spinner for example)
#
spin_pid=$!
function start_spinner()
{
  tput civis -- invisible
  local i sp n
  sp='/-\|'
  n=${#sp}
  printf ' '
  while sleep 0.1; do
      printf "%s\b" "${sp:i++%n:1}"
  done
}

function stop_spinner()
{
  kill "$spin_pid" # kill the spinner
  tput cnorm -- normal
  printf " \b"
  echo -n
  echo
}

function wait_spinner()
{
  echo -e  -n "${IYellow}$1"
  start_spinner &
  spin_pid=$!
  disown $spin_pid
}

# Always call the following when sourcing this file.
#
system_os
