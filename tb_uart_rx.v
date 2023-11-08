`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2023 08:58:50
// Design Name: 
// Module Name: tb_uart_rx
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


module tb_uart_rx;
    // PARAMATERS    
    parameter   DATA_WIDTH  =   8;
    parameter   STOP_WIDTH  =   1;
    
    // INPUTS
    reg         i_clk;
    reg         i_tick;
    reg         i_reset;
    reg         i_rx_data;

    // OUTPUTS
    wire                    o_tick;
    wire                    o_rx_done_bit;
    wire [DATA_WIDTH-1:0]   o_data_byte;
    
    
    localparam                        period = 20;
    localparam                        demora = 52083;      //(1/baudrate)
    localparam [DATA_WIDTH-1:0] byte_to_rx = 8'b01101010;   //dato a mandar
    integer data_index = 0;
    integer stop_index = 0;

    br_generator tb_br (
        .i_clk(i_clk),
        .o_tick(ticks)
    );
    
    uart_rx tb_rx (
        .clk(i_clk),
        .reset(i_reset),
        .i_tick(ticks),
        .i_rx_data(i_rx_data),
        .o_rx_done_bit(o_rx_done_bit),
        .o_data_byte(o_data_byte)
    );
    
//    always @(posedge i_clk) 
//        i_tick <= o_tick;
        
    initial
    begin
        i_clk = 1'b0;
        i_tick  = 1'b0;
        i_rx_data = 1'b1;
        i_reset = 1'b1;
        
        #20
        i_reset = 1'b0;
        #demora
        
        i_rx_data = 1'b0;   // Bit de START
        #demora
        $display("idle");
        
        ////DATA
        for(data_index = 0; data_index < DATA_WIDTH; data_index = data_index +1)
        begin
            i_rx_data<= byte_to_rx[data_index];
            $display("data %d", byte_to_rx[data_index]);
            #demora;
        end
        
         ////STOP
        for(stop_index = 0; stop_index < STOP_WIDTH; stop_index = stop_index +1)
        begin
            i_rx_data= 1'b1; ////STOP
            $display("stop ");
            #demora;
        end
        #demora

        $display("data recibido %b \n", o_data_byte);
    
        if((o_data_byte == byte_to_rx))
          $display("correct");
        else
          $display("failed");
        $finish;
    end
    always #(period/2) i_clk = ~i_clk;
    
endmodule
