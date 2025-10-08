`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 15:57:40
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input noisy_btn,
    input clk,
    input rst,
    output reg updated_btn
    );
        
    reg [16:0] counter;
    reg stable_btn;
    reg prev_btn;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            stable_btn <= 0;
            prev_btn <= 0;
            updated_btn <= 0;
            
        end else begin
            updated_btn <= 0;
            
            if (noisy_btn == stable_btn) begin
                counter <= 0;
                
            end else begin
                counter <= counter + 1;
                
                if (counter == 100000) begin
                    stable_btn <= noisy_btn; 
                    counter <= 0;
                end
            end
                        
         if (stable_btn && !prev_btn) begin
              updated_btn <= 1;
         end
                      
         prev_btn <= stable_btn;
      end
   end    
   
endmodule
