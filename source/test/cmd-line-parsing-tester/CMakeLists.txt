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
cmake_minimum_required(VERSION 3.18...3.24)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
   cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

# Must be called prior to a project being defined.
#
CMAKE_POLICY(SET CMP0091 NEW)

PROJECT("cpp-argv-parser"
		VERSION 1.0
		DESCRIPTION "A test for the header only cpp-argv-parser library."
		HOMEPAGE_URL "https://github.com/wsberry"
		LANGUAGES CXX)

LIST(APPEND CMAKE_MODULE_PATH "${SLX_ROOT_INCLUDE_DIR}/cmake")
include(cpp-options)

# Generate versioning header.
#
configure_file(
   "${SLX_ROOT_INCLUDE_DIR}/slx/version.h.in"
   "${SLX_ROOT_INCLUDE_DIR}/slx/version.hh"
)

FILE(GLOB include_sources "${SLX_ROOT_INCLUDE_DIR}/slx/*.hh")
FILE(GLOB project_sources "./*.c*")
ADD_EXECUTABLE(${PROJECT_NAME} ${project_sources} ${include_sources})
disable_build_warnings("${PROJECT_NAME}")



