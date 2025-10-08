`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 16:16:03
// Design Name: 
// Module Name: task_P
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


module task_p (
    input clk,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input btnC,
    input [12:0] pixel_index,
    output reg [15:0] pixel_data
);

    wire [6:0] x;
    wire [5:0] y;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;

    parameter BLACK = 16'h0000;
    parameter RED = 16'hF800;
    parameter GREEN = 16'h07E0;
    parameter WHITE = 16'hFFFF;
    parameter MAGENTA = 16'hF81F;

    reg [16:0] count_1ms = 0;
    reg clk_1ms = 0;
    
    always @ (posedge clk) 
    begin
        count_1ms <= (count_1ms == 49999) ? 0 : count_1ms + 1;
        if (count_1ms == 49999)
            clk_1ms <= ~clk_1ms;
    end
    
    reg show_left = 1;
    reg btnL_prev = 0;
    reg [8:0] debounce_cnt_L = 0;
    reg debouncing_L = 0;
    
    always @ (posedge clk_1ms) 
    begin
        if (btnL && !btnL_prev && !debouncing_L) 
            begin
                show_left <= ~show_left;
                debouncing_L <= 1;
                debounce_cnt_L <= 0;
            end
        
        if (debouncing_L)
            debounce_cnt_L <= (debounce_cnt_L >= 200) ? debounce_cnt_L : debounce_cnt_L + 1;
        
        if (debounce_cnt_L >= 200)
            debouncing_L <= 0;
        
        btnL_prev <= btnL;
    end
    
    reg show_right = 1;
    reg btnR_prev = 0;
    reg [8:0] debounce_cnt_R = 0;
    reg debouncing_R = 0;
    
    always @ (posedge clk_1ms) 
    begin
        if (btnR && !btnR_prev && !debouncing_R) 
        begin
            show_right <= ~show_right;
            debouncing_R <= 1;
            debounce_cnt_R <= 0;
        end
        
        if (debouncing_R)
            debounce_cnt_R <= (debounce_cnt_R >= 200) ? debounce_cnt_R : debounce_cnt_R + 1;
        
        if (debounce_cnt_R >= 200)
            debouncing_R <= 0;
        
        btnR_prev <= btnR;
    end

    parameter integer RADIUS = 8;
    parameter integer CIRCLE_X = 12;
    parameter integer CIRCLE_Y = 12;
    
    wire [6:0] dx_abs = (x > CIRCLE_X) ? (x - CIRCLE_X) : (CIRCLE_X - x);
    wire [6:0] dy_abs = (y > CIRCLE_Y) ? (y - CIRCLE_Y) : (CIRCLE_Y - y);
    
    wire [13:0] circle_dist = dx_abs * dx_abs + dy_abs * dy_abs;
    wire in_circle = (circle_dist <= RADIUS * RADIUS);
    
    wire any_btn = btnL || btnR || btnU || btnD || btnC;
    wire [15:0] circle_color = any_btn ? MAGENTA : WHITE;

    wire top_5 = (x >= 28 && x <= 52) && (y >= 9 && y <= 14);
    wire mid_5 = (x >= 28 && x <= 52) && (y >= 28 && y <= 33);
    wire bot_5 = (x >= 28 && x <= 52) && (y >= 48 && y <= 53);
    wire left_5 = (x >= 28 && x <= 33) && (y >= 9 && y <= 33);
    wire right_5 = (x >= 47 && x <= 52) && (y >= 28 && y <= 53);
    
    wire in_5 = top_5 || mid_5 || bot_5 || left_5 || right_5;

    wire top_2 = (x >= 61 && x <= 85) && (y >= 9 && y <= 14);
    wire mid_2 = (x >= 61 && x <= 85) && (y >= 28 && y <= 33);
    wire bot_2 = (x >= 61 && x <= 85) && (y >= 48 && y <= 53);
    wire right_2 = (x >= 80 && x <= 85) && (y >= 9 && y <= 33);
    wire left_2 = (x >= 61 && x <= 66) && (y >= 28 && y <= 53);
    
    wire in_2 = top_2 || mid_2 || bot_2 || right_2 || left_2;

    always @ (*) 
    begin
        pixel_data = in_circle ? circle_color :
                     (show_left && in_5) ? RED :
                     (show_right && in_2) ? GREEN :
                     BLACK;
    end

endmodule
