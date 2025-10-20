`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 14:05:00
// Design Name: 
// Module Name: function_selector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Selects function type based on switches
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module function_selector(
    input wire CLOCK,
    input wire RST,
    input wire [1:0] sw_mode,       // SW[15:14] for function selection
    output reg [1:0] function_type  // 00=Quadratic, 01=Linear, 10=Constant, 11=Logarithmic
    );
    
    always @(posedge CLOCK or posedge RST) begin
        if (RST) begin
            function_type <= 2'b00;  // Default to quadratic
        end else begin
            function_type <= sw_mode;
        end
    end
    
endmodule
