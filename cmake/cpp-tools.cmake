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
#	Implements functions and macros to assist in creating CMake project scripts.
#
# TODO:
#   Document this file!!!
# -----------------------------------------------------------------------------------------

# Call this function if Git is SCM is required.
#
function(require_git)
	find_package(Git)
	IF (NOT GIT_FOUND)
		message(FATAL_ERROR " - Error: Git is required for the projects being generated. (see: https://git-scm.com/).")
	ENDIF()
endfunction()

# Find a substring and replace it with another.
#
macro(replace_substring string_to_find string_to_replace string_to_search string_result)
	#
	# E.g., replace_substring("/deps"  "/_deps" "${CMAKE_CURRENT_BINARY_DIR}" DEPS_DIR)
	#
	string(FIND "${string_to_search}" "${string_to_find}" pos)
	IF (pos GREATER_EQUAL 0)
		string(REPLACE "${string_to_find}"  "${string_to_replace}" "${string_result}" "${string_to_search}")
	ENDIF()
endmacro()

# Create a CMake module that defines the paths to the installed dependency include file.
# 
# The contents for this file will be generated in by 'install_repo' function
# defined below.
#
SET(dependency_module_path "${CMAKE_BINARY_DIR}/_cmake/dependency-includes.cmake")
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/_cmake")

# Use to exclude a dependency module path.
#
function(remove_dependency_module)
	IF (EXISTS "${dependency_module_path}")
		FILE(REMOVE "${dependency_module_path}")
	ENDIF()
endfunction()

# Install/Clone a Git Repo
#
function(install_repo url branch_name install_path caption)

	require_git()

	IF (NOT EXISTS "${dependency_module_path}")
		FILE(WRITE "${dependency_module_path}" "# Warning: Generated CMake File. DO NOT EDIT\n#")
	ENDIF()

	IF (NOT EXISTS "${install_path}")
		#
		# Notes:
		# 1. If there are not any submodules then the "--recurse-submodules" flag will be ignored.
		# 2. The "--single-branch" command clones only the specified branch. If you need to work
		#    with other branches in a repo then uncheck the option defined below.
		#
		option(GIT_INCLUDE_SINGLE_BRANCH_ONLY "clone only the specified branch (uses git --single-branch flag)" ON)

		IF (GIT_INCLUDE_SINGLE_BRANCH_ONLY)
			execute_process(COMMAND "git" "clone" "--single-branch" "--recurse-submodules" "-b" "${branch_name}" "${url}" "${install_path}")
		ELSE()
			execute_process(COMMAND "git" "clone" "--recurse-submodules" "-b" "${branch_name}" "${url}" "${install_path}")
		ENDIF()

		IF (NOT EXISTS "${install_path}")
			message(FATAL_ERROR "Required dependency, '${install_path}', Not Found!")
		ENDIF()
	ELSE()
		message(STATUS " - Found ${caption} Library.")
	ENDIF()

	# Some repositories do not follow the convention of having an 'include' directory.
	# For these cases the ${install_path} is included, but sometimes neither of the following
	# will be sufficient. If only all us always followed the same conventions :)
	#
	FILE(APPEND "${dependency_module_path}" "\n# ${caption}:")
	FILE(APPEND "${dependency_module_path}" "\ninclude_directories(\"${install_path}\")")
	FILE(APPEND "${dependency_module_path}" "\ninclude_directories(\"${install_path}/include\")\n")
endfunction()

