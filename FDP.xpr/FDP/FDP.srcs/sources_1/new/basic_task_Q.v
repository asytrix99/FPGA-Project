`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 16:00:32
// Design Name: 
// Module Name: basic_task_Q
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


module basic_task_Q(
    input CLOCK,
    input clk_6p25m,
    input RST,
    input BTNL, BTNC, BTNR,
    input [12:0] pixel_index,
    output [15:0] oled_data
    );
    wire frame_begin, sending_pixels, sample_pixel;
    
    wire clk20m_sig;

    clk20m clk_20m (CLOCK, clk20m_sig);
    
    wire updated_btnl, updated_btnc, updated_btnr;
    reg [24:0] counter;
    
    debouncer left_db (BTNL, CLOCK, RST, updated_btnl);
    debouncer mid_db (BTNC, CLOCK, RST, updated_btnc);
    debouncer right_db (BTNR, CLOCK, RST, updated_btnr);   
    
    wire [6:0] length = pixel_index % 96;
    wire [6:0] width = pixel_index / 96;
    
    localparam RED = 16'hF800;
    localparam GREEN = 16'h07E0;
    localparam BLUE = 16'h001F;
    localparam YELLOW = 16'hFFE0;
    localparam WHITE = 16'hFFFF;
    localparam BLACK = 16'h0000;
    localparam MAGENTA = 16'hF81F;
    
    reg [2:0] left_state; 
    reg [2:0] mid_state;  
    reg [2:0] right_state;
    
    reg [15:0] oled_in;
    assign oled_data = oled_in;
    
    function [2:0] next_state(input [2:0] curr_state);
        next_state = (curr_state == 4) ? 0 : (curr_state + 1);
    endfunction
    
    function [15:0] state_colour(input [2:0] state);
        case (state)
            0: state_colour = RED;
            1: state_colour = BLUE;
            2: state_colour = YELLOW;
            3: state_colour = GREEN;
            4: state_colour = WHITE;
            default: state_colour = BLACK;
        endcase
     endfunction
    
    always @ (posedge CLOCK or posedge RST) begin
        if (RST) left_state <= 0;
        else if (updated_btnl) left_state <= next_state(left_state);
    end
    
    always @ (posedge CLOCK or posedge RST) begin
        if (RST) mid_state <= 3;
        else if (updated_btnc) mid_state <= next_state(mid_state);
    end
    
    always @ (posedge CLOCK or posedge RST) begin
        if (RST) right_state <= 1;
        else if (updated_btnr) right_state <= next_state(right_state);
    end
    
    always @ (*) begin
        oled_in = BLACK;
        if (length >= 9 && length <= 28 && width >= 37 && width <= 56) oled_in = state_colour(left_state);
        if (length >= 38 && length <= 57 && width >= 37 && width <= 56) oled_in = state_colour(mid_state);
        if (length >= 67 && length <= 86 && width >= 37 && width <= 56) oled_in = state_colour(right_state);
        if (state_colour(left_state) == GREEN && state_colour(mid_state) == WHITE && state_colour(right_state) == BLUE) begin
            if (length >= 87 && length <= 92 && width <= 15 && width >= 3) oled_in = MAGENTA;
            if (length >= 87 && length <= 90 && width <= 15 && width >= 5) oled_in = BLACK;
        end
    end
           
        
endmodule
