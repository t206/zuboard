module zmod_test (
    input   logic           base_clk,  // input reference clock
    output  logic           clk_out_p, clk_out_n,
    output  logic[3:0]      d_out_p,   d_out_n,
    input   logic           clk_in_p,  clk_in_n,
    input   logic[3:0]      d_in_p,    d_in_n
);

    // clock synthesis
    logic clk, clkx4, locked;
    zmod_clk_wiz clk_wiz_inst (.clk_in1(base_clk), .clkout(clk), .clkoutx4(clkx4), .locked(locked));    

    // pattern generation
    logic[3:0] tx_data=0, d_out;
    always_ff @(posedge clkx4) tx_data <= tx_data + 1;
    
    // transmit the tx clock
    OSERDESE3 #(.DATA_WIDTH(8), .INIT(1'b0), .IS_CLKDIV_INVERTED(1'b0), .IS_CLK_INVERTED(1'b0), .IS_RST_INVERTED(1'b0), .SIM_DEVICE("ULTRASCALE_PLUS"))
    OSERDESE3_clock (.CLK(clkx4), .CLKDIV(clk), .D(8'b10101010), .RST(1'b0), .OQ(clk_out), .T(1'b0), .T_OUT());
    OBUFDS OBUFDS_clk_out (.I(clk_out), .O(clk_out_p),  .OB(clk_out_n));   
    
    always_ff @(posedge clkx4) d_out <= tx_data; // IOB register

    // rx clocks
    logic rxdivclk, rxclk, rxlocked;
    zmod_clk_in_wiz clk_in_wiz_inst (.clk_in1_p(clk_in_p), .clk_in1_n(clk_in_n), .clkout(rxclk), .divclkout(rxdivclk), .locked(rxlocked));

    logic[3:0] d_in, d_in_q, d_in_qq;
    generate for(genvar i=0; i<4; i++) begin
        OBUFDS OBUFDS_data (.I(d_out[i]), .O(d_out_p[i]),  .OB(d_out_n[i]));   
        IBUFDS IBUFDS_data (.I(d_in_p[i]), .IB(d_in_n[i]), .O(d_in[i]));        
        IDDRE1 #(.DDR_CLK_EDGE("OPPOSITE_EDGE"), .IS_CB_INVERTED(1'b1), .IS_C_INVERTED(1'b0)) IDDRE1_inst (.Q1(d_in_q[i]), .Q2(), .C(rxclk),.CB(rxclk), .D(d_in[i]), .R(1'b0));
    end endgenerate


    logic error=0; 
    logic[3:0] inc_sum;
    assign inc_sum = d_in_qq+1;
    always_ff @(posedge rxclk) begin
        //d_in_q <= d_in; // IOB register
        d_in_qq <= d_in_q;
        error <= (d_in_q != inc_sum);        
    end

    // debug
    zmod_ila ila_inst (.clk(rxclk), .probe0({error, d_in_q})); // 4

endmodule



/*
IDDRE1 #(
.DDR_CLK_EDGE("OPPOSITE_EDGE"), // IDDRE1 mode (OPPOSITE_EDGE, SAME_EDGE, SAME_EDGE_PIPELINED)
.IS_CB_INVERTED(1'b0), // Optional inversion for CB
.IS_C_INVERTED(1'b0) // Optional inversion for C
)
IDDRE1_inst (
.Q1(Q1), // 1-bit output: Registered parallel output 1
.Q2(Q2), // 1-bit output: Registered parallel output 2
.C(C), // 1-bit input: High-speed clock
.CB(CB), // 1-bit input: Inversion of High-speed clock C
.D(D), // 1-bit input: Serial Data Input
.R(R) // 1-bit input: Active High Async Reset
);

*/