# Show the CMake project output directories as they are defined.
#
function(show_project_output_directories)
	message(STATUS "\nCMake Directory Definitions:")
	message(STATUS " CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")
	message(STATUS " CMAKE_CURRENT_SOURCE_DIR : ${CMAKE_CURRENT_SOURCE_DIR}")
	message(STATUS " CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR}")
	message(STATUS " CMAKE_INSTALL_BINDIR: ${CMAKE_INSTALL_BINDIR}\n")
	message(STATUS " CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR}")
	message(STATUS " RUNTIME_OUTPUT_DIRECTORY : ${RUNTIME_OUTPUT_DIRECTORY}")
	message(STATUS " CMAKE_ARCHIVE_OUTPUT_DIRECTORY : ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
	message(STATUS " CMAKE_LIBRARY_OUTPUT_DIRECTORY : ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
	message(STATUS " CMAKE_RUNTIME_OUTPUT_DIRECTORY : ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}\n")
	message(STATUS " Using ${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION} with C++${CMAKE_CXX_STANDARD}\n")
endfunction()

# Show the project include directories.
#
function(show_project_include_directories)
	message(STATUS "\nProject Defined Include Directories:")
	get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
	foreach(dir ${dirs})
		message(STATUS " - '${dir}'")
	endforeach()
	message(STATUS "\n")
endfunction()

# TODO FIX: This will not work with cmake therefore do something else.
# For consistency define multi-configuration builds, Debug and Release, on Linux and Darwin.
#
macro(generate_debug_and_release_configuration_support)
	SET(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)
	SET(CMAKE_BUILD_TYPE "Debug" CACHE STRING  "Default Build Configuration.")
	SET_PROPERTY(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${CMAKE_CONFIGURATION_TYPES}")
endmacro()

# Much of the code that follows here was created by Jason Turner:
#
# See: https://github.com/suhasghorp/jason-cpp-starter/tree/main/cmake
#
function(tool_enable_doxygen)
	option(ENABLE_DOXYGEN "Enable doxygen doc builds of source" ON)
	if(ENABLE_DOXYGEN)
		set(DOXYGEN_CALLER_GRAPH YES)
		set(DOXYGEN_CALL_GRAPH YES)
		set(DOXYGEN_EXTRACT_ALL YES)
		find_package(Doxygen REQUIRED dot)
		doxygen_add_docs(doxygen-docs ${PROJECT_SOURCE_DIR})
	endif()
endfunction(tool_enable_doxygen)

# These must called after 'add_executable', 'add_library', etc.
#
function(tool_enable_sanitizers project_name)

	if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
		option(ENABLE_COVERAGE "Enable coverage reporting for gcc/clang" FALSE)

		if(ENABLE_COVERAGE)
			target_compile_options(${project_name} INTERFACE --coverage -O0 -g)
			target_link_libraries(${project_name} INTERFACE --coverage)
		endif()

		set(SANITIZERS "")

		option(ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" FALSE)
		if(ENABLE_SANITIZER_ADDRESS)
			list(APPEND SANITIZERS "address")
		endif()

		option(ENABLE_SANITIZER_LEAK "Enable leak sanitizer" FALSE)
		if(ENABLE_SANITIZER_LEAK)
			list(APPEND SANITIZERS "leak")
		endif()

		option(ENABLE_SANITIZER_UNDEFINED_BEHAVIOR "Enable undefined behavior sanitizer" FALSE)
		if(ENABLE_SANITIZER_UNDEFINED_BEHAVIOR)
			list(APPEND SANITIZERS "undefined")
		endif()

		option(ENABLE_SANITIZER_THREAD "Enable thread sanitizer" FALSE)
		if(ENABLE_SANITIZER_THREAD)
			if("address" IN_LIST SANITIZERS OR "leak" IN_LIST SANITIZERS)
				message(WARNING "Thread sanitizer does not work with Address and Leak sanitizer enabled")
			else()
				list(APPEND SANITIZERS "thread")
			endif()
		endif()

		option(ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" FALSE)
		if(ENABLE_SANITIZER_MEMORY AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
			if("address" IN_LIST SANITIZERS
					OR "thread" IN_LIST SANITIZERS
					OR "leak" IN_LIST SANITIZERS)
				message(WARNING "Memory sanitizer does not work with Address, Thread and Leak sanitizer enabled")
			else()
				list(APPEND SANITIZERS "memory")
			endif()
		endif()

		list(
				JOIN
				SANITIZERS
				","
				LIST_OF_SANITIZERS)

	endif()

	if(LIST_OF_SANITIZERS)
		if(NOT "${LIST_OF_SANITIZERS}" STREQUAL "")
			target_compile_options(${project_name} INTERFACE -fsanitize=${LIST_OF_SANITIZERS})
			target_link_libraries(${project_name} INTERFACE -fsanitize=${LIST_OF_SANITIZERS})
		endif()
	endif()

endfunction(tool_enable_sanitizers)

macro(enable_inter_procedural_optimizations)
	#
	# Generate compile_commands.json to make it easier to work with clang based tools
	#
	set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

	# Note:
	# Inter-procedural optimization (IPO) is a collection of compiler techniques used
	# to improve performance in programs containing many frequently used functions
	# of small or medium length. IPO differs from other compiler optimization because
	# it analyzes the entire program; other optimizations look at only a single
	# function, or even a single block of code.
	#
	option(ENABLE_IPO "Enable Inter-procedural Optimization (i.e., Link Time Optimization (LTO))." OFF)

	if(ENABLE_IPO)
		include(CheckIPOSupported)
		check_ipo_supported(RESULT result OUTPUT output)
		
		if(result)
			set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
			message(STATUS " Interprocedural optimizations (IPO) have been enabled.")
		else()
			message(SEND_ERROR " IPO is not supported: ${output}:\n${CMAKE_CXX_COMPILER_ID}  v${CMAKE_CXX_COMPILER_VERSION} using C++ ${CMAKE_CXX_STANDARD}")
		endif()
		
	endif()
endmacro(enable_inter_procedural_optimizations)

macro(enable_static_analyzers)
	option(ENABLE_CPPCHECK "Enable static analysis with cppcheck" OFF)
	option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
	option(ENABLE_INCLUDE_WHAT_YOU_USE "Enable static analysis with include-what-you-use" OFF)

	if(ENABLE_CPPCHECK)
		find_program(CPPCHECK cppcheck)
		if(CPPCHECK)
			set(CMAKE_CXX_CPPCHECK
					${CPPCHECK}
					--suppress=missingInclude
					--enable=all
					--inline-suppr
					--inconclusive
					-i
					${CMAKE_SOURCE_DIR}/imgui/lib)
		else()
			message(SEND_ERROR "cppcheck requested but executable not found")
		endif()
	endif()

	if(ENABLE_CLANG_TIDY)
		find_program(CLANGTIDY clang-tidy)
		if(CLANGTIDY)
			set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY} -extra-arg=-Wno-unknown-warning-option)
		else()
			message(SEND_ERROR "clang-tidy requested but executable not found")
		endif()
	endif()

	if(ENABLE_INCLUDE_WHAT_YOU_USE)
		find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
		if(INCLUDE_WHAT_YOU_USE)
			set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE})
		else()
			message(SEND_ERROR "include-what-you-use requested but executable not found")
		endif()
	endif()
endmacro(enable_static_analyzers)
