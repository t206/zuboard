# sudo python3 mmap_test.py
import mmap
import os

f = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)

addr = 0x80000000
mem = mmap.mmap(f, mmap.PAGESIZE, mmap.MAP_SHARED, mmap.PROT_READ | mmap.PROT_WRITE, offset=addr)
for i in range(0, 8):
    print(hex(mem[i]))

os.close(f)
