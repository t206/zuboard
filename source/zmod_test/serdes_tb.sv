`timescale 1ns / 1ps

module serdes_tb ();
    
    // tx clocks
    localparam clk_period=2; logic clk=1; always #(clk_period/2) clk=~clk;
    logic txclk;
    assign txclk = clk;
    logic txdivclk=0; always #(4*clk_period/2) txdivclk=~txdivclk;
    logic hssclk;
    OSERDESE3 #(.DATA_WIDTH(8), .INIT(1'b0), .IS_CLKDIV_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    OSERDESE3_txclk (.CLK(txclk), .CLKDIV(txdivclk), .D(8'b10101010), .RST(1'b0), .OQ(hssclk), .T(1'b0), .T_OUT());
    logic hssclk_p, hssclk_n;
    OBUFDS OBUFDS_hssclk (.I(hssclk), .O(hssclk_p), .OB(hssclk_n));   

    // tx sync
    logic hss_sync, hss_sync_p, hss_sync_n;
    OSERDESE3 #(.DATA_WIDTH(8), .INIT(1'b0), .IS_CLKDIV_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    OSERDESE3_txsync (.CLK(txclk), .CLKDIV(txdivclk), .D(8'b0000_0001), .RST(1'b0), .OQ(hss_sync), .T(1'b0), .T_OUT());
    OBUFDS OBUFDS_hss_sync (.I(hss_sync), .O(hss_sync_p), .OB(hss_sync_n));   

    // tx data
    logic[7:0] txdata=0;
    always_ff @(posedge txdivclk) txdata <= txdata+1;
    logic txhssdata, hssdata_p, hssdata_n;
    OSERDESE3 #(.DATA_WIDTH(8), .INIT(1'b0), .IS_CLKDIV_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    OSERDESE3_txdata (.CLK(txclk), .CLKDIV(txdivclk), .D(txdata), .RST(1'b0), .OQ(txhssdata), .T(1'b0), .T_OUT());
    OBUFDS OBUFDS_txdata (.I(txhssdata), .O(hssdata_p), .OB(hssdata_n));   

    // rx clock
    logic rxdivclk, rxclk;
    IBUFDS IBUFDS_clk (.I(hssclk_p), .IB(hssclk_n), .O(rxclk));        
    BUFGCE_DIV #(.BUFGCE_DIVIDE(4), .IS_CE_INVERTED(1'b0), .IS_CLR_INVERTED(1'b0), .IS_I_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS")) BUFGCE_DIV_rxclk (.I(rxclk), .O(rxdivclk), .CE(1'b1), .CLR(1'b0));    

    // rx sync
    logic[7:0] rxsync;
    logic rx_hss_sync;
    IBUFDS IBUFDS_sync (.I(hss_sync_p), .IB(hss_sync_n), .O(rx_hss_sync));        
    ISERDESE3 #(.DATA_WIDTH(8), .FIFO_ENABLE("FALSE"), .FIFO_SYNC_MODE("FALSE"), .IS_CLK_B_INVERTED(1'b1), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    ISERDESE3_rxsync (.RST(1'b0), .CLK(rxclk), .CLK_B(rxclk), .CLKDIV(rxdivclk), .D(rx_hss_sync), .Q(rxsync), .FIFO_EMPTY(), .INTERNAL_DIVCLK(), .FIFO_RD_CLK(1'b0), .FIFO_RD_EN(1'b0));  

    // rx data
    logic[7:0] rxdata;
    logic rxhssdata;
    IBUFDS IBUFDS_data (.I(hssdata_p), .IB(hssdata_n), .O(rxhssdata));        
    ISERDESE3 #(.DATA_WIDTH(8), .FIFO_ENABLE("FALSE"), .FIFO_SYNC_MODE("FALSE"), .IS_CLK_B_INVERTED(1'b1), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    ISERDESE3_rxdata (.RST(1'b0), .CLK(rxclk), .CLK_B(rxclk), .CLKDIV(rxdivclk), .D(rxhssdata), .Q(rxdata), .FIFO_EMPTY(), .INTERNAL_DIVCLK(), .FIFO_RD_CLK(1'b0), .FIFO_RD_EN(1'b0));  

    // rx alignment gearbox
    logic[15:0] rxshift;
    logic[3:0] shift;
    logic[7:0] rx_dout, rx_dout_q;
    logic error=0; 
    logic[7:0] inc_sum;
    assign inc_sum = rx_dout_q+1;
    always_ff @(posedge rxdivclk) begin

        rxshift <= {rxdata, rxshift[15:8]};

        // determine the needed shift
        case (rxsync)
            8'b0000_0001: shift <= 0;
            8'b0000_0010: shift <= 1;
            8'b0000_0100: shift <= 2;
            8'b0000_1000: shift <= 3;
            8'b0001_0000: shift <= 4;
            8'b0010_0000: shift <= 5;
            8'b0100_0000: shift <= 6;
            8'b1000_0000: shift <= 7;
            default:      shift <= 0;
        endcase

        // apply shift
        rx_dout <= rxshift >> shift;

        // rx data verification
        rx_dout_q <= rx_dout;
        error <= (rx_dout != inc_sum);        

    end
    
endmodule
