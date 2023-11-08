`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2023 16:25:03 PM
// Design Name: 
// Module Name: INTERFAZ
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


module interface
#(
  //PARAMETERS
  parameter     SIZEDATA = 8,
  parameter      SIZEOP = 6
  )
  (
  //INPUTS
  input                            i_clock,
  input                            i_reset,
  input                            i_rx_done,
  input signed  [SIZEDATA - 1:0]   i_rx_data,
  input         [SIZEDATA - 1:0]   i_alu_result,

  //OUTPUTS
  output  reg   [SIZEDATA - 1:0]   o_alu_datoa,
  output  reg   [SIZEDATA - 1:0]   o_alu_datob,
  output  reg   [SIZEDATA - 1:0]   o_alu_opcode,
  output  reg   [SIZEDATA - 1:0]   o_tx_result,
  output  reg                      o_tx_signal
  );
  
  // One-Hot, One-Cold  
  localparam STATE_OPA    = 4'b0001;
  localparam STATE_OPB    = 4'b0010;
  localparam STATE_OPCODE = 4'b0100;
  localparam STATE_RESULT = 4'b1000;
  
  reg [3:0]  current_state  = 0;
  reg [3:0]  next_state     = 0;
//  reg              rx_valid = 1;
//  reg [SIZEDATA - 1:0] operando_a;
//  reg [SIZEDATA - 1:0] operando_b;
//  reg [SIZEDATA - 1:0] opcode;
//  reg [SIZEDATA - 1:0] result;
  
   always @(posedge i_clock) //MEMORIA
        if (i_reset)
                current_state <= STATE_OPA; //ESTADO INICIAL
        else
                current_state <= next_state;
    
   
      
  always @(posedge i_clock) begin: next_state_logic
    case (current_state)
        STATE_OPA:
        begin
            if(i_rx_done)
            begin
                o_alu_datoa <= i_rx_data;
                o_alu_datob <= 0;
                o_alu_opcode <= 0;
                o_tx_result <= 0;
                o_tx_signal <= 0;
                next_state <= STATE_OPB;
            end
            else
            begin              
                next_state <= STATE_OPA;
            end
        end
        
        STATE_OPB:
        begin
           if(i_rx_done)
            begin
                //operando_a <= o_alu_datoa;
                o_alu_datob <= i_rx_data;
                //opcode <= o_alu_opcode;
                //result <= o_tx_result;
                next_state <= STATE_OPCODE;
            end
            else
            begin             
                next_state <= STATE_OPB;
            end
        end
        
        STATE_OPCODE:
        begin
            if(i_rx_done)
            begin
                //operando_a <= o_alu_datoa;
                //operando_b <= o_alu_datob;
                o_alu_opcode <= i_rx_data;            
                //result <= o_tx_result;
                next_state <= STATE_RESULT;
            end
            else
            begin 
                next_state <= STATE_OPCODE;
            end
        end
        
        STATE_RESULT:
        begin
            //operando_a <= o_alu_datoa;
            //operando_b <= o_alu_datob;
            //opcode <= o_alu_opcode;
            o_tx_result <= i_alu_result;
            o_tx_signal <= 1;
            next_state <= STATE_OPA;
        end
              
        default:
        begin
            o_alu_datoa <= 0;
            o_alu_datob <= 0;
            o_alu_opcode <= 0;
            o_tx_result <= 0;
            next_state <= STATE_OPA;
        end
        
    endcase
    end

endmodule