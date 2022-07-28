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
# About: Defines GCC related compiler flags that are typically used on Linux OS
# -----------------------------------------------------------------------------------------

macro(standard_linux_build_options)

	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		MESSAGE(STATUS "Importing GCC Compiler Settings...")
	else()
		return()
	endif()

	# Enable build caching, but only if the necessary program is installed
	find_program(CCACHE_PROGRAM ccache)
	if(CCACHE_PROGRAM)
		set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
	endif()

	# Throw a warning if a linked library is unused
	if(NOT CMAKE_LINK_WHAT_YOU_USE)
		set(CMAKE_LINK_WHAT_YOU_USE TRUE CACHE STRING "Choose whether to only link libraries which contain symbols actually used by the target." FORCE)
	endif()

    # When creating a shared object, it will cause the link to fail if  there are unresolved symbols.
	# Error if there are any undefined symbols in the output binaries.
	# See: https://stackoverflow.com/a/1671205
	#
	add_link_options("LINKER:-z,defs")

	add_definitions(-DCOMPILER_SUPPORTS_FILESYSTEM)

	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		# GCC 9.+ Supports PMR
		if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_GREATER "9")
			add_definitions(-DCOMPILER_SUPPORTS_PMR)
		else()
			MESSAGE("\nWARNING: This GCC compiler version does not support PMR!\nPMR related library features will be disabled.\n")
		endif()
	endif()

	MESSAGE("Using ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION} with C++${CMAKE_CXX_STANDARD}")

	# SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--stack,100000")

	add_definitions(-DCOMPILER_GCC -DPLATFORM_LINUX -DENDIAN_IS_LITTLE)

endmacro(standard_linux_build_options)
