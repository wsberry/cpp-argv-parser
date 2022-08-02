cmake_minimum_required(VERSION 3.18...3.24)
if(${CMAKE_VERSION} VERSION_LESS 3.12)
   cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()

# Must be called prior to a project being defined.
#
CMAKE_POLICY(SET CMP0091 NEW)

# Compiler ID gets generated here by cmake:
#
PROJECT("cpp-argv-parser"
		VERSION 1.0
		DESCRIPTION "A test for the header only cmd-line-parsing library."
		HOMEPAGE_URL "https://github.com/wsberry"
		LANGUAGES CXX
)

SET(SLX_ROOT_DIR  ${PROJECT_SOURCE_DIR})
SET(SLX_ROOT_SOURCE_DIR  ${PROJECT_SOURCE_DIR}/source)
SET(SLX_ROOT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(cpp-options)
install_dependencies()

option(USE_PORTABLE_DIALOGS "Builds the test project with Portable Dialogs." OFF)

if (CMAKE_CXX_STANDARD VERSION_GREATER_EQUAL "20")
	option(ENABLE_BOOST_UT_MODULE "Enable (Default is OFF) Boost UT Framework C++ 20 Module Features" ON)
else()
	option(ENABLE_BOOST_UT_MODULE "Enable (Default is OFF) Boost UT Framework C++ 20 Module Features" OFF)
endif()

IF (ENABLE_BOOST_UT_MODULE)
	add_definitions(-DENABLE_BOOST_UT_MODULE)
	
	if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
	     add_definitions(-DBOOST_UT_DISABLE_MODULE)
	endif()
	
ENDIF()

MESSAGE(STATUS "Compiling with ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION} using C++ standard version ${CMAKE_CXX_STANDARD}")

IF (USE_PORTABLE_DIALOGS)
	add_definitions(-DUSE_PORTABLE_DIALOGS)
	MESSAGE(WARNING "USE_PORTABLE_DIALOGS is ON. This option should be turned OFF when running in a continuous integration (CI) environment!")
ENDIF()

# Note:
# To add or remove dependencies modify the 'dependencies.cmake' file
# in the `./cmake` folder.

# Add your projects here:
#
add_subdirectory("./source/test/cmd-line-parsing-tester")
