
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
      "-DSDL_SHARED=OFF",
      "-DSDL_STATIC=ON",
      "-DSDL_EXAMPLES_LINK_SHARED=OFF",
      "-DSDL_TESTS_LINK_SHARED=OFF",
      "-DSDL_EXAMPLES=ON",
      "-DCMAKE_BUILD_TYPE=MinSizeRel"
    ]
  }
```

  Then run CMake: Delete Cache and Reconfigure.You can also check from terminal:

```sh
  cmake -S . -B build -LAH | rg "SDL_(SHARED|STATIC|EXAMPLES_LINK_SHARED|TESTS_LINK_SHARED)"
  ```