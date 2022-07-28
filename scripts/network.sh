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

# Implements functions to test for a network/vpn connection.

# Set to false if you do not want status information to
# be published to stdout.
#
no_stdcout="true"
is_network_connected="false"

function show_connections_help
{
  clear
connections_help_page="
\n${IWhite}  Function Examples${IDefault}
\n\t
\n\t       Set 'no_stdcout' to ${ICyan}false${IDefault} to suppress information output. '${ICyan}true${IDefault}' is
\n\t       the default for 'no_stdcout'.
\n\t
\n\t       The following will abort the scripting process if it fails to connect to the given URL:
\n\t       require_connection \"https://cppcon.org/\"
\n\t
\n\t       if any_connection_available \"https://github.com/wsberry\" \"www.google.com\" \"https://cppcon.org/\";
\n\t	      then
\n\t          ... Do something
\n\t	      else
\n\t          ... Do something else
\n\t	      fi
\n\t
\n\t       if connection_available \"https://github.com/wsberry\" ;
\n\t	      then
\n\t          ... Do something
\n\t	      else
\n\t          ... Do something else
\n\t	      fi
\n\t
\n\t       any_connection_available \"https://github.com/wsberry\" \"www.google.com\" \"https://cppcon.org/\";
\n\t       connection_available \"www.google.com\"
\n\t       connection_available \"https://github.com/wsberry\"
\n\t       if [[ \"true\" == ${is_network_connected} ]];
\n\t       then
\n\t           ... Do Something
\n\t       fi
${IDefault}
\n\n
"
echo -e $connections_help_page
set -e
exit 0
}

# Function Examples
#
#    Set 'no_stdcout' to false to suppress information output. 'true' is
#    the default for 'no_stdcout'.
#
#    require_connection "https://cppcon.org/" # exits process if connection is not available
#
#    if any_connection_available "https://github.com/wsberry" "www.google.com" "https://cppcon.org/";
#	   then
#       ... Do something
#	   else
#       ... Do something else
#	   fi
#
#    if connection_available "https://github.com/wsberry" ;
#	   then
#       ... Do something
#	   else
#       ... Do something else
#	   fi
#
#    any_connection_available "https://github.com/wsberry" "www.google.com" "https://cppcon.org/";
#    connection_available "www.google.com"
#    connection_available "https://github.com/wsberry"
#    if [[ "true" == ${is_network_connected} ]];
#    then
#        ... Do Something
#    fi
#
# TODO: 
#    Re-write function logic and remove while loop logic by moving the processing into the for loop.
#
function have_network_connection()
{
  pids=""
  processes="0"
  test_urls="$1 $2 $3"
  is_network_connected="false"

 echo -e "${IYellow}Checking Connections:${IDefault}"
  for test_url in $test_urls; do
    if [[ "true" == "${no_stdcout}" ]];
    then
      echo -e " - ${IYellow}'$test_url'${IDefault}"
    fi
    curl --silent --head "$test_url" > /dev/null &
    pids="$pids $!"
    processes=$(($processes + 1))
  done

  found_connection="false"

  while [ $processes -gt 0 ]; do
    for pid in $pids; do
      if ! ps | grep "^[[:blank:]]*$pid[[:blank:]]" > /dev/null; then
        # Process no longer running
        index=$(($processes))
        processes=$(($processes - 1))
        pids=$(echo "$pids" | sed -E "s/(^| )$pid($| )/ /g")

        if wait $pid;
        then
          # Success! 
          # We have at least one connection:
          # kill -s SIGQUIT -TERM $pids > /dev/null 2>&1 || true
          wait $pids
          found_connection="true"
        fi
      fi
    done
    sleep 0.1  # wait -n $pids Better than sleep, but not supported on all systems
  done

  # Only one address is required for success, but all the addresses
  # provided are tested.
  #
  if [[ "true" == "${found_connection}" ]];
  then
      return 0
  fi

  return 1
}

function require_connection()
{
  if have_network_connection "$1";
  then
    is_network_connected="true"
    if [[ "true" == "${no_stdcout}" ]];
    then
      echo -e " ${IYellow}Found Connection: '$1'...${IGreen}Success!${IDefault}"
    fi
    return 0
  fi
  if [[ "true" == "${no_stdcout}" ]];
  then
    echo -e "\n${IRed} ERROR${IDefault}: ${IYellow}A connection is required but was not found for '$1'!${IDefault}\n Aborting script process...\n"
  fi
  set -e
  exit 1
}

function connection_available()
{
  if have_network_connection "$1";
  then
    is_network_connected="true"
    if [[ "true" == "${no_stdcout}" ]];
    then
      echo -e "${IYellow}Found Connection: '$1'...${IGreen}Success!${IDefault}"
    fi
    return 0
  fi
  if [[ "true" == "${no_stdcout}" ]];
  then
    echo -e "${IRed} WARNING${IDefault}: ${IYellow}A Connection was not found for '$1'!${IDefault}"
  fi
  return 1
}

function any_connection_available()
{
	   if have_network_connection "$1" "$2" "$3";
	   then
        if [[ "true" == "${no_stdcout}" ]];
        then
          echo -e "${IYellow}Found Connection...${IGreen}Success!${IDefault}"
        fi
        is_network_connected="true"
        return 0
	   fi
     if [[ "true" == "${no_stdcout}" ]];
     then
       echo -e "${IRed} WARNING${IDefault}: ${IYellow}A Connection was Not Found!${IDefault}"
     fi
	   return 1
}
