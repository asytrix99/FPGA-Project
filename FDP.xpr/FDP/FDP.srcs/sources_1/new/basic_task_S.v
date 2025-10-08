`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 15:48:32
// Design Name: 
// Module Name: basic_task_S
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


module basic_task_S(
    input clk,
    input slow_clk,
    input btnU, btnD, btnL, btnR,
    input [12:0] pixel_index,
    output reg [15:0]oled_data 
    );

    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire reset = 0;

    // circle parameters
    parameter radius = 10;
    wire [6:0] offset_x;
    wire [6:0] offset_y;
    wire [6:0] x;
    wire [6:0] y;     

    // coordinate system
    assign x = pixel_index % 96; 
    assign y = pixel_index / 96; 


    // circle drawing 
    wire [13:0]circle = (x > offset_x ? x - offset_x: offset_x - x) * (x > offset_x ? x - offset_x: offset_x - x)
        + (y > offset_y ? y - offset_y: offset_y - y) * (y > offset_y ? y - offset_y: offset_y - y);

    // hollow square drawing
    parameter thickness = 3;
    parameter len_square = 26;
    reg [6:0] offset_x_square = 3; //offset the square so its not touching the border
    reg [6:0] offset_y_square = 64 - len_square - 3;
    // outer square thats drawn in white
    wire outer_square = (x >= offset_x_square ) && (x < offset_x_square + len_square) && (y >= offset_y_square) && (y < offset_y_square + len_square)  && (x < 96 && y < 64);
    //inner square thats drawn in black
    wire inner_square = (x >= offset_x_square + thickness ) && (x < offset_x_square + len_square - thickness) && (y >= offset_y_square + thickness) && (y < offset_y_square+len_square - thickness);

    // number 7 drawing
    //y coordinate is flipped, zero is at top and increases towards the bottom
    wire top_part = (x >= 11) && (x < 19) && (y >= 64 - 23) && (y < 64 - 20)  && (x < 96 && y < 64);
    wire bot_part = (x >= 16)&& (x < 19) && (y >= 64- 20) && (y< 64 - 9)  && (x < 96 && y < 64);
    
    // circle movement code
    reg [2:0] dir = 3'b000;
    // movement speed of 40pixels per second == 40Hz clock
    wire clk_40;
    clk40 c (clk,clk_40);
    movement mv (clk_40, dir, offset_x, offset_y);
    always @ (posedge clk)begin
        if (btnU)
            dir <= 3'b001;
        else if (btnD)
            dir <= 3'b010;
        else if (btnL)
            dir <= 3'b011;
        else if (btnR)
            dir <= 3'b100;    
    end

    // update oled screen
    always @ (posedge slow_clk) begin
        if (circle <= radius * radius)
            oled_data = 16'hF800;  //red
        else if (outer_square && !inner_square)
            oled_data = 16'hFFFF;  //white
        else if (top_part || bot_part)
            oled_data = 16'h37E3; //light green
        else
            oled_data = 16'h0000;  //black
    end   

endmodule
