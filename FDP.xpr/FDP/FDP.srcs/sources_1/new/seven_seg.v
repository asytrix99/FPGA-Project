`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 18:38:58
// Design Name: 
// Module Name: seven_seg
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


module seven_seg(
    input clk,
    output reg [3:0] an,
    output reg [7:0] seg
    );
    
    localparam s = 8'b10010010;
    localparam one_decimal = 8'b01111001;
    localparam zero = 8'b11000000;
    localparam eight = 8'b10000000;
    
    wire clk_500;
    clk_500 u1 (clk, clk_500);
    
    reg [1:0] COUNT = 2'b00;
    
    always @ (posedge clk_500) begin
        if (COUNT == 2'b00) begin
            seg <= s;
            an <= 4'b0111;
            COUNT <= COUNT + 1;
        end else if (COUNT == 2'b01) begin
            seg <= one_decimal;
            an <= 4'b1011;
            COUNT <= COUNT + 1;
        end else if (COUNT == 2'b10) begin
            seg <= zero;
            an <= 4'b1101;
            COUNT <= COUNT + 1;
        end else begin
            seg <= eight;
            an <= 4'b1110;
            COUNT <= COUNT + 1;
        end

    end
    
    
endmodule
