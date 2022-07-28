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

include(cpp-tools)

SET(DEPENDENCY_DIR "${CMAKE_BINARY_DIR}/_deps")

macro (target_link_catch2 your_project_name version)
	FIND_PACKAGE(Catch2 "${version}" REQUIRED)
	target_link_libraries(${your_project_name} Catch2::Catch2WithMain)
	#target_link_libraries(${your_project_name} PRIVATE Catch2::Catch2)
endmacro()

macro (target_link_boost_ut your_project_name)
	find_package(ut REQUIRED)
	target_link_libraries(${your_project_name} PRIVATE Boost::ut)
endmacro()

macro(install_packages)
	
	#TODO: 
	# https://github.com/zeromq/ingescape
	# https://github.com/zeromq/zyre
	# "https://github.com/lz4/lz4.git"
	# "https://github.com/lemire/fast_double_parser.git"
	# "https://github.com/bernedom/SI.git"
	# "https://github.com/HowardHinnant/date.git"  # Note: to become part of the C++ 20 standard
	# "https://github.com/mariusbancila/stduuid.git" # Note: to become part of the C++ 20 standard

	install_repo("https://github.com/fmtlib/fmt.git" "master" "${DEPENDENCY_DIR}/fmtlib" "FmtLib")
	
	install_repo("https://github.com/samhocevar/portable-file-dialogs.git" "main" "${DEPENDENCY_DIR}/pfd" "Portable File Dialogs")
	if (EXISTS "${DEPENDENCY_DIR}/pfd")
		add_definitions(-DUSE_PORTABLE_DIALOGS)
	endif()

	install_repo("https://github.com/boost-ext/ut.git" "master" "${DEPENDENCY_DIR}/ut" "μ(micro)/Unit Testing Framework")
	
endmacro()

function(install_dependencies)
	include_directories("include")
	MESSAGE(STATUS "\nSearching for Packages...")
	remove_dependency_module()
	install_packages()
	include(dependency-includes)
	enable_inter_procedural_optimizations()
	show_project_include_directories()
endfunction()

