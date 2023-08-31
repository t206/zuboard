#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "fpga.h"


int main()
{
    init_platform();

    xil_printf("Hello World\n\r");
    
    uint32_t *regptr = (uint32_t *)XPAR_M00_AXI_BASEADDR;

    //xil_printf("regptr[FPGA_ID] = 0x%08x, regptr[FPGA_VERSION] = 0x%08x\n\r", regptr[FPGA_ID], regptr[FPGA_VERSION]);
    
	xil_printf("Successfully ran Hello World application\n\r");
    
    
    cleanup_platform();
    return 0;
}
