#pragma once

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
// 
// About:
//  Implements Unit Tests for cpp-argv-parser
// -----------------------------------------------------------------------------------------

#include <array>
#include <fstream>
#include <set>
#include <cstdlib>
#include <chrono>
#include <fmt/format.h>
#include <thread>

// DISABLE_BOOST_UNIT_TESTS will be defined when a given compiler version
// will not support it.
//
#ifndef DISABLE_BOOST_UNIT_TESTS
#   include <boost/ut.hpp>
#else
    // TODO: Use Catch2 version 3 ?
#endif

#include <slx/cmd-line-parsing.hh>

// A data model used for mark down log file output.
//
struct test_result_t final
{
    bool succeeded{};
    std::string_view msg{};
    void reset() { succeeded = false; }
};

// Misc. Helper Functions.
//
inline void init();
inline void exit_handler();
inline void create_log_report_result(const std::string_view msg);
inline std::string create_msg(const std::string_view msg, bool success);



