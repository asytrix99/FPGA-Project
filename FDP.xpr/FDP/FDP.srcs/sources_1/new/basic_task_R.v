`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2025 22:05:51
// Design Name: 
// Module Name: basic_task_R
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


module basic_task_R(
    input led_clk,
    input rst,
    input sw1,
    input sw3,
    input frame_begin, 
    input sample_pixel,
    output reg [15:0] oled_data
    );
    
    // define localpara for color
    localparam BLUE = 16'h001F;
    localparam BLACK = 16'h0000;
    localparam ORANGE = 16'hFD20;
   
    
    // define oled output
    wire sending_pixels;
    wire pixel_index;
    
    reg [6:0] x;
    reg [5:0] y;
    
    // define offset
    wire [6:0] x_offset;
    horizontal_movement h_move (led_clk, sw1, x_offset);
    
    wire [6:0] y_offset;
    vertical_movement v_move (led_clk, sw3, y_offset);
    
    initial begin
        x = 7'b0;
        y = 6'b0;
    end
    
    always @ (posedge led_clk or posedge rst) begin
        if (rst) begin
            x <= 7'b0;
            y <= 6'b0;
        end else begin
            if (frame_begin) begin
                x <= 7'b0;
                y <= 6'b0;
            end else if (sample_pixel) begin
                oled_data <= BLACK;
                
                if (x >= x_offset && x <= (15 + x_offset) && 
                    ((y >= 19 && y <= 22) || (y >= 30 && y <= 33) || 
                    (y >= 41 && y <= 44))) begin
                    oled_data <= BLUE;
                end else if (x >= (12 + x_offset) && x <= (15 + x_offset) && 
                     ((y >= 23 && y <= 29) || (y >= 34 && y <= 40))) begin
                    oled_data <= BLUE;
                end
                
                if (x >= 40 && x <= 55 && 
                    ((y >= y_offset && y <= (3 + y_offset)) || 
                    (y >= (11 + y_offset) && y <= (14 + y_offset)) || 
                    (y >= (22 + y_offset) && y <= (25 + y_offset))
                    )) begin
                    oled_data <= ORANGE;
                end else if (((x >= 40 && x <= 43) || (x >= 52 && x <= 55)) && 
                            y >= (4 + y_offset) && 
                            y <= (10 + y_offset)) begin
                    oled_data <= ORANGE;
                end else if (x >= 52 && x <= 55 && 
                        y >= (15 + y_offset) && 
                        y <= (21 + y_offset)) begin
                    oled_data <= ORANGE;
                end   
                
                if (x == 7'd95) begin
                    x <= 0;
                    y <= (y == 6'd63) ? 0 : y + 1;
                end else begin
                    x <= x + 1;
                end
            end
        end
    end

endmodule
