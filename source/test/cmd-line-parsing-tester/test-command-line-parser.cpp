#include <slx/version.hh>

#include "test-command-line-parser.hh"

// Write out test results to a file.
// You may also redirect the Boot UT output (see 
static std::vector<test_result_t> g_test_results;

// Ok for example testing but using the following could result in an uncaught
// exception since I am using static storage. I.e., Not a best practice.
//
static std::ofstream g_ofs("./test-command-line-results.md");

void test_with_valid_args();
void test_with_missing_args();

static auto display_help = []() {

   // Note:
   //
   // It is also possible to use this method for validation.
   //
   // auto validate = []() {
   //     auto args = slx::get_command_line_args();
   //     for (const auto &[key, value]: args) {
   //         // etc.
   //     }
   // };
   //
   // Call 'validate()' before returning.

   // Use portable dialogs if installed.
   //
   if constexpr (has_portable_file_dialogs) {
      pfd::message(
         // Caption
         "Error: Missing required Options!",

         // Body
         "\n Command Line Options:\n"
         "\n  --in,  -i: [required]"
         "\n  input file (eg., --in \"input.json\")"
         "\n\n--out, -o: [optional]"
         "\n  output file (e.g., --out \"result.json\")\n",

         // Options
         pfd::choice::ok,
         pfd::icon::warning

         // 'result()' forces synchronous behavior.
         //
      ).result();
   }
   else
   {
      std::cout
         <<
         "Error: Missing required Options!"
         "\n Command Line Options:"
         "\n  --in,  -i: [required]"
         "\n  input file (eg., --in \"input.json\")"
         "\n\n--out, -o: [optional]"
         "\n  output file (e.g., --out \"result.json\")\n"
         << std::endl; /*flush*/
   }
};

int main(/*int argc, char* argv[]*/) {
   // slx::product_dialog();
   init();
   std::cout << "Testing " << slx::product_about() << ":\n";
   test_with_valid_args();
   test_with_missing_args();
}



// See: https://github.com/boost-ext/ut

// Test Implementations.
//
void test_with_valid_args()
{
#ifdef ENABLE_BOOST_UT_MODULE
   using namespace boost::ut;
   "Parsing with all required arguments should SUCCEED."_test = [&]
#endif
   {
      slx::clear_command_line_options();

      // Mock command line (missing required "-i" "input.json").
      //
      constexpr int argc{ 5 };
      const char* argv_[argc] = { "mock.app", "-o", "output.json", "-i", "input.json" };
      const auto argv = const_cast<char**>(argv_);

      // Your command line options
      //
      slx::command_line_options_t options{ {"in", "i", /*required:*/ true}, {"out", "o", false} };

      // Parse the command line:
      //
      auto r = slx::parse_command_line_args<false>(options, argc, argv, display_help);

#ifdef ENABLE_BOOST_UT_MODULE
      create_log_report_result("Parsing with all required arguments should SUCCEED."_test.name);

      g_test_results.back().succeeded =
         expect(0 == r.count("app")).value_
         && expect("input.json" == r["in"]).value_
         && expect("output.json" == r["out"]).value_;
#else
      create_log_report_result("Parsing with all required arguments should SUCCEED.");
      g_test_results.back().succeeded =
         (0 == r.count("app"))
         && ("input.json" == r["in"])
         && ("output.json" == r["out"]);
#endif
   };
}

void test_with_missing_args()
{
#ifdef ENABLE_BOOST_UT_MODULE
   using namespace boost::ut;
   "Parsing with missing arguments that are required should display help information."_test = [&]
#endif
   {
      slx::clear_command_line_options();

      // Mock command line (missing required "-i" "input.json").
      //
      constexpr int argc{ 4 };
      const char* argv_[argc] = { "mock.app", "-o", "output.json", "--ignored" };
      const auto argv = const_cast<char**>(argv_);

      // Your command line options
      //
      slx::command_line_options_t options{ {"in", "i", /*required:*/ true}, {"out", "o", false} };

      // Parse the command line:
      //
      auto r = slx::parse_command_line_args<false>(options, argc, argv, display_help);

#ifdef ENABLE_BOOST_UT_MODULE
      create_log_report_result("Parsing with missing arguments that are required should display help information."_test.name);

      g_test_results.back().succeeded =
         expect(r.size() != options.size()).value_
         //
         // Note:
         // GCC did not support 'r.contains' vs 'r.count'
         // with C++ 20. Therefore 'count' is used for portability.
         //
         && expect(0 == r.count("in")).value_
         && expect("output.json" == r["out"]).value_;
#else
      create_log_report_result("Parsing with missing arguments that are required should FAIL.");
      g_test_results.back().succeeded =
         (r.size() != options.size())
         && (0 == r.count("in"))
         && ("output.json" == r["out"]);
#endif
   };

}

// Misc. Support Functions.
//
inline std::string create_msg(const std::string_view msg, bool success)
{
   // Formatted for most mark down editors (GitHub will ignore the HTML styles).
   //
   constexpr auto failed = "<font color='#C34A2C'>FAILED</font>";
   constexpr auto succeeded = "<font color='#2E8B57'>SUCCEEDED</font>";
   const std::string_view result = success ? succeeded : failed;
   // constexpr std::string_view caption = "<font color='#0077c6'>Test</font>";
   return fmt::format("{} - {}  \n", result, msg);
}

inline void exit_handler()
{
   for (const auto& [succeeded, msg] : g_test_results)
   {
      g_ofs << create_msg(msg, succeeded);
   }
}

inline void create_log_report_result(std::string_view msg)
{
   g_test_results.emplace_back(test_result_t{ false, msg });
}

inline void init()
{
   static bool once = false;
   if (once) return;
   once = true;
   std::atexit(exit_handler);
   const auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
   const auto date_time = std::ctime(&now);  // NOLINT(concurrency-mt-unsafe)
   g_ofs << date_time << "  \n";
   g_ofs << "**Command Line Parser Testing:**  \n";
}
