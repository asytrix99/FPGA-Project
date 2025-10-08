`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 16:12:13
// Design Name: 
// Module Name: basic_task_P
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


module basic_task_P(
    input clk,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input btnC,
    input [12:0] pixel_index,
    output [15:0] pixel_data
    );
                
    task_p my_task (
        .clk(clk),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data)
    );    
    
endmodule
