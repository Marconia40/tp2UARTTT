module uart_rx 
#(
    parameter   DATA_WIDTH  =   8,
                STOP_WIDTH  =   1
) 
(   // INPUTS
    input       clk,
    input       reset,
    input       i_tick,
    input       i_rx_data,
    // OUTPUTS
    output                     o_rx_done_bit,
    output [DATA_WIDTH - 1:0]   o_data_byte
);


    localparam  STATE_IDLE   = 4'b0001;
    localparam  STATE_START  = 4'b0010;
    localparam  STATE_DATA   = 4'b0100;
    localparam  STATE_STOP   = 4'b1000;

    reg [DATA_WIDTH - 1:0]  data_byte = 0;
    reg [3:0]   tick_counter    = 0;
    reg [3:0]   current_state   = 0;
    reg [3:0]   next_state      = 0;
    reg [2:0]   data_index      = 0;
    reg [2:0]   stop_index      = 0;
    reg         rx_data         = 1'b1;
    reg         rx_done_bit     = 0;

    assign o_data_byte = data_byte;
    assign o_rx_done_bit = rx_done_bit;
    // assign rx_data = i_rx_data;

    // Datos entrantes
    always @(posedge clk ) 
        rx_data <= i_rx_data;

    // Memoria
    always @(posedge clk ) begin
        if (reset) begin 
            current_state <= STATE_IDLE;    // Estado inicial
            tick_counter <= 0;
            data_index <= 0;
            stop_index <= 0;
        end
        else
            current_state <= next_state;
    end

    // Maquina de estados
    always @(posedge clk ) begin
        case (current_state)
            STATE_IDLE: 
              begin 
                data_index <= 0;
                tick_counter <= 0;
                
                if (rx_data == 1'b0) begin // Bit de inicio detectado                
                    next_state <= STATE_START;                 
                    rx_done_bit <= 0;    
                end
                else
                    next_state <= STATE_IDLE;   
              end
                 
            
            STATE_START:
              begin
                if (i_tick) begin
                    if (tick_counter == 7) begin
                        if (rx_data == 1'b0) begin
                            tick_counter <= 0;
                            next_state <= STATE_DATA;                        
                        end 
                        else begin
                            tick_counter <= 0;
                            next_state <= STATE_IDLE;                        
                        end
                    end
                    else 
                    begin
                        tick_counter <= tick_counter + 1;
                        next_state <= STATE_START;
                    end
                end
              end
            
            STATE_DATA:
            begin    
                if (i_tick) 
                begin
                    if (tick_counter == 15) 
                    begin
                        tick_counter <= 0;
                        data_byte[data_index] <= rx_data;
                        
                        if (data_index < DATA_WIDTH - 1) 
                        begin
                            data_index <= data_index + 1;
                            next_state <= STATE_DATA;
                        end 
                        else 
                        begin
                            data_index <= 0;                 
                            next_state <= STATE_STOP;
                        end
                    end 
                    else 
                        tick_counter <= tick_counter + 1; 
                end
            end
            
            STATE_STOP: 
            begin                
                if (i_tick) 
                begin
                    if (tick_counter == 15) 
                    begin
                        if(rx_data == 1'b1)
                        begin    
                            if(stop_index < STOP_WIDTH) 
                            begin
                                stop_index <= stop_index + 1;
                                tick_counter <= 0;                          
                            end
                            else 
                            begin
                                rx_done_bit <= 1'b1;
                                current_state <= STATE_IDLE;
                            end
                        end
                        else 
                        begin
                            tick_counter <= 0;
                            data_index <= 0;
                            stop_index <= 0;
                            next_state <= STATE_IDLE;
                        end
                    end 
                    else 
                        tick_counter <= tick_counter + 1;                
                end
            end
        endcase
    end

endmodule