module top    #(
   //PARAMETERS
   parameter    SIZEDATA = 8,
   parameter    SIZEOP = 6,
   parameter    DATA_WIDTH = 8,
   parameter    STOP_WIDTH = 1
   )
  (
  //INPUTS
   input        clk,
   input        reset,
   input        i_tx,
   //OUTPUTS
   output       o_rx,
   output       o_tx_done
   );
   
       // Wires.
    wire [SIZEDATA - 1 : 0]    operando_a;
    wire [SIZEDATA - 1 : 0]    operando_b;
    wire [SIZEOP - 1 : 0]      opcode;
    wire [SIZEDATA - 1 : 0]    result;
    wire [DATA_WIDTH - 1 : 0]    rx_data_byte;
    wire [DATA_WIDTH - 1 : 0]    tx_data_byte;
    wire                       rx_done;
    wire                       tx_signal;    
    wire                       ticks;

   ALU u_alu (
    .i_valA        (operando_a),
    .i_valB        (operando_b),
    .i_opcode       (opcode),
    .o_result       (result)
    );

   interface u_intf (
    .i_clock         (clk),
    .i_reset         (reset),
    .i_rx_done       (rx_done),
    .i_rx_data       (rx_data_byte),
    .i_alu_result    (result),
    .o_alu_datoa     (operando_a),
    .o_alu_datob     (operando_b),
    .o_alu_opcode    (opcode),
    .o_tx_result     (tx_data_byte),
    .o_tx_signal     (tx_signal)
    );
    
    uart u_uart (
    .clk            (clk),
    .reset          (reset),
    .i_tx_signal    (tx_signal),
    .i_rx_data      (i_tx),
    .i_data_byte    (tx_data_byte),
    .o_data_byte    (rx_data_byte),
    .o_rx_done_bit  (rx_done),
    .o_tx_data      (o_rx),
    .o_tx_done_bit  (o_tx_done)
    );
   
endmodule