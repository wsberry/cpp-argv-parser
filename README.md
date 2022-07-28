### ![./resources/slx-logo](./resources/slx-logo.png)<font color='#0077c6'>C++ Command Liner Parser</font>

##### Project: cpp-argv-parser

##### Version 1.0 

Implements a header only command line parser for C++. 

Although it has been implemented for C++ 17 and above it is easily modifiable for older C++ standards.

##### Tested on Windows, Linux, and the macOS w/ C++ 20.

### <font color='#0077c6'>Overview</font>

Minimal Example

~~~C++
#include <slx/cmd-line-parsing.hh>

int main(int argc, char*[] argv)
{
    slx::command_line_options_t options
    { 
      {"in",  "i", /*required:*/ true}, 
      {"out", "o", /*required:*/ false} 
    };
  
    auto cmd_line = slx::parse_command_line_args(options, argc, argv, [](){} );
    
    std::ifstream input(cmd_line["in"]);
    std::ofstream output(cmd_line["out"]);
    . 
    . Do Stuff
    .
    return !cmd_line.empty() ? EXIT_SUCCESS : EXIT_FAILURE;
}
~~~

The following demonstrates terminal/console output features that are available also.

~~~C++
#include <slx/cmd-line-parsing.hh>

int main(int argc, char*[] argv)
{
    // Publish command line to stdout:
    //
    slx::publish_command_line_args(argc, argv);
    
    // Create your command line options:
    //
    slx::command_line_options_t options{ 
      {"in", "i", /*required:*/ true}, {"out", "o", false} 
    };
  
    // Parse the command line
    //
    auto cmd_line = slx::parse_command_line_args(options, argc, argv, [](){} );
    
    // Get your command line arguments:
    //
    auto& input_file = cmd_line["in"];
    auto& output_file = cmd_line["out"];
    
    // Dump your parsed results to stdout:
    //
    slx::publish_command_line_parse_results();
  
    return !cmd_line.empty() ? EXIT_SUCCESS : EXIT_FAILURE;
}
~~~

Running the above will result in the following output:
~~~bash
./test.app --ignored -o "output.txt" --in "input.json"

Command Line Args:
 [0]: ./a.app
 [1]: --ignored
 [2]: -o
 [3]: output.txt
 [4]: --in
 [5]: input.json
 
Result is std::unordered_map:
 ["in"]: input.json
 ["out"]: output.txt
 ["app"]: ./a.out
~~~

An optional error handler or help output may be defined to process errors and provide user feedback  (e.g., when an argument is missing or is incorrect). The helper function is inserted via an injected lambda function (see the <font color='#0080FF'>help_info</font> function in the sample code below):

~~~C++
int main(int argc, char** argv)
{
    slx::publish_command_line_args(argc,argv);
    slx::command_line_options_t options{ {"in", "i", true}, {"out", "o", false} };
  
    // Define a help or info display:
    //
    inline auto help_info = []()
    {
        // Note:
        //
        // It is possible to use this method for validation also.
        //
        // auto validate = []() {
        //     auto args = slx::get_command_line_args();
        //     for (const auto &[key, value]: args) {
        //         // etc.
        //     }
        // };
        // .
        // . Do stuff
        // .
        // validate();
				//
        if constexpr (has_portable_file_dialogs)
        {
            // Use portable dialogs if present:
            //
            pfd::message(
              "Error: Missing Required Options!",
              "\n Command Line Options:\n"
              "\n  --in,  -i: [required]"
              "\n  input file (eg., --in \"myinput.json\")"
              "\n\n--out, -o: [optional]"
              "\n  output file (e.g., --out \"result.json\")\n",
              pfd::choice::ok,
              pfd::icon::warning
            ).result();
        }
        else
        {
            std::cout
              <<
              "Error: Missing Required Options!\n"
              "\n Command Line Options:\n"
              "\n  --in,  -i: [required]"
              "\n  input file (eg., --in \"myinput.json\")"
              "\n\n--out, -o: [optional]"
              "\n  output file (e.g., --out \"result.json\")\n"
              << std::endl; /*flush*/
        }
    };
    auto cmd_line = slx::parse_command_line_args(options, argc, argv, help_info);
    auto input_file = cmd_line["in"];
    auto output_file = cmd_line["out"];
    slx::publish_command_line_parse_results();
    return !cmd_line.empty() ? EXIT_SUCCESS : EXIT_FAILURE;
}
~~~

If the '--in' option is not provided on the command line in this example then the following is displayed when `has_portable_file_dialogs`is <font color='#0080FF'>false</font>  (otherwise a dialog with the same information will be displayed) :

~~~bash
Command Line Args:
  [0]: ./a.out
  [1]: -o
  [2]: myinputfile.json

Error: Missing Required Options!
 Command Line Options:
  --in,  -i: [required] input file (eg., --in "myinput.json")
  --out, -o: [optional] output file (e.g., --out "result.json")

