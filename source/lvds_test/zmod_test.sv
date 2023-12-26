//
module zmod_test (
    input   logic           base_clk,  // input reference clock
    output  logic           clk_out_p, clk_out_n,
    output  logic[3:0]      d_out_p,   d_out_n,
    input   logic           clk_in_p,  clk_in_n,
    input   logic[3:0]      d_in_p,    d_in_n,
    output  logic           rxclk
);

    // clock synthesis
    logic clk, clkx4, locked, refclk;
    zmod_clk_wiz clk_wiz_inst (.clk_in1(base_clk), .clkout(clk), .clkoutx4(clkx4), .clkout300(refclk), .locked(locked));    

    // pattern generation
    logic[7:0] tx_data=0;
    always_ff @(posedge clkx4) tx_data <= tx_data + 1;
    
    // transmit the tx clock
    ODDRE1 #(.IS_C_INVERTED(1'b0), .IS_D1_INVERTED(1'b0), .IS_D2_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"), .SRVAL(1'b0)) ODDRE1_clk_out (.Q(clk_out), .C(clkx4), .D1(1'b1), .D2(1'b0), .SR(1'b0));   
    OBUFDS OBUFDS_clk_out (.I(clk_out), .O(clk_out_p),  .OB(clk_out_n));   
    

    // rx clocks
    logic rxlocked, rxclk;
    zmod_clk_in_wiz clk_in_wiz_inst (.clk_in1_p(clk_in_p), .clk_in1_n(clk_in_n), .clkout(rxclk), .locked(rxlocked));
//    logic clk_in;
//    IBUFDS IBUFDS_rxclk (.I(clk_in_p), .IB(clk_in_n), .O(clk_in));            
//    BUFG BUFG_rxclk (.O(rxclk), .I(clk_in));

    
    logic[23:0] reset_pipe = 24'hffffff;
    always_ff @(posedge refclk) reset_pipe <= {1'b0, reset_pipe[23:1]};  // generate an 80ns reset pulse after refclk starts 
    (* IODELAY_GROUP = "zmod_idelay_group" *) IDELAYCTRL #(.SIM_DEVICE("ULTRASCALE")) idelctrl (.RDY(), .REFCLK(refclk), .RST(reset_pipe[0]));



    logic[3:0] d_in, d_in_del; 
    logic[7:0] d_in_q, d_in_qq;
    localparam int DELAY = 0;
    logic[3:0] d_out;
    generate for(genvar i=0; i<4; i++) begin
    
        ODDRE1 #(.IS_C_INVERTED(1'b0), .IS_D1_INVERTED(1'b0), .IS_D2_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"), .SRVAL(1'b0)) ODDRE1_data (.Q(d_out[i]), .C(clkx4), .D1(tx_data[i*2+0]), .D2(tx_data[i*2+1]), .SR(reset_pipe[0]));  
        OBUFDS OBUFDS_data (.I(d_out[i]), .O(d_out_p[i]),  .OB(d_out_n[i]));   
        
        IBUFDS IBUFDS_data (.I(d_in_p[i]), .IB(d_in_n[i]), .O(d_in[i])); 
        //input_delay #(.DELAY(DELAY)) idelay_db (.din(d_in[i]), .dout(d_in_del[i]));       
        IDDRE1 #(.DDR_CLK_EDGE("SAME_EDGE"), .IS_CB_INVERTED(1'b1), .IS_C_INVERTED(1'b0)) IDDRE1_inst (.Q1(d_in_q[i*2+1]), .Q2(d_in_q[i*2+0]), .C(rxclk),.CB(rxclk), .D(d_in_del[i]), .R(1'b0));
        
    end endgenerate
    assign d_in_del = d_in;


    logic error=0; 
    logic[7:0] inc_sum;
    assign inc_sum = d_in_qq+1;
    always_ff @(posedge rxclk) begin
        d_in_qq <= d_in_q;
        error <= (d_in_q != inc_sum);        
    end

    // debug
    zmod_ila ila_inst (.clk(rxclk), .probe0({error, d_in_q})); // 9

endmodule



/*
   ODDRE1 #(
      .IS_C_INVERTED(1'b0),           // Optional inversion for C
      .IS_D1_INVERTED(1'b0),          // Unsupported, do not use
      .IS_D2_INVERTED(1'b0),          // Unsupported, do not use
      .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
      .SRVAL(1'b0)                    // Initializes the ODDRE1 Flip-Flops to the specified value (1'b0, 1'b1)
   )
   ODDRE1_inst (
      .Q(Q),   // 1-bit output: Data output to IOB
      .C(C),   // 1-bit input: High-speed clock input
      .D1(D1), // 1-bit input: Parallel data input 1
      .D2(D2), // 1-bit input: Parallel data input 2
      .SR(SR)  // 1-bit input: Active-High Async Reset
   );

    IDDRE1 #(
        .DDR_CLK_EDGE("OPPOSITE_EDGE"), // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
        .IS_CB_INVERTED(1'b0), // Optional inversion for CB
        .IS_C_INVERTED(1'b0) // Optional inversion for C
    ) IDDRE1_inst (
        .Q1(Q1), // 1-bit output: Registered parallel output 1
        .Q2(Q2), // 1-bit output: Registered parallel output 2
        .C(C), // 1-bit input: High-speed clock
        .CB(CB), // 1-bit input: Inversion of High-speed clock C
        .D(D), // 1-bit input: Serial Data Input
        .R(R) // 1-bit input: Active High Async Reset
    );

*/
