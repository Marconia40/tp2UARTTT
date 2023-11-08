`timescale 1ns / 1ps

module tb_top;
    
    //PARAMATERS
    parameter   DATA_WIDTH  =   8;
    parameter   STOP_WIDTH  =   1;

    //INPUTS
    reg     clk;
    reg     reset;
    reg     i_tx;

    //OUTPUTS
    wire    o_rx;
    wire    o_tx_done;

    localparam                  periodo     = 20;
    localparam                  demora      = 52083;
    localparam [DATA_WIDTH-1:0] dato_a      = 8'b00001010;   // A
    localparam [DATA_WIDTH-1:0] dato_b      = 8'b00010111;
    localparam [DATA_WIDTH-1:0] opcode      = 6'b100100;     //AND
    reg        [DATA_WIDTH-1:0] resultado   = 8'b0;
    reg                         tx_done   = 0;

    integer data_index = 0;
    integer stop_index = 0;
    
    assign o_tx_done = tx_done;

    top u_top(
        .clk(clk),
        .reset(reset),
        .i_tx(i_tx),
        .o_rx(o_rx),
        .o_tx_done(o_tx_done)
    );

    initial
    begin
        clk = 1'b0;
        i_tx = 1'b1;
        reset = 1'b1;
        
        #20
        reset = 1'b0;
        #demora
        
        i_tx = 1'b0;   // Bit de START
        #demora
        $display("idle");

         ////DATO A
        for(data_index = 0; data_index < DATA_WIDTH; data_index = data_index +1)
        begin
            i_tx <= dato_a[data_index];
            $display("data %d", i_tx);
            #demora;
        end

        ////STOP
        for(stop_index = 0; stop_index < STOP_WIDTH; stop_index = stop_index +1)
        begin
            i_tx= 1'b1; ////STOP
            $display("stop ");
            #demora;
        end
        #demora
        #demora
        #demora

        // Transmision dato B

        i_tx = 1'b0;   // Bit de START
        #demora
        $display("idle");

         ////DATO B
        for(data_index = 0; data_index < DATA_WIDTH; data_index = data_index +1)
        begin
            i_tx <= dato_b[data_index];
            $display("data %d", i_tx);
            #demora;
        end

        ////STOP
        for(stop_index = 0; stop_index < STOP_WIDTH; stop_index = stop_index +1)
        begin
            i_tx= 1'b1; ////STOP
            $display("stop ");
            #demora;
        end
        #demora
        #demora
        #demora

        // Transmision opcode
        i_tx = 1'b0;   // Bit de START
        #demora
        $display("idle");

         //// OPCODE
        for(data_index = 0; data_index < DATA_WIDTH; data_index = data_index +1)
        begin
            i_tx <= opcode[data_index];
            $display("data %d", i_tx);
            #demora;
        end

        ////STOP
        for(stop_index = 0; stop_index < STOP_WIDTH; stop_index = stop_index +1)
        begin
            i_tx= 1'b1; ////STOP
            $display("stop ");
            #demora;
        end
        #demora
        #demora
        #demora
        $finish;
    end
    
    always @(posedge clk)
    begin
        if(o_rx == 0)
        begin
            $display("start bit detectado a tiempo");
            ////DATA
            for(data_index = 0; data_index < DATA_WIDTH; data_index = data_index +1)
            begin
                //i_data_byte <= byte_to_tx[data_index];
                resultado[data_index] <= o_rx;
                $display("data %d", o_rx);
                #demora;
            end
            
            ////STOP
            for(stop_index = 0; stop_index < STOP_WIDTH; stop_index = stop_index +1)
            begin
                tx_done = 1'b1; ////STOP
                $display("stop ");
                #demora;
            end
        end
    end
    
    
    always #(periodo/2) clk = ~clk;

endmodule