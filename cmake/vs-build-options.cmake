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
#	Contains functions and macros to help with the creation of CMake scripts.
# -----------------------------------------------------------------------------------------

macro(standard_visual_studio_options)

	if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		MESSAGE(STATUS " Importing Default Visual Studio Compiler Settings...")
	else()
		return()
	endif()

	if (NOT DEFINED CXX_RTTI)
		option(CXX_RTTI "Enable or disable C++ RTTI." ON)
	endif()

	if (NOT DEFINED MAKE_WIN32_LEAN_AND_MEAN)
		option(MAKE_WIN32_LEAN_AND_MEAN "Minimize what <windows.h> imports and defines." ON)
	endif()

	if (NOT DEFINED ADD_BIG_OBJ)
		option(ADD_BIG_OBJ "Increases the number of sections that an object file can contain." OFF)
	endif()
	
    if (NOT DEFINED ADD_EHsc)
		option(ADD_EHsc "Catch C++ exceptions only and assume functions declared as extern 'C' never throw exceptions." ON)
	endif()
	
    # SET your warnings here: 
	# Warning form is: '/wd{warning number}' E.g. /wd4405
	#
    LIST(APPEND warnings "/W3 /wd4100 /wd4116 /wd4127 /wd4244 /wd4305 /wd4334 /wd4715 /wd4789 /wd4146 /wd4996 /WX /EHsc")

	# Why these warnings:
	#
	# From Google gRPC Build: 
	#   C4116: unnamed type definition in parentheses
    #   C4146: unary minus operator applied to unsigned type, result still unsigned
	#   C4334: result of 32-bit shift implicitly converted to 64 bits (was 64-bit shift intended?) 
	#   C4715: 'upb_encode_scalarfield': not all control paths return a value
	#   C4789: buffer 'ret' of size 8 bytes will be overrun; 16 bytes will be written starting at offset 0
	
	if (MAKE_WIN32_LEAN_AND_MEAN)
		add_definitions(-DWIN32_LEAN_AND_MEAN -DVC_EXTRALEAN)
    endif()
	
	if(ADD_EHsc)
	     # /EHsc), catches C++ exceptions only and tells the compiler to assume that functions declared 
		 # as extern "C" never throw a C++ exception. 
		 #
		add_compile_options(/EHsc)
	endif()
	
	if (ADD_BIG_OBJ)
		add_compile_options(/bigobj)
	endif()
		
	if (NOT CONFIGURED)
	   
		SET(CONFIGURED ON)
		  
		# CXX
		#
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${warnings}"
			CACHE STRING "Flags used by the compiler during all build types." FORCE)

		# C
		#
		SET(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} ${warnings}"
			CACHE STRING "Flags used by the compiler during all build types." FORCE)
					
	endif()
    
    if (WIN32)
      add_definitions("/std:c++${CPP_VERSION_TO_COMPILE_TO}")
    endif()
	
	if (CXX_RTTI)
	    #
		# Enable RTTI
		#
		add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/GR>")
		message(STATUS "${TAB}- RTTI has been enabled.")
	else()
	    message("${TAB}- RTTI is disabled.")
	endif(CXX_RTTI)
	
	if (NOT CONFIGURED)
   
      SET(CONFIGURED ON)
      
		# CXX
		#
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${warnings}"
			CACHE STRING "Flags used by the compiler during all build types." FORCE)

		# C
		#
		SET(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} ${warnings}"
			CACHE STRING "Flags used by the compiler during all build types." FORCE)
				
	endif()


	if( ${CMAKE_CXX_STANDARD} GREATER_EQUAL "17")
		add_definitions(-DCOMPILER_SUPPORTS_PMR)
	else()
		MESSAGE("\nWARNING: This compiler version does not support PMR!\nPMR related library features will be disabled.\n")
	endif()
   
    add_definitions (
			-DEXPERIMENTAL_CODE

	        # Since Visual Studio is be used the Windows Platform is Assumed.
			#
	        -DPLATFORM_WINDOWS
			
			# Windows is little endian
			#
			-DENDIAN_IS_LITTLE 
    
            # IF BOOST is used then it calls  several potentially unsafe methods in the C++ Standard Library. This 
            #  results in Compiler Warning (level 3) C4996 in Visual Studio. To disable this warning the
            #  macro '_SCL_SECURE_NO_WARNINGS' is defined.
            #
            # '#pragma warning(disable:4996) ' may also be used to disable this warning on the Windows OS.
            #
            -D_SCL_SECURE_NO_WARNINGS

            # Remove Debug CRT Deprecate Warnings
            #
            -D_CRT_SECURE_NO_DEPRECATE    

            # enables template overloads of standard CRT functions that auto call more secure variants
            #
            -D_CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES             
            -D_CRT_SECURE_NO_WARNING

            # thread safe (i.e. re-entrant) versions
            #
            -D_REENTRANT			

            # For other optimizations see: 
			#  https://docs.microsoft.com/en-us/cpp/build/reference/o-options-optimize-code?view=vs-2019			

            # Note:
            #  Programs that use intrinsic functions are faster because they do not 
            #  have the overhead of function calls, but may be larger because of the
            #  additional code created.
            #
            #  see: https://docs.microsoft.com/en-us/cpp/build/reference/oi-generate-intrinsic-functions
            #       There are specific x86 (compared to x64) behaviors when using this feature.
            # 
            -Oi	

            # Note: 
            #
            # -Ob[2]
            #
            # The default value, 2, allows expansion of functions marked as inline,
            # __inline, or __forceinline, and any other function that the compiler
            # chooses.
            #
            # see: https://docs.microsoft.com/en-us/cpp/build/reference/ob-inline-function-expansion
            -Ob2

            # -MP[n] If you omit the processMax argument, the compiler retrieves the number 
            # of effective processors on your computer from the operating system, and 
            # creates a process for each processor. This generally reduces the build time, but
            # may increase the build time with some Visual Studio solution configurations.
            #
            -MP

            # Note:
            #
            # Math Constants are not defined in Standard C/C++. 
            # To use them, you must first define _USE_MATH_DEFINES and 
            # then include cmath or math.h.
            #
            # see: https://docs.microsoft.com/en-us/cpp/c-runtime-library/math-constants
            #
            -D_USE_MATH_DEFINES		

            # Windows' Platform Misc Macros:
            #
            -DWIN32   			# required even for x64
            -D_WINDOWS			# required even for x64
            -DGUID_WINDOWS      # required if windows native GUID generator
			-DHOST_LIBRARY_WIN32
	)
	
	# Platform Specific Library Groupings
	#
	set(platform_libraries_group
		"shcore.lib"
		"ws2_32.lib"
		"Secur32.lib"
		"Rpcrt4.lib"
	)
	
	# CMAKE_MSVC_RUNTIME_LIBRARY Options (i.e., chooses the C/C++ runtime to link against.
	#
	# MultiThreaded
	#    Compile with -MT or equivalent flag(s) to use a multi-threaded statically-linked runtime library.
	#
	# MultiThreadedDLL
	#    Compile with -MD or equivalent flag(s) to use a multi-threaded dynamically-linked runtime library.
	#
	# MultiThreadedDebug
	#    Compile with -MTd or equivalent flag(s) to use a multi-threaded statically-linked runtime library.
	#
	#  [Default] MultiThreadedDebugDLL
	#    Compile with -MDd or equivalent flag(s) to use a multi-threaded dynamically-linked runtime library.
	#
	SET(CMAKE_MSVC_RUNTIME_LIBRARY_OPTIONS  "MultiThreadedDebugDLL" CACHE STRING  "MSVC Runtime Library Flags.")
    SET_PROPERTY(CACHE CMAKE_MSVC_RUNTIME_LIBRARY_OPTIONS PROPERTY STRINGS "MultiThreadedDebugDLL;MultiThreadedDebug;MultiThreadedDLL;MultiThreaded")
    SET(CMAKE_MSVC_RUNTIME_LIBRARY ${CMAKE_MSVC_RUNTIME_LIBRARY_OPTIONS})
	
	#SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /STACK:100000")
	
endmacro(standard_visual_studio_options)