Command Line Parse Results:
  ["out"]: myinputfile.json
  ["app"]: ./a.out
~~~

A test project using the [Boost UT/μt (micro unit test framework)](https://github.com/boost-ext/ut) is provided for an example. 

### <font color='#0077c6'>Conventions</font>

Directories created by the provided build scripts name generated folders with and underscore '\_' prefix by convention. These folders may therefore be deleted safely since they are generated from the CMake project scripts. 

### <font color='#0077c6'>Delimitations</font>

The test projects and corresponding documentation have the following delimitations:

1. The Homebrew package manager is assumed for macOS sfor installing updated versions of Git and Bash.
2. The provided install scripts require bash versions 4.x and above with 5.x being recommended.

### <font color='#0077c6'>Required Tools for Building the Unit Test Project</font>

&nbsp;&nbsp;\-  [Homebrew](https://brew.sh/) \[required for macOS systems only].
&nbsp;&nbsp;\-  [Git](https://git-scm.com/) 
&nbsp;&nbsp;\-  [CMake](https://cmake.org/)
&nbsp;&nbsp;\-  [Bash](https://www.gnu.org/software/bash/)
&nbsp;&nbsp;\-  [Boost UT/μt (micro unit test framework)](https://github.com/boost-ext/ut) (Installed by CMake)

### <font color='#0077c6'>macOS Users</font>
Bash 3.2.57 is the default installed version on the macOS. To use the install and build scripts for building this project requires bash versions 4.x and the latest (5.x) is recommended. If you choose not to use the provided scripts then you may also build your projects from CMake as well.

#### <font color='#0077c6'>Updating Bash</font>

Run the '<font color='#943126'>mac-os-install-prerequisites.sh</font>' if you do not have the current version of bash. 

~~~bash
./scripts/mac-os-install-prerequisites.sh
~~~

Or complete the following steps:

Install [Homebrew](https://brew.sh) (https://brew.sh) from a terminal:

~~~bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)”
~~~

Next check if Git has been installed on your system by running: `git --version`.

Run`brew install git` if it has not been installed.

Next run `brew install bash`.

Two versions of bash will now be installed on your macOS:
Example:

~~~bash
$ which -a bash
$ /usr/local/bin/bash
$ /bin/bash
~~~

The first line is the latest version installed by the Homebrew package manager. To use the updated bash version in the terminal on macOS make the following additional changes to your usr account:

~~~bash
$ echo $(brew --prefix)/bin/bash | sudo tee -a /private/etc/shells /usr/local/bin/bash
$ sudo chpass -s /usr/local/bin/bash {usrname}
~~~

The <font color='#0077c6'>*chpass*</font> utility allows editing of the user database information associated with *user* or, by default, the current user.

Note that the shebang line in any bash scripts you create should be updated to use `#!/usr/bin/env bash`. This works by finding the latest version of bash (by convention the latest version of directory occurs first) and ensures your scripts generally remain portable for Linux and Windows in addition to working on macOS.

**Note**:
On macOS if you are using Xcode then be sure to install its command line tools by running: 
`sudo xcode-select —reset`.

### <font color='#0077c6'>Linux Users</font>

Install prerequisites. 

See `./scripts/install-prerequisites-ubuntu-vm.sh` for details.

### <font color='#0077c6'>Windows Users</font>

Install prerequisites.

### <font color='#0077c6'>Building</font>

The following assumes you are in the  <font color='#0077c6'>`cpp-command-line-parser`</font> folder.

~~~bash
$ ./create-and-build.sh
~~~

You may also build directly from CMake:

##### macOS

~~~bash
$ cmake -DCMAKE_BUILD_TYPE=Debug -G "Xcode" -B "${CMAKE_BINARY_DIR}" -S "./"
~~~

##### Linux

~~~bash
$ cmake -DCMAKE_BUILD_TYPE=Debug -G "Ninja" -B "${CMAKE_BINARY_DIR}" -S "./"
~~~

##### Windows

~~~bash
$ cmake -DCMAKE_BUILD_TYPE="Debug;Release" -B "${CMAKE_BINARY_DIR}" -S "./"
~~~

### <font color='#0077c6'>Known Issues</font>

- [ ] Using MSVC you may get the following warning:
cl : command line warning D9002: ignoring unknown option '/std:c++' 
This warning may be safely ignored.

### <font color='#0077c6'>TODO</font>

- [ ] Consider supporting implicit type conversion for option value types.
  E.g., 
  
     $./app --latitude 30.516864 or --latitude "30.516864"

  ~~~C++
  double lat = options["latitude"];
  ~~~

  ​    $.app --enable-logging false

  ~~~C++
  bool enable_logging = options["enable-logging"];
  ~~~

- [ ] Implement CMake and other source code TODO items.
  
