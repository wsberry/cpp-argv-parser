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
#
# About:
#	Contains functions and macros to help with the creation of CMake project scripts.
#
# About: Defines C/C++ Standard Options 
# -----------------------------------------------------------------------------------------

include(cpp-tools)
include(compiler-warnings)
include(dependencies)

# Standard C++ version to compile to:
# Start with C++20 but note GCC issues below.
#
SET(CMAKE_CXX_STANDARD "20")

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	# GCC 9.+ Supports PMR
	if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS_EQUAL "9")
		SET(CMAKE_CXX_STANDARD "17")
		MESSAGE(WARNING
				"Boost Unit Tests require a GCC compiler version greater than 9 and have been disabled. "
				"Using ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}.\n"
				)
		add_definitions(-DDISABLE_BOOST_UNIT_TESTS)
	endif()
endif()

SET(CMAKE_CXX_EXTENSIONS OFF)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

SET(CMAKE_C_EXTENSIONS OFF)
SET(CMAKE_C_STANDARD_REQUIRED ON)

SET(DEBUG_POSTFIX_OPTION  "-d" CACHE STRING  "Debug postfix option.")
SET_PROPERTY(CACHE DEBUG_POSTFIX_OPTION PROPERTY STRINGS "-d;_d;-dbg")
SET(CMAKE_DEBUG_POSTFIX ${DEBUG_POSTFIX_OPTION})

if (CMAKE_CXX_STANDARD VERSION_GREATER_EQUAL "14")
	add_definitions (-DCOMPILER_SUPPORTS_FILESYSTEM)
endif()

# My assumption is that all C++ projects will generally include the 'fmt library.
#
#    Note that FmtLib has significantly faster performance than cout,
#    printf, etc. (see https://github.com/fmtlib/fmt for performance
#    benchmarks.
#
#  If std::format is being used then the define below has no effect.
#
add_definitions(-DFMT_HEADER_ONLY)

# Adds a preprocessor macro that assigns the name of the root directory
# of the main project CMakeLists definition.
#
get_filename_component(ROOT_DIR_NAME "${CMAKE_CURRENT_DIR}" NAME)
add_compile_definitions(ROOT_PROJECTS_DIR_NAME="${ROOT_DIR_NAME}")
#string(REPLACE "find this substring" "replace with this" ResultString SourceString)

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	SET(CMAKE_C_COMPILER clang)
	SET(CMAKE_CXX_COMPILER clang++)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -std=c++${CMAKE_CXX_STANDARD_NUMBER} -Wno-multichar")

 elseif (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
	include(darwin-build-options)
	standard_apple_clang_build_options()

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	include(linux-build-options)
	standard_linux_build_options()
	
	#if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
	#	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
	#endif()

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
	# using Intel C++
	MESSAGE(WARNING "  Compiler Options Not Implemented!\n  CMAKE_CXX_COMPILER_ID: '${CMAKE_CXX_COMPILER_ID}'")

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
	include(vs-build-options)
	standard_visual_studio_options()
	
	# Get rid of 'cl : command line warning D9002: ignoring unknown option '/std:c++'  warning
	# on Windows.
	#
	#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++${CMAKE_CXX_STANDARD}")
	
	
else()
	MESSAGE(WARNING "  Compiler Options Not Implemented!\n  CMAKE_CXX_COMPILER_ID: '${CMAKE_CXX_COMPILER_ID}'")
endif()


