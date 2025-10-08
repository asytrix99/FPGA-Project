`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 16:07:32
// Design Name: 
// Module Name: clk40
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


module clk40(
    input clk,
    output reg SLOW_CLOCK
    );
    
    reg [21:0] COUNT = 21'd0; 
    
    initial begin 
        SLOW_CLOCK = 0;
    end
    
    always @ (posedge clk) begin 
        COUNT <= (COUNT == 21'd1249999) ? 0 : COUNT + 1; 
        SLOW_CLOCK <= ( COUNT == 21'd0) ? ~SLOW_CLOCK : SLOW_CLOCK ; 
    end
    
endmodule
