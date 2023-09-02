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

    // initialize the spi interface
    spiptr[XSPIPS_ER_OFFSET/4]  = 0; // disable
    spiptr[XSPIPS_IER_OFFSET/4] = 0;
    spiptr[XSPIPS_IMR_OFFSET/4] = 0;
    spiptr[XSPIPS_DR_OFFSET/4]  = 0xf0f0f0f0;
    spiptr[XSPIPS_CR_OFFSET/4]  = 0x00000031;
    spiptr[XSPIPS_TXWR_OFFSET/4] = 1;
    spiptr[XSPIPS_RXWR_OFFSET/4] = 1;
    spiptr[XSPIPS_ER_OFFSET/4]  = 1; // enable

    // write some data to txd port.
    spiptr[XSPIPS_TXD_OFFSET/4] = 0xfa;
    spiptr[XSPIPS_TXD_OFFSET/4] = 0xf3;

    // wait for the tx fifo to go empty.
    uint32_t rval;
    do {
        rval = spiptr[XSPIPS_SR_OFFSET/4];
        xil_printf("XSPIPS_SR_OFFSET = 0x%08x\n\r", rval); 	
        for(int i=0; i<50000000; i++);
    } while(0==(rval & 0x00000004));
    
    // read the rx fifo until it goes empty.
    int rcount=0;
    while (0x0010 & spiptr[XSPIPS_SR_OFFSET/4]) {
    	rval = spiptr[XSPIPS_RXD_OFFSET/4];
    	rcount ++;
    }
    rval = spiptr[XSPIPS_SR_OFFSET/4];
    xil_printf("XSPIPS_SR_OFFSET = 0x%08x\n\r", rval);
    xil_printf("rcount = %d\n\r", rcount);

	xil_printf("Successfully ran!!\n\r");
    
	uint32_t whilecount = 0;
	while(1) {
		regptr[FPGA_RGB_LED] = whilecount;
		for(int i=0; i<50000000; i++);
		whilecount++;
	}
    
    return 0;
}

