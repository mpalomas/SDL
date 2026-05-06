
```sh
cmake -S . -B build-static \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DSDL_SHARED=OFF \
    -DSDL_STATIC=ON
```

  If you also want examples/tests linked against the static lib:

```sh
  cmake -S . -B build-static \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DSDL_SHARED=OFF \
    -DSDL_STATIC=ON \
    -DSDL_EXAMPLES=ON \
    -DSDL_EXAMPLES_LINK_SHARED=OFF \
    -DSDL_TESTS=ON \
    -DSDL_TESTS_LINK_SHARED=OFF
```

Then build:

```sh
  cmake --build build-static
```

In VSCode, the reliable way is to set them in .vscode/settings.json:
```json
{
  "cmake.configureArgs": [
    "-DSDL_STATIC=ON",
    "-DSDL_EXAMPLES_LINK_SHARED=OFF",
    "-DSDL_TESTS_LINK_SHARED=OFF",
    "-DSDL_EXAMPLES=ON",
    "-DSDL_DISKAUDIO=OFF",
    "-DSDL_CAMERA=OFF",
    "-DSDL_DUMMYCAMERA=OFF",
    "-DSDL_DUMMYAUDIO=OFF",
    "-DSDL_DUMMYVIDEO=OFF",
    "-DSDL_X11=OFF",
    "-DSDL_GPU=OFF",
    "-DSDL_GPU_OPENXR=OFF",
    "-DSDL_HAPTIC=OFF",
    "-DSDL_METAL=OFF",
    "-DSDL_VULKAN=OFF",
    "-DSDL_OPENGLES=OFF",
    "-DSDL_RENDER_VULKAN=OFF",
    "-DSDL_RENDER_METAL=OFF",
    "-DSDL_SENSOR=OFF",
    "-DSDL_TRAY=OFF",
    "-DSDL_INSTALL=ON",
    "-DCMAKE_INSTALL_PREFIX=install",
    "-DCMAKE_BUILD_TYPE=MinSizeRel"
  ]
}
```

  Then run CMake: Delete Cache and Reconfigure.You can also check from terminal:

```sh
  cmake -S . -B build -LAH | rg "SDL_(SHARED|STATIC|EXAMPLES_LINK_SHARED|TESTS_LINK_SHARED)"
  ```

## Binary size

Useful tools for inspecting `.a` and `.dylib` size:

```sh
ls -lh build/install/lib
lipo -info build/install/lib/*.a build/install/lib/*.dylib
size -m build/install/lib/*.a build/install/lib/*.dylib
nm -gU build/install/lib/*.dylib | wc -l
```

Use `nm -S` or `bloaty` to find large symbols and sections:

```sh
nm -S build/install/lib/*.a | sort -k2 -nr | head -50
bloaty -d symbols build/install/lib/*.dylib
```

Common causes of large libraries are universal binaries with multiple architectures,
debug or local symbol data, many exported symbols, static data tables, embedded
assets, template-heavy C++ code, and bundled static dependencies.
