`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2025 14:08:55
// Design Name: 
// Module Name: clk6p25m
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


module clk6p25m(
    input CLK,
    output reg blink
    );
    
    reg [3:0] COUNT;
    
    initial begin
        COUNT = 3'b000;
    end
    
    always @ (posedge CLK) begin
        COUNT <= (COUNT == 3'b111) ? 0 : COUNT + 1;
        blink <= (COUNT == 3'b111) ? ~blink : blink;
    end
    
endmodule
