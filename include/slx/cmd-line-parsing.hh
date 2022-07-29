#pragma once
#ifndef CMD_LINE_PARSING_HH__
#define CMD_LINE_PARSING_HH__

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

#include "compiler-support.hh"

#include <algorithm>
#include <string>
#include <string_view>
#include <vector>
#include <unordered_map>
#include <iostream>
#include <tuple>
#include <set>

namespace slx {
    /**
     * \brief Stores the parsed results of the commandline. Where the first string is the long form
     *        of the option name and the second string is its value.
     */
    using command_line_options_result_t = ::std::unordered_map<::std::string, std::string>;

    /**
     * \brief Use this container to define the commandline options.
     *
     *        E.g.,
     *        slx::command_line_options_t options{ {"in", "i", true}, {"out", "o", false} };
     *
     *        Where the first string is long form of the option name and the second string
     *        is the short form of the options key. 'bool' is a flag that indicates
     *        if the option is required.
     */
    using command_line_options_t = ::std::vector <std::tuple<std::string, std::string, bool>>;

    /**
     * \brief Internal use only; do not call directly.
     * @return A static non-const pointer to a map of key/value pairs.
     */
    inline command_line_options_result_t *get_command_line_args_() {
        static command_line_options_result_t command_line;
        return &command_line;
    }

   /**
    * TODO: Evaluate...Is the even required. 
    */
    inline void clear_command_line_options() {
        get_command_line_args_()->clear();
    }

    /**
     * \brief Provide global access to the commandline arguments within an application.
     * @return A copy of the command_line_options_result_t, a std::unordered_map.
     */
    inline command_line_options_result_t get_command_line_args() {
        return *get_command_line_args_();
    }

    /**
     * \brief Dumps out the command line args for debugging/viewing.
     */
    template<bool debug_only = false>
    void publish_command_line_args(const int argc, char **argv) {
        if constexpr(debug_only)
        {
#ifndef NDEBUG
            std::cout << " Command Line Args:";
            for (auto i = 0; i < argc; ++i) std::cout << "\n  [" << i << "]: " << argv[i];
            std::cout << "\n" << std::endl;
#endif
        }
        else
        {
            std::cout << " Command Line Args:";
            for (auto i = 0; i < argc; ++i) std::cout << "\n  [" << i << "]: " << argv[i];
            std::cout << "\n" << std::endl;
        }
    }

    /**
    * \brief Dumps out the parsed command line args for debugging/viewing.
    */
    template<bool debug_only = false>
    void publish_command_line_parse_results() {
        if constexpr(debug_only)
        {
#ifndef NDEBUG
            std::cout << " Command Line Parse Results:\n";
            for (const auto &[key, value]: slx::get_command_line_args())
                std::cout << "  [\"" << key << "\"]: " << value << "\n";
#endif
        }
        else
        {
            std::cout << " Command Line Parse Results:\n";
            for (const auto &[key, value]: slx::get_command_line_args())
                std::cout << "  [\"" << key << "\"]: " << value << "\n";
        }
    }

