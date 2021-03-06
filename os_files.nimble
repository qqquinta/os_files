# Package
version = "0.1.1"
author = "Tormund"
description = """Native file dialogs (x11, windows, osx) with extension filters and predefined path.
    System file icons in any resolution (x11 with theme support, windows, osx).
    Open file in default application (x11, windows, osx)"""

license = "MIT"

requires "https://github.com/Tormund/winim" #revert to winim after https://github.com/khchen/winim/pull/4 will be merged
requires "gtk2"
requires "jsbind"
