// This little module excercises a high-speed lvds data link implemented on a 
// little zmod module plugged into J2 of the zuboard.  The idea is to see how fast 
// we can push data over that connector using a low-cost pcb.
// The channel consists of four lvds lanes plus source-synchronous clock. Three bits are used as
// data and one as a framing sync word. 
module zmod_test (
    input   logic           base_clk,  // base clock
    output  logic           clk_out_p, clk_out_n,
    output  logic[3:0]      d_out_p, d_out_n,
    input   logic           clk_in_p, clk_in_n,
    input   logic[3:0]      d_in_p,  d_in_n
);

    // clock synthesis
    logic clk, clkx4, locked;
    zmod_clk_wiz clk_wiz_inst (.clk_in1(base_clk), .clkout100(clk), .clkout400(clkx4), .locked(locked));    

    // pattern generation
    logic[31:0] tx_data=0;
    always_ff @(posedge clk) begin
        tx_data[31:24] <= 8'b0000_0001;
        tx_data[23: 0] <= tx_data[23:0] + 1;
    end
    
    // transmit the tx clock
    OSERDESE3 #(.DATA_WIDTH(8), .INIT(1'b0), .IS_CLKDIV_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    OSERDESE3_clock (.CLK(clkx4), .CLKDIV(clk), .D(8'b10101010), .RST(1'b0), .OQ(clk_out), .T(1'b0), .T_OUT());
    OBUFDS OBUFDS_clk_out (.I(clk_out), .O(clk_out_p),  .OB(clk_out_n));   
    
    // rx clocks
    logic rxdivclk, rxclk, rxclk_b, rxlocked;
    zmod_clk_in_wiz clk_in_wiz_inst (.clk_in1_p(clk_in_p), .clk_in1_n(clk_in_n), .clkout100(rxdivclk), .clkout400(rxclk), .clkout400_b(rxclk_b), .locked(rxlocked));    


    logic[3:0] d_out, d_in;
    logic[31:0] rx_data;
    generate for(genvar i=0; i<4; i++) begin

        // data serialization and transmission    
        OSERDESE3 #(.DATA_WIDTH(8), .INIT(1'b0), .IS_CLKDIV_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
        OSERDESE3_data (.CLK(clkx4), .CLKDIV(clk), .D(tx_data[i*8 +: 8]), .RST(1'b0), .OQ(d_out[i]), .T(1'b0), .T_OUT());
        OBUFDS OBUFDS_data (.I(d_out[i]), .O(d_out_p[i]),  .OB(d_out_n[i]));   
   
        // data reception and deserialization   
        IBUFDS IBUFDS_data (.I(d_in_p[i]), .IB(d_in_n[i]), .O(d_in[i]));        
        ISERDESE3 #(.DATA_WIDTH(8), .FIFO_ENABLE("TRUE"), .FIFO_SYNC_MODE("FALSE"), .IS_CLK_B_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
        ISERDESE3_data (.RST(1'b0), .CLK(rxclk), .CLK_B(rxclk_b), .CLKDIV(rxdivclk), .D(d_in[i]), .Q(rx_data[i*8 +: 8]), .FIFO_EMPTY(), .INTERNAL_DIVCLK(), .FIFO_RD_CLK(1'b0), .FIFO_RD_EN(1'b0));  
    
    end endgenerate
    
    // cross back to the original clk with a little fifo
    logic[31:0] fifo_dout;
    zmod_fifo fifo_inst (.wr_clk(rxdivclk), .rd_clk(clk), .din(rx_data), .wr_en(1'b1), .rd_en(1'b1), .dout(fifo_dout), .full(), .empty());    

    
    // rotate the bits to get the right framing
    logic[3:0][15:0] shift_data;
    logic[3:0][7:0] shift_dout; 
    logic[2:0] shift;
    always_ff @(posedge clk) begin
     
        // determine the needed shift
        case (fifo_dout[31:24])
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

        // create 16 bit words of the last two bytes of each lane
        shift_data[3] <= {shift_data[3][7:0], fifo_dout[31:24]};
        shift_data[2] <= {shift_data[2][7:0], fifo_dout[23:16]};
        shift_data[1] <= {shift_data[1][7:0], fifo_dout[15: 8]};
        shift_data[0] <= {shift_data[0][7:0], fifo_dout[ 7: 0]}; 

        // apply the shift
        shift_dout[3] <= shift_data[3] >> shift;  
        shift_dout[2] <= shift_data[2] >> shift;  
        shift_dout[1] <= shift_data[1] >> shift;  
        shift_dout[0] <= shift_data[0] >> shift;  
                                
    end    
    
    // rename for convenience
    logic[31:0] out_word;
    assign out_word = shift_dout;
    
    // debug
    zmod_ila ila_inst (.clk(clk), .probe0({fifo_dout, shift, out_word})); // 32+3+32=67
    zmod_rx_ila rx_ila_inst (.clk(rxdivclk), .probe0(rx_data)); // 32

endmodule



/*

zmod_fifo your_instance_name (
  .wr_clk(wr_clk),  // input wire wr_clk
  .rd_clk(rd_clk),  // input wire rd_clk
  .din(din),        // input wire [31 : 0] din
  .wr_en(wr_en),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(dout),      // output wire [31 : 0] dout
  .full(full),      // output wire full
  .empty(empty)    // output wire empty
);

   BUFG BUFG_inst (
      .O(O), // 1-bit output: Clock output.
      .I(I)  // 1-bit input: Clock input.
   );
   
   OBUFDS OBUFDS_inst (
      .O(O),   // 1-bit output: Diff_p output (connect directly to top-level port)
      .OB(OB), // 1-bit output: Diff_n output (connect directly to top-level port)
      .I(I)    // 1-bit input: Buffer input
   );

   OSERDESE3 #(
      .DATA_WIDTH(8),                 // Parallel Data Width (4-8)
      .INIT(1'b0),                    // Initialization value of the OSERDES flip-flops
      .IS_CLKDIV_INVERTED(1'b0),      // Optional inversion for CLKDIV
      .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
      .SIM_DEVICE("ULTRASCALE_PLUS")  // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
   )
   OSERDESE3_inst (
      .OQ(OQ),         // 1-bit output: Serial Output Data
      .T_OUT(T_OUT),   // 1-bit output: 3-state control output to IOB
      .CLK(CLK),       // 1-bit input: High-speed clock
      .CLKDIV(CLKDIV), // 1-bit input: Divided Clock
      .D(D),           // 8-bit input: Parallel Data Input
      .RST(RST),       // 1-bit input: Asynchronous Reset
      .T(T)            // 1-bit input: Tristate input from fabric
   );
   
      
   
   IBUFDS IBUFDS_inst (
      .O(O),   // 1-bit output: Buffer output
      .I(I),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
      .IB(IB)  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
   );

   ISERDESE3 #(
      .DATA_WIDTH(8),                 // Parallel data width (4,8)
      .FIFO_ENABLE("FALSE"),          // Enables the use of the FIFO
      .FIFO_SYNC_MODE("FALSE"),       // Always set to FALSE. TRUE is reserved for later use.
      .IS_CLK_B_INVERTED(1'b0),       // Optional inversion for CLK_B
      .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
      .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
      .SIM_DEVICE("ULTRASCALE_PLUS")  // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
   )
   ISERDESE3_inst (
      .FIFO_EMPTY(FIFO_EMPTY),           // 1-bit output: FIFO empty flag
      .INTERNAL_DIVCLK(INTERNAL_DIVCLK), // 1-bit output: Internally divided down clock used when FIFO is
                                         // disabled (do not connect)

      .Q(Q),                             // 8-bit registered output
      .CLK(CLK),                         // 1-bit input: High-speed clock
      .CLKDIV(CLKDIV),                   // 1-bit input: Divided Clock
      .CLK_B(CLK_B),                     // 1-bit input: Inversion of High-speed clock CLK
      .D(D),                             // 1-bit input: Serial Data Input
      .FIFO_RD_CLK(FIFO_RD_CLK),         // 1-bit input: FIFO read clock
      .FIFO_RD_EN(FIFO_RD_EN),           // 1-bit input: Enables reading the FIFO when asserted
      .RST(RST)                          // 1-bit input: Asynchronous Reset
   );   
      
*/
