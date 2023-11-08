module uart #(
    parameter   DATA_WIDTH  =   8,
                STOP_WIDTH  =   1
) 
(
    //INPUTS
    input       clk,
    input       reset,
    input       i_tx_signal,
    input       i_rx_data,
    input [DATA_WIDTH - 1:0]    i_data_byte,

    //OUTPUTS
    output [DATA_WIDTH - 1:0]   o_data_byte,
    output      o_rx_done_bit,
    output      o_tx_data,
    output      o_tx_done_bit
);

    br_generator tb_br (
    .i_clk(clk),
    .o_tick(ticks)
    );
    
    uart_tx transmisor (
        .clk(clk),
        .i_tick(ticks),
        .reset(reset),
        .i_data_byte(i_data_byte),
        .i_tx_signal(i_tx_signal),
        .o_tx_done_bit(o_tx_done_bit),
        .o_tx_data(o_tx_data)
    );

    uart_rx receptor (
        .clk(clk),
        .reset(reset),
        .i_tick(ticks),
        .i_rx_data(i_rx_data),
        .o_rx_done_bit(o_rx_done_bit),
        .o_data_byte(o_data_byte)
    );
      
endmodule