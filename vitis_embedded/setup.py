#!/usr/bin/env python3
import vitis
import os
import shutil

cwd = os.getcwd()

# delete all Vitis project files for clean build
try:
    shutil.rmtree("./workspace")
except OSError as e:
    pass
print("**************** workspace deleted")


client = vitis.create_client()
client.set_workspace("./workspace")

platform = client.create_platform_component(name = "standalone_plat", hw = "../implement/results/top.xsa", cpu = "psu_cortexa53_0", os = "standalone", domain_name = "standalone_a53")
status = platform.build()
print("**************** platform built")

# create an empty application
comp = client.create_app_component(name="hello1", platform = "./workspace/standalone_plat/export/standalone_plat/standalone_plat.xpfm", template = 'empty_application')
# use symbolic links to add source files
os.symlink(cwd + '/src/hello1/test.c', cwd + '/workspace/hello1/src/test.c') 
os.symlink(cwd + '/src/fpga.h',        cwd + '/workspace/hello1/src/fpga.h') 
print("**************** source files added with symbolic line")

# build application
comp = client.get_component(name="hello1")
comp.build()
print("*************** application built");


exit()

vitis.dispose()