    /**
    * \brief A minimalistic command line parser (~60 lines of code).
    * \param options   slx::command_line_options_t cmd_line_options{ {"in", "i", true}, {"out", "o", false} };
    *                             By convention the long argument should be listed first.
    *
    * \param argc The command line arg count.
    * \param argv The command line arguments.
    * \param publish_help_info A function to display help information to the user.
    * \return A copy of the command_line_options_result_t, a std::unordered_map.
    *
    *   The assumption here is that if content of an option begins with a '-' or '--', then the value of the option
    *   must be quoted.
    *   E.g.
    *   		-option "-Some Data"	OK
    *   		-option -Some Data	NOT OK
    *
    *  Examples:
    *
    *    int main(int argc, char** argv)
    *    {
    *        slx::publish_command_line_args(argc,argv);
    *        slx::command_line_options_t options{ {"in", "i", true}, {"out", "o", false} };
    *        auto cmd_line = slx::parse_command_line_args(options, argc, argv, [](){});
    *        slx::publish_command_line_parse_results();
    *        return !cmd_line.empty() ? EXIT_SUCCESS : EXIT_FAILURE;
    *    }
    *
    *    int main(int argc, char** argv)
    *    {
    *        slx::publish_command_line_args(argc,argv);
    *        slx::command_line_options_t options{ {"in", "i", true}, {"out", "o", false} };
    *        auto help_info = []()
    *        {
    *          std::cout << "Error: Missing Required Options!\n";
    *          std::cout
    *            << "\n Command Line Options:"
    *            << "\n  --in,  -i: [required] input file (eg., --in \"input.json\")"
    *            << "\n  --out, -o: [optional] output file (e.g., --out \"result.json\")\n"
    *            << std::endl; //flush
    *        };
    *        auto cmd_line = slx::parse_command_line_args(options, argc, argv, help_info);
    *        auto input_file = cmd_line["in"];
    *        auto output_file = cmd_line["out"];
    *        slx::publish_command_line_parse_results();
    *        return !cmd_line.empty() ? EXIT_SUCCESS : EXIT_FAILURE;
    *    }
    *
    *  Commandline:
    *    --ignored -o "output.txt" --in "input.json"
    *
    *    Command Line Args:
    *     [0]: ./a.out
    *     [1]: --ignore
    *     [2]: -o
    *     [3]: output.txt
    *     [4]: --in
    *     [5]: input.json
    *
    *    Result is std::unordered_map:
    *     ["in"]: input.json
    *     ["out"]: output.txt
    *     ["app"]: ./a.out
    *
    *     Args that are not registered are ignored.
    */
    template<bool include_app_path = true>
    command_line_options_result_t parse_command_line_args(command_line_options_t &options, int argc, char **argv,
                                                          std::function<void()> publish_help_info) {
        // Note:
        // Compiling with C++ on Visual Studio results in 'cmd-line-parsing.hh(225,33):
        // error C2672: 'get': no matching overloaded function found'
        // error if 'std::get<long_option>'. The MSVC compiler errors on 'long_option', a
        // constexpr and requires 'std::get<0>'. Therefore the #defines implemented in
        // the code below.
        //
#ifdef WIN32
#  define long_option  0
#  define short_option 1
#else
        constexpr auto long_option = 0;
        constexpr auto short_option = 1;
#endif

        const auto start = include_app_path ? 0 : 1;
        std::string option;
        auto &result = *get_command_line_args_();

        for (auto i = start; i < argc; ++i) {
            if constexpr(include_app_path)
            {
                if (0 == i) {
                    result["app"] = argv[0];
                    continue;
                }
            }
            std::string arg = argv[i];

            // tuple of <std::string, std::string, bool>:
            //
            // Where first string is long form of the option name and the second string
            // is the short form of the options key. 'bool' is a flag that indicates
            // if the option is required.
            //
            if (std::find_if(options.begin(), options.end(), [&](std::tuple<std::string, std::string, bool> &p) {
                if (("--" + std::get<long_option>(p)) == arg || ("-" + std::get<short_option>(p)) == arg) {
                    option = std::get<long_option>(p);
                    return true;
                }
                return false;
            }) != options.end()) {
                // See if the next arg is an option or content. Options are prefixed with
                // '-' or '--'. If the flag does not have any associated data then an
                // empty string is assigned for content.
                //
                // The assumption here is that if content of an option begins with a '-' or '--', then the value
                // of the option must be quoted.
                //
                // E.g.
                // 		'-option "-Some Data"' Good
                //		'-option -Some Data'   Bad
                ++i;
                if (argv[i]) {
                    if ('-' == argv[i][0]) {
                        result[option] = "";
                        --i;
                        continue;
                    }
                    result[option] = argv[i];

                    // On some platforms (e.g., Windows, extra quotes are added to arguments
                    // by the operating system). These are removed when storing the value.
                    //
                    if ('\"' == result[option].front() && '\"' == result[option].back()) {
                        //
                        // Remove the extra quotes around the string.
                        //
                        auto &t = result[option];
                        result[option] = std::string(t.begin() + 1, t.end() - 1);
                    }
                }
            }
        }

        // Evaluate if any options are missing and display help information if defined.
        // This routine may also provide validation.
        //
        for (auto const &[key, ignore, is_required]: options) {
            if (result.count(key)) continue;
            if (is_required && publish_help_info) {
                publish_help_info();
                break;
            }
        }
        return result;
    }
}

#endif // CMD_LINE_PARSING_HH__
