#!/usr/bin/env python


from os.path import join, dirname
from vunit import VUnit

root = dirname(__file__)

ui = VUnit.from_argv()
ui.enable_location_preprocessing()
lib = ui.add_library("lib")
lib.add_source_files(join(root, "*.vhd"))
ui.main()
