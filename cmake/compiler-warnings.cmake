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
# Original Source:  https://github.com/tasmith/cpp_starter
# -----------------------------------------------------------------------------------------

cmake_policy(SET CMP0022 NEW)

# On MacOS use @rpath/ for target's install name prefix path
if (POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)
endif ()

# Clear VERSION variables when no VERSION is given to project()
if(POLICY CMP0048)
  cmake_policy(SET CMP0048 NEW)
endif()

# MSVC runtime library flags are selected by an abstraction.
if(POLICY CMP0091)
  cmake_policy(SET CMP0091 NEW)
endif()

# Call 'target_compile_options' after 'add_executable', 'add_library', etc.
# when using this macro
#
# Example:
#   set_project_warnings()
#	.
#	.
#	.
#	target_compile_options(${PROJECT_NAME} PRIVATE ${PROJECT_WARNINGS})
#
macro(set_project_warnings)
	option(WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

	set(MSVC_WARNINGS
			/W4 # Baseline reasonable warnings
			/w14242 # 'identifier': conversion from 'type1' to 'type1', possible loss of data
			/w14254 # 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
			/w14263 # 'function': member function does not override any base class virtual member function
			/w14265 # 'classname': class has virtual functions, but destructor is not virtual instances of this class may not
			# be destructed correctly
			/w14287 # 'operator': unsigned/negative constant mismatch
			/we4289 # nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside
			# the for-loop scope
			/w14296 # 'operator': expression is always 'boolean_value'
			/w14311 # 'variable': pointer truncation from 'type1' to 'type2'
			/w14459 # warning C4459: declaration of 'type' hides global declaration
			/w14545 # expression before comma evaluates to a function which is missing an argument list
			/w14546 # function call before comma missing argument list
			/w14547 # 'operator': operator before comma has no effect; expected operator with side-effect
			/w14549 # 'operator': operator before comma has no effect; did you intend 'operator'?
			/w14555 # expression has no effect; expected expression with side- effect
			/w14619 # pragma warning: there is no warning number 'number'
			/w14640 # Enable warning on thread un-safe static member initialization
			/w14826 # Conversion from 'type1' to 'type_2' is sign-extended. This may cause unexpected runtime behavior.
			/w14905 # wide string literal cast to 'LPSTR'
			/w14906 # string literal cast to 'LPWSTR'
			/w14928 # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
			/permissive- # standards conformance mode for MSVC compiler.
			)

	set(CLANG_WARNINGS
			-Wall
			-Wextra # reasonable and standard
			-Wshadow # warn the user if a variable declaration shadows one from a parent context
			-Wnon-virtual-dtor # warn the user if a class with virtual functions has a non-virtual destructor. This helps
			# catch hard to track down memory errors
			-Wold-style-cast # warn for c-style casts
			-Wcast-align # warn for potential performance problem casts
			-Wunused # warn on anything being unused
			-Woverloaded-virtual # warn if you overload (not override) a virtual function
			-Wpedantic # warn if non-standard C++ is used
			#-Wconversion # warn on type conversions that may lose data
			#-Wsign-conversion # warn on sign conversions
			-Wnull-dereference # warn if a null dereference is detected
			-Wdouble-promotion # warn if float is implicit promoted to double
			-Wformat=2 # warn on security issues around functions that format output (ie printf)
			)

	if(WARNINGS_AS_ERRORS)
		set(CLANG_WARNINGS ${CLANG_WARNINGS} -Werror)
		set(MSVC_WARNINGS ${MSVC_WARNINGS} /WX)
	endif()

	set(GCC_WARNINGS
			${CLANG_WARNINGS}
			-Wmisleading-indentation # warn if indentation implies blocks where blocks do not exist
			-Wduplicated-cond # warn if if / else chain has duplicated conditions
			-Wduplicated-branches # warn if if / else branches have duplicated code
			-Wlogical-op # warn about logical operations being used where bitwise were probably wanted
			#
			# This is non consistent across various compilers.
			#
			#-Wuseless-cast # warn if you perform a cast to the same type
			)

	if(MSVC)
		MESSAGE(STATUS "Setting MSVC_WARNINGS.")
		set(PROJECT_WARNINGS ${MSVC_WARNINGS})
	elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
		MESSAGE(STATUS "Setting CLANG_WARNINGS.")
		set(PROJECT_WARNINGS ${CLANG_WARNINGS})
	elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		MESSAGE(STATUS "Setting GCC_WARNINGS.")
		set(PROJECT_WARNINGS ${GCC_WARNINGS})
	else()
		message(AUTHOR_WARNING "**** No compiler warnings set for '${CMAKE_CXX_COMPILER_ID}' compiler. ****")
	endif()

endmacro(set_project_warnings)

macro (disable_build_warnings the_project_name)
	set_project_warnings()
	target_compile_options(${the_project_name} PRIVATE ${PROJECT_WARNINGS})
endmacro(disable_build_warnings)



