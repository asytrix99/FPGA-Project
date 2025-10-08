`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2025 00:46:42
// Design Name: 
// Module Name: vertical_movement
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


module vertical_movement(
    input clk,
    input STOP, 
    output reg [6:0] y_offset
    );
    
     // move left in 5 sec -> 135ms per offset
       
       reg STATE = 0; //0 to move down, 1 to move up
       reg [19:0] COUNT = 20'b0; 
       
       initial begin
           y_offset = 0;
       end
       
       always @ (posedge clk) begin
           if (STOP) begin 
               // Do nothing
           end 
           
           else if (!STATE) begin
               if (COUNT == 20'd844594) begin
                   COUNT <= 0;
                   if (y_offset == 36) begin
                       y_offset <= y_offset + 1;
                       STATE <= ~STATE;
                   end else begin
                       y_offset <= y_offset + 1;
                   end
               end else begin
                   COUNT <= COUNT + 1;
               end
               
           end else begin
               if (COUNT == 20'd844594) begin
                   COUNT <= 0;
                   
                   if (y_offset == 1) begin
                       y_offset <= y_offset - 1;
                       STATE <= ~STATE;
                   end else begin
                       y_offset <= y_offset - 1;
                   end
                   
               end else begin
                   COUNT <= COUNT + 1;
               end
           end
       end
    
endmodule
