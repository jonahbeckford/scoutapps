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
./dk src/SonicScout_Setup/Clean.ml --builds
./dk src/SonicScout_Setup/Develop.ml android --next

./dk src/SonicScout_Setup/Clean.ml --builds
./dk src/SonicScout_Setup/Develop.ml android
```

## Goal B - DkCoder embeds bytecode interpreter into shared library

Flush technique A:

- Make sure Android Studio works locally with `./dk src/SonicScout_Setup/Develop.ml android`
- Run the app up until generating the QR scanner page.
- Hide the DkSDK CMake bits in us/SonicScoutBackend/CMakeLists.txt behind a CMake variable set in the presets.
- Compile with `./dk SonicScout_Setup.Develop compile --skip-fetch --next --build-type Debug` until Android Studio works again.
- Run the app up until generating the QR scanner page.

Drawbacks: Important bits like the capnp generation will not run.

---

Flush technique B:

- Make sure Android Studio works locally with `./dk src/SonicScout_Setup/Develop.ml android`
- Run the app up until generating the QR scanner page.
- Edit DkSDK CMake so that OCaml compiler is never run. Ditto for WSL2. Hide that "never run" feature behind a CMake variable set in the presets.
- Compile with `./dk SonicScout_Setup.Develop compile --skip-fetch --next --build-type Debug` until Android Studio works again.
- Run the app up until generating the QR scanner page.

---

Quick Steps:

```powershell
# SCANNER, CLI
del -force -recurse build_dev\DkSDKFiles\host ; del -force -recurse build_dev/_deps/bytecode_to_c_host_tools-build

# COM (Android Studio)
del -force -recurse Y:\source\scoutapps\us\SonicScoutAndroid\data\.cxx\Debug\y5xc2i16\arm64-v8a\DkSDKFiles\host ; del -force -recurse Y:\source\scoutapps\us\SonicScoutAndroid\data\.cxx\Debug\y5xc2i16\arm64-v8a\_deps\bytecode_to_c_host_tools-build\ ; del -force Y:\source\scoutapps\us\SonicScoutAndroid\data\.cxx\Debug\y5xc2i16\arm64-v8a\data\src\main\cpp\SonicScout_ObjsLib-bc.c
```
