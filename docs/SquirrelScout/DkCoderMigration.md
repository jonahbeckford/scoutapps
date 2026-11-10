# DkCoder migration

Currently DkCoder is used for the IDE experience. It produces bytecode and a Merlin file.

Android Gradle Plugin will use DkSDK CMake, however, meaning that what is in the IDE is not exactly what is run in Android.

There are two relevant Diskuv goals:

- [ ] A. DkSDK CMake uses DkCoder underneath (`dksdk-coder`) to produce native code.
- [ ] B. DkCoder produces native shared libraries by linking an embedded bytecode interpreter into a skeleton shared library. That is, expand `Run` and `Repl` to `SharedLib`.

Either of these two goals will remove the DkSDK CMake / DkCoder discrepancy. The latter will make for a fast development experience (no WSL2).

## Testing

These will compile all of the packages with DkCoder:

```powershell
./dk DkRun_Project.Run run SonicScout_Objs.ObjsEntry
./dk DkRun_Project.Run run -- SonicScout_MainCLI.SquirrelScout_cli --help
./dk DkRun_Project.Run run SonicScout_ManagerApp.ManagerApp_ml
./dk DkRun_Project.Run run SonicScout_ObjsLib.Init
./dk DkRun_Project.Run run SonicScout_Std.Qr_manager
./dk SonicScout_Setup.Develop
```

This will compile with DkSDK CMake:

```powershell
./dk SonicScout_Setup.Clean --builds
./dk SonicScout_Setup.Develop android --next

./dk SonicScout_Setup.Clean --builds
./dk SonicScout_Setup.Develop android
```

## Goal B - DkCoder embeds bytecode interpreter into shared library

Flush technique A:

- Make sure Android Studio works locally with `./dk SonicScout_Setup.Develop android`
- Run the app up until generating the QR scanner page.
- Hide the DkSDK CMake bits in us/SonicScoutBackend/CMakeLists.txt behind a CMake variable set in the presets.
- Compile with `./dk SonicScout_Setup.Develop compile --skip-fetch --next --build-type Debug` until Android Studio works again.
- Run the app up until generating the QR scanner page.

Drawbacks: Important bits like the capnp generation will not run.

---

Flush technique B:

- Make sure Android Studio works locally with `./dk SonicScout_Setup.Develop android`
- Run the app up until generating the QR scanner page.
- Edit DkSDK CMake so that OCaml compiler is never run. Ditto for WSL2. Hide that "never run" feature behind a CMake variable set in the presets.
- Compile with `./dk SonicScout_Setup.Develop compile --skip-fetch --next --build-type Debug` until Android Studio works again.
- Run the app up until generating the QR scanner page.

---

Quick Steps:

```powershell
# SCANNER, CLI
del -recurse -force us\SonicScoutBackend\build_dev\DkSDKFiles\host\bytecode-to-c ; del -recurse -force us\SonicScoutBackend\build_dev\_deps\bytecode_to_c_host_tools-build\ ; del -recurse -force us\SonicScoutBackend\build_dev\src\SonicScout_MainCLI ; echo "" >> us\SonicScoutBackend\build_dev\CMakeCache.txt
#   Use a new interpreter since the environment is appended and will run out of space if not reset each time
cmd /c "cd us\SonicScoutBackend & powershell -ExecutionPolicy Bypass .tools\vsdev-backend-build.ps1"
#   Or use the following in a Visual Studio 2019 Developer Prompt:
#   ninja -C us\SonicScoutBackend\build_dev src\SonicScout_MainCLI\sonic-scout-cli.exe 

# COM (Android Studio)
$aid="y5xc2i16"; del -force -recurse us\SonicScoutAndroid\data\.cxx\Debug\$aid\arm64-v8a\DkSDKFiles\host ; del -force -recurse us\SonicScoutAndroid\data\.cxx\Debug\$aid\arm64-v8a\_deps\bytecode_to_c_host_tools-build\ ; del -force us\SonicScoutAndroid\data\.cxx\Debug\$aid\arm64-v8a\data\src\main\cpp\SonicScout_ObjsLib-prim.c ;del -force us\SonicScoutAndroid\data\.cxx\Debug\$aid\arm64-v8a\data\src\main\cpp\SonicScout_ObjsLib-sect.c ; del -force us\SonicScoutAndroid\data\.cxx\Debug\$aid\arm64-v8a\data\src\main\cpp\SonicScout_ObjsLib-lib.c ; del -force -recurse us\SonicScoutBackend\build_dev\_deps\bytecode_to_c_host_tools-build\; del -recurse -force us\SonicScoutBackend\build_dev\src\SonicScout_ObjsLib
```
