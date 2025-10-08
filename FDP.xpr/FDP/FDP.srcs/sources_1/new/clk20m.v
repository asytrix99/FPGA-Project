`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 15:56:39
// Design Name: 
// Module Name: clk20m
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


module clk20m(
    input clk_in,
    output reg clk_out = 0
    );
    
    reg [24:0] count = 0;
    
    always @ (posedge clk_in) begin
        count <= (count == 25'd19_999_999) ? 0 : count + 1;
        clk_out <= (count == 25'd19_999_999) ? ~clk_out : clk_out;
    end
    
endmodule
