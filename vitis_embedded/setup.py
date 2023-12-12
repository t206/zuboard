#!/usr/bin/env python3
import vitis
import os

try:
    os.rmdir("./workspace")
except OSError:
    pass


client = vitis.create_client()

client.set_workspace("./workspace")

platform = client.create_platform_component(name = "standalone_plat", hw = "../implement/results/top.xsa", cpu = "psu_cortexa53_0", os = "standalone", domain_name = "standalone_a53")

exit()

vitis.dispose()
