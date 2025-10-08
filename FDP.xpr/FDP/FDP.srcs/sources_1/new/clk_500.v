`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 18:44:43
// Design Name: 
// Module Name: clk_500
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


module clk_500(
    input CLK,
    output reg blink
    );
    
    reg [13:0] COUNT;
        
    initial begin
        COUNT = 14'd000;
    end
    
    always @ (posedge CLK) begin
        COUNT <= (COUNT == 14'd99_999) ? 0 : COUNT + 1;
        blink <= (COUNT == 14'd99_999) ? ~blink : blink;
    end
endmodule
