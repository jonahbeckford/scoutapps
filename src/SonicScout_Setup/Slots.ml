(** Accumulator of paths as programs and directories are found. *)

type t = {
  msys2 : Fpath.t option;
  git : Fpath.t option;
  uv : Fpath.t option;
  uv_cache : Fpath.t option;
  uv_install : Fpath.t option;
  python_version : string option;
  paths : Fpath.t list;
  android_sdk_dir : Fpath.t option;
  jdk : Fpath.t option;
  gradle_home : Fpath.t option;
  ninja_dir : Fpath.t option;
  cmake_home : Fpath.t option;
  android_studio_launcher : Fpath.t option;
}

let create () =
  {
    msys2 = None;
    git = None;
    uv = None;
    uv_cache = None;
    uv_install = None;
    python_version = None;
    paths = [];
    android_sdk_dir = None;
    jdk = None;
    gradle_home = None;
    ninja_dir = None;
    cmake_home = None;
    android_studio_launcher = None;
  }

let add_msys2 t fp = { t with msys2 = Some fp }

let add_git t git_exe =
  let fp_dir = Fpath.parent git_exe in
  { t with git = Some git_exe; paths = fp_dir :: t.paths }

let add_uv ~cache_dir t uv_exe =
  let fp_dir = Fpath.parent uv_exe in
  {
    t with
    uv = Some uv_exe;
    uv_cache = Some cache_dir;
    paths = fp_dir :: t.paths;
  }

let add_uv_install ~version t uv_install_dir =
  { t with uv_install = Some uv_install_dir; python_version = Some version }

let add_path t path = { t with paths = path :: t.paths }

let add_android_sdk_dir t android_sdk_dir =
  { t with android_sdk_dir = Some android_sdk_dir }

let add_jdk t jdk = { t with jdk = Some jdk }
let add_gradle_home t gradle_home = { t with gradle_home = Some gradle_home }
let set_ninja_dir t ninja_dir = { t with ninja_dir = Some ninja_dir }
let set_cmake_home t cmake_home = { t with cmake_home = Some cmake_home }

let set_android_studio_launcher t android_studio_launcher =
  { t with android_studio_launcher = Some android_studio_launcher }

let paths { paths; _ } = paths
let msys2 { msys2; _ } = msys2
let git { git; _ } = git
let uv { uv; _ } = uv
let uv_cache { uv_cache; _ } = uv_cache
let uv_install { uv_install; _ } = uv_install
let python_version { python_version; _ } = python_version
let android_sdk_dir { android_sdk_dir; _ } = android_sdk_dir
let jdk { jdk; _ } = jdk
let gradle_home { gradle_home; _ } = gradle_home

let ninja_dir { ninja_dir; _ } =
  match ninja_dir with
  | None -> failwith "Missing ninja_dir slot"
  | Some ninja_dir -> ninja_dir

let cmake_home { cmake_home; _ } =
  match (cmake_home, Sys.getenv_opt "DKCODER_CMAKE_EXE") with
  | Some cmake_home, _ -> cmake_home
  | None, Some cmake_exe -> Fpath.(v cmake_exe |> parent |> parent)
  | None, None ->
      failwith
        "Expected to be run within DkCoder. But no DKCODER_CMAKE_EXE \
         environment variable was available."

(** [android_studio_launcher slots] is the Android Studio executable (macOS)
    or the ["studio.bat"] / ["studio.sh"] script (Win32, other Unix). *)
let android_studio_launcher { android_studio_launcher; _ } =
  android_studio_launcher
