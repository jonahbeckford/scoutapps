# We'll define a NODE and a EXECUTABLE

DkSDKProject_AddPackage(
        AUTO_OPAM_PACKAGE
        SUMMARY_ONELINER "A simple Hello World executable that demonstrates how to use DkSDK CMake."
        SUMMARY_PARAGRAPHS
        [[SquirrelScout_MainCLI is a TCP/IP echo server that repeats whatever you send it.]]
        [[You can clone the project using the './dk dksdk.project.new' command$<SEMICOLON> see the DkSDK.md document for more information.]]
)
option(SONIC_SCOUT_FEATURE_CLI "Enable the 'sonic-scout-cli' program" ON)

# ======================= EXECUTABLE =======================

if(SONIC_SCOUT_FEATURE_CLI)
        # By default the file is placed in the build directory.
        # But we place it in the source directory so it easy to
        # set a breakpoint in your favorite C language IDE (CLion, etc.).
        DkSDKProject_CreateMainC(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/_main.c)

        DkSDKProject_AddExecutable(
                TARGET sonic-scout-cli
                MODULE_ID SonicScout_MainCLI.SquirrelScout_cli)
        install(TARGETS sonic-scout-cli DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()

