module br_generator
#(
  //PARAMETERS
  // Valores del ejemplo de la presentacion
  // investigar la frecuencia de la placa
  parameter clk_frec  = 50.0, // 50MHz
  parameter baudrate = 19200

  )
  (
  //INPUTS
   input        i_clk,
   //OUTPUTS
   output     reg o_tick
   );
   
  localparam integer modulo = (clk_frec*1000000) / (baudrate * 16);
  reg [ $clog2 (modulo) - 1:0] contador;
  
  
  always @(posedge i_clk)
  begin
    if(contador < modulo)
        begin
            o_tick <= 0;
            contador <= contador + 1;
        end
    else
        begin
            o_tick <= 1;
            contador <= 0;
        end
  end      
        

   
endmodule