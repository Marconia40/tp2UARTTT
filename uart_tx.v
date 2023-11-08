module uart_tx #(
    parameter   DATA_WIDTH  =   8,
                STOP_WIDTH  =   1
) 
(
    // INPUTS
    input [DATA_WIDTH - 1:0]    i_data_byte,
    input       clk,
    input       reset,
    input       i_tick,
    input       i_tx_signal,

    // OUTPUTS
    output wire  o_tx_done_bit,
    output wire     o_tx_data

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
    reg         tx_data         = 1'b1;
    reg         tx_done_bit     = 0;

    assign o_tx_data = tx_data;
    assign o_tx_done_bit = tx_done_bit;

    // Memoria
    always @(posedge clk ) begin
        if (reset) begin 
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

            STATE_IDLE: begin
                tx_data <= 1'b1;
                tick_counter <= 0;
                data_index <= 0;
                next_state <= STATE_IDLE;
                if (i_tx_signal == 1'b1) begin
                    next_state <= STATE_START; 
                    data_byte <= i_data_byte;
                end                                   
            end

            STATE_START: begin
                if (i_tick) begin
                    tx_data <= 1'b0;
                    if (tick_counter == 15) begin
                        next_state <= STATE_DATA;                        
                        tx_data <= 0;
                        data_index <= 0;
                        tick_counter <= 0;
                    end 
                    else begin
                        tick_counter <= tick_counter + 1;
                    end
                end
            end

            STATE_DATA: begin
                if (i_tick) 
                begin    
                    tx_data <= data_byte[data_index];
                    if (tick_counter == 15) 
                    begin
                        tick_counter <= 0;
                        if (data_index == DATA_WIDTH - 1) 
                        begin
                            tick_counter <= 0;
                            data_index <= 0;
                            stop_index <= 0;
                            tx_data <= 1'b1;
                            next_state <= STATE_STOP;
                        end 
                        else 
                            data_index <= data_index + 1;                        
                    end 
                    else 
                        tick_counter = tick_counter + 1;    
                end
            end

            STATE_STOP: begin
                if (i_tick) 
                begin
                    if (tick_counter == 15) 
                    begin
                        if (stop_index == STOP_WIDTH) 
                        begin
                            stop_index <= 0;
                            tick_counter <= 0;
                            tx_done_bit <= 1;
                            next_state <= STATE_IDLE;                            
                        end 
                        else 
                            stop_index <= stop_index + 1;
                    end 
                    else
                        tick_counter = tick_counter + 1; 
                end 
            end
        endcase
    end
    
endmodule