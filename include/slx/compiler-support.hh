#pragma once

#ifndef COMPILER_SUPPORT_HH__
#define COMPILER_SUPPORT_HH__

// ----------------------------------------------------------------------------------------
// Copyright (c) William Berry
// email: wberry.cpp@gmail.com
// github: https://github.com/wsberry
//
// Licensed under the Apache License, Version 2.0 (the "License");
// You may freely use this source code and its projects in compliance with the License.
//
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License src distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------------------

// TODO: Under Construction.

// Deprecated symbols markup
#if (defined(__cplusplus) && __cplusplus >= 201402L)
#define slx_deprecated(msg) [[deprecated(msg)]]
#endif

#ifdef __GNUC__
    //
    // Suppress portable file dialog warnings and Boost UT warnings
    // when compiling with GCC.
    //
#   pragma GCC diagnostic ignored "-Wunused-variable"
#   pragma GCC diagnostic ignored "-Wshadow"
#endif

#ifdef USE_PORTABLE_DIALOGS
#if defined __has_include
#   if __has_include (<portable-file-dialogs.h>)
constexpr bool has_portable_file_dialogs = true;
#       include <portable-file-dialogs.h>
#   else
        constexpr bool has_portable_file_dialogs = false;
#   endif
#else
#   ifdef USE_PORTABLE_DIALOGS
        constexpr bool has_portable_file_dialogs = true;
#       include <portable-file-dialogs.h>
#   else
        constexpr bool has_portable_file_dialogs = false;
#   endif
#endif
#endif

#endif // COMPILER_SUPPORT_HH__
