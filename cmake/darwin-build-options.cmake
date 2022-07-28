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
# About: Defines CLang related compiler flags that are typically used on macOS
# -----------------------------------------------------------------------------------------

macro(standard_apple_clang_build_options)

	if (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
		MESSAGE(STATUS "Importing Apple Clang Compiler Settings...")
	else()
		return()
	endif()

	# Enable build caching, but only if the necessary program is installed
	find_program(CCACHE_PROGRAM ccache)
	if(CCACHE_PROGRAM)
		set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
	endif()

endmacro(standard_apple_clang_build_options)
