#include "xil_printf.h"
#include "xparameters.h"
#include "fpga.h"
#include "xspips.h"
#include "xspips_hw.h"


#define XSPIPS_MOD_ID_OFFSET	0xFCU


int main()
{

    xil_printf("Hello World\n\r");
    
    uint32_t *regptr = (uint32_t *)XPAR_M00_AXI_BASEADDR;
    uint32_t *spiptr = (uint32_t *)XPAR_PSU_SPI_1_BASEADDR;

    xil_printf("regptr = %p\n\r", regptr);
    xil_printf("spiptr = %p\n\r", spiptr);

    xil_printf("FPGA_ID = 0x%08x, FPGA_VERSION = 0x%08x\n\r", regptr[FPGA_ID], regptr[FPGA_VERSION]);
    
    xil_printf("XSPIPS_MOD_ID_OFFSET = 0x%08x\n\r", spiptr[XSPIPS_MOD_ID_OFFSET/4]);

    spiptr[XSPIPS_ER_OFFSET]  = 0; // disable
    spiptr[XSPIPS_IER_OFFSET] = 0;
    spiptr[XSPIPS_IMR_OFFSET] = 0;
    spiptr[XSPIPS_DR_OFFSET]  = 0x0a0a0a0a;
    spiptr[XSPIPS_CR_OFFSET]  = 0x00000031;
    spiptr[XSPIPS_TXWR_OFFSET] = 1;
    spiptr[XSPIPS_RXWR_OFFSET] = 1;
    spiptr[XSPIPS_ER_OFFSET]  = 1; // enable

    spiptr[XSPIPS_TXD_OFFSET] = 0xfa;
    spiptr[XSPIPS_TXD_OFFSET] = 0xf3;

    uint32_t rval;
    do {
        rval = spiptr[XSPIPS_SR_OFFSET/4];
        xil_printf("XSPIPS_SR_OFFSET = 0x%08x\n\r", rval); 	
        for(int i=0; i<50000000; i++);
    } while(0==(rval & 0x00000004));

	xil_printf("Successfully ran Hello World application\n\r");
    
	while(1);
    
    return 0;
}

