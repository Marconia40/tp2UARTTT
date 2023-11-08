`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2023 21:03:14
// Design Name: 
// Module Name: tb_uart_tx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_uart_tx;
    //Parametros
    parameter DATA_WIDTH = 8;
    parameter STOP_WIDTH = 1;
    
    //INPUTS
    reg         i_clk;
    reg         i_tick;
    reg         i_reset;
    reg         i_tx_signal;
    reg [DATA_WIDTH-1:0]      i_data_byte = 8'b11101010;
    
    //OUTPUTS
    wire        o_tick;
    wire        o_tx_done_bit;
    wire        o_tx_data;
    
    localparam      period = 20;
    localparam      demora = 52083;
    reg [DATA_WIDTH-1:0] byte_from_tx = 8'b0;
    integer data_index = 0;
    integer stop_index = 0;
    
    br_generator tb_br (
        .i_clk(i_clk),
        .o_tick(o_tick)
    );
    
    uart_tx tb_tx (
        .clk(i_clk),
        .i_tick(i_tick),
        .reset(i_reset),
        .i_data_byte(i_data_byte),
        .i_tx_signal(i_tx_signal),
        .o_tx_done_bit(o_tx_done_bit),
        .o_tx_data(o_tx_data)
    );
    
        always @(posedge i_clk) 
        i_tick <= o_tick;
        
    initial
    begin
        i_clk = 1'b0;
        i_tick  = 1'b0;
        i_tx_signal = 1'b0;
        i_reset = 1'b1;
        
        #20
        i_reset = 1'b0;
        #demora
        
        i_tx_signal = 1'b1;   // Bit de START
        #demora
        $display("idle");
        
        if(o_tx_data == 0)
            begin
            #demora
            $display("start bit detectado a tiempo");
            end
        ////DATA
        for(data_index = 0; data_index < DATA_WIDTH; data_index = data_index +1)
        begin
            //i_data_byte <= byte_to_tx[data_index];
            byte_from_tx[data_index] <= o_tx_data;
            $display("data %d", o_tx_data);
            #demora;
        end
        
         ////STOP
        for(stop_index = 0; stop_index < STOP_WIDTH; stop_index = stop_index +1)
        begin
            i_tx_signal= 1'b1; ////STOP
            $display("stop ");
            #demora;
        end
        #demora

        $display("data recibido %b \n", o_tx_data);
    
        if((i_data_byte == byte_from_tx))
          $display("correct");
        else
          $display("failed");
        $finish;
    end
    always #(period/2) i_clk = ~i_clk;
    
endmodule