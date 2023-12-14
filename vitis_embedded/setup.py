#!/usr/bin/env python3
import vitis
import os
import shutil

try:
    shutil.rmtree("./workspace")
except OSError as e:
    pass

client = vitis.create_client()

client.set_workspace("./workspace")

platform = client.create_platform_component(name = "standalone_plat", hw = "../implement/results/top.xsa", cpu = "psu_cortexa53_0", os = "standalone", domain_name = "standalone_a53")
status = platform.build()

comp = client.create_app_component(name="hello1",platform = "./workspace/standalone_plat/export/standalone_plat/standalone_plat.xpfm",domain = "standalone_a53")
os.symlink( './src/hello1/test.c', './workspace/hello1/src/test.c' )
comp = client.get_component(name="hello1")
comp.build()

exit()

vitis.dispose()
