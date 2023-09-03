#include "xil_printf.h"
#include "xparameters.h"
#include "fpga.h"
#include "xspips.h"
#include "xspips_hw.h"

#define XSPIPS_MOD_ID_OFFSET	0xFCU

void spi_init (uint32_t* spiptr) {

    // initialize the spi interface
    spiptr[XSPIPS_ER_OFFSET/4]  = 0; // disable
    spiptr[XSPIPS_IER_OFFSET/4] = 0;
    spiptr[XSPIPS_IMR_OFFSET/4] = 0;
    spiptr[XSPIPS_DR_OFFSET/4]  = 0xf0f0f0f0;
    spiptr[XSPIPS_CR_OFFSET/4]  = 0x00007c31;
    spiptr[XSPIPS_TXWR_OFFSET/4] = 1;
    spiptr[XSPIPS_RXWR_OFFSET/4] = 1;
    spiptr[XSPIPS_ER_OFFSET/4]  = 1; // enable	
    
}

int spi_scan (uint32_t* spiptr, uint8_t* wdata, uint8_t* rdata, int n) {

	// set csn low
	spiptr[XSPIPS_CR_OFFSET/4] &= 0xfffffbff;

	// write the data to txd port.
	for(int i=0; i<n; i++) {
		spiptr[XSPIPS_TXD_OFFSET/4] = wdata[i];
	}

	// wait for the tx fifo to go empty.
	uint32_t rval;
	do {
		rval = spiptr[XSPIPS_SR_OFFSET/4];
		for(int i=0; i<50000000; i++);
	} while(0==(rval & 0x00000004));

	// read the rx fifo until it goes empty.
	int rcount=0;
	while (0x0010 & spiptr[XSPIPS_SR_OFFSET/4]) {
		rdata[rcount] = spiptr[XSPIPS_RXD_OFFSET/4];
		rcount ++;
	}

	// set csn high
	spiptr[XSPIPS_CR_OFFSET/4] |= 0x00003c00;

	return(rcount);

}


int main()
{

    xil_printf("Hello World\n\r");
    
    uint8_t wdata[100], rdata[100];

    // get pointers to fpga and spi controller registers
    uint32_t *regptr = (uint32_t *)XPAR_M00_AXI_BASEADDR;
    uint32_t *spiptr = (uint32_t *)XPAR_PSU_SPI_0_BASEADDR;

    // check fpga ID and VERSION registers
    xil_printf("FPGA_ID = 0x%08x, FPGA_VERSION = 0x%08x\n\r", regptr[FPGA_ID], regptr[FPGA_VERSION]);
    
    // check SPI controller ID register
    xil_printf("XSPIPS_MOD_ID_OFFSET = 0x%08x\n\r", spiptr[XSPIPS_MOD_ID_OFFSET/4]);
    
    spi_init(spiptr);

    uint32_t rval;
    int rcount;

	// infinite loop
	uint32_t whilecount = 0;
	while(1) {

		wdata[0] = 0x8f; wdata[1] = 0x00;
	    rcount = spi_scan(spiptr, wdata, rdata, 2);

		//rval = spiptr[XSPIPS_SR_OFFSET/4];
		//xil_printf("XSPIPS_SR_OFFSET = 0x%08x\n\r", rval);
		xil_printf("whilecount = %d; rcount = %d\n\r", whilecount, rcount);
		xil_printf("whoami = 0x%02x\n\r", rdata[1]);

		wdata[0] = 0xab; wdata[1] = 0x00; wdata[2] = 0x00;
	    rcount = spi_scan(spiptr, wdata, rdata, 3);
		xil_printf("rcount = %d, tempC = 0x%02x 0x%02x\n\r", rcount, rdata[1], rdata[2]);

		regptr[FPGA_RGB_LED] = whilecount; // flash the LED
		for(int i=0; i<100000000; i++);
		whilecount++;
	}
    
    return 0;
}


