DkSDKProject_AddPackage(AUTO_OPAM_PACKAGE TESTS)

include(DkSDKTest)

if(NOT DKSDK_GENERATOR STREQUAL DKCODER) # DkCoder has its own test frameworks for OCaml code
  # Test Std
  DkSDKTest_AddUnitTest(NAME Std
    STANDARD_MAIN

    ML_RUNTIME SquirrelScout::Std)

  # Test Objs
  DkSDKTest_AddUnitTest(NAME Objs
    MAIN generic-ffi-main.c

    # dksdk_ffi_c_logger_initConsoleLogger() is in generic-ffi-main.c
    C_RUNTIME DkSDK::FFI::C-Static

    ML_RUNTIME SquirrelScout::Objs)
endif()

add_subdirectory(ManagerApp)
