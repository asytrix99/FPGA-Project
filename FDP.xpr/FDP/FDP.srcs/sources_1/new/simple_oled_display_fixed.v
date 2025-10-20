`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 13:37:09
// Design Name: 
// Module Name: input_top
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

module simple_oled_display(
    input  wire clk,
    input  wire reset,
    input  wire [12:0] pixel_index,

    input  wire [1:0] active_coeff,
    input  wire [1:0] cursor_pos,
    input  wire [3:0] digit_a_0, digit_a_1, digit_a_2, digit_a_3,
    input  wire [3:0] digit_b_0, digit_b_1, digit_b_2, digit_b_3,
    input  wire [3:0] digit_c_0, digit_c_1, digit_c_2, digit_c_3,
    input  wire sign_a, sign_b, sign_c,
    input  wire [1:0] function_type,
    input  wire clk_10Hz,

    output reg  [15:0] pixel_data
);

    localparam WIDTH  = 96;
    localparam HEIGHT = 64;
    localparam BLACK  = 16'h0000;
    localparam WHITE  = 16'hFFFF;
    localparam CYAN   = 16'h07FF;
    localparam YELLOW = 16'hFFE0;

    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;

    reg blink;
    always @(posedge clk_10Hz or posedge reset)
        if (reset) blink <= 0;
        else        blink <= ~blink;

    // ---------- Standard Font ROM (7 pixels wide) ----------
    function [6:0] font_row;
        input [7:0] ch;
        input [2:0] row;
        case (ch)
            "0": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1000001;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b1000001;3'd5:font_row=7'b1000001;
                               3'd6:font_row=7'b0111110;default:font_row=7'b0;endcase
            "1": case(row)3'd0:font_row=7'b0000100;3'd1:font_row=7'b0001100;
                               3'd2:font_row=7'b0000100;3'd3:font_row=7'b0000100;
                               3'd4:font_row=7'b0000100;3'd5:font_row=7'b0000100;
                               3'd6:font_row=7'b0111111;default:font_row=7'b0;endcase
            "2": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b0000001;
                               3'd2:font_row=7'b0000010;3'd3:font_row=7'b0001100;
                               3'd4:font_row=7'b0010000;3'd5:font_row=7'b0100000;
                               3'd6:font_row=7'b1111111;default:font_row=7'b0;endcase
            "3": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b0000001;
                               3'd2:font_row=7'b0001110;3'd3:font_row=7'b0000001;
                               3'd4:font_row=7'b0000001;3'd5:font_row=7'b0000001;
                               3'd6:font_row=7'b0111110;default:font_row=7'b0;endcase
            "4": case(row)3'd0:font_row=7'b1000010;3'd1:font_row=7'b1000010;
                               3'd2:font_row=7'b1111111;3'd3:font_row=7'b0000010;
                               3'd4:font_row=7'b0000010;3'd5:font_row=7'b0000010;
                               3'd6:font_row=7'b0000010;default:font_row=7'b0;endcase
            "5": case(row)3'd0:font_row=7'b1111111;3'd1:font_row=7'b1000000;
                               3'd2:font_row=7'b1111110;3'd3:font_row=7'b0000001;
                               3'd4:font_row=7'b0000001;3'd5:font_row=7'b0000001;
                               3'd6:font_row=7'b1111110;default:font_row=7'b0;endcase
            "6": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000000;
                               3'd2:font_row=7'b1111110;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b1000001;3'd5:font_row=7'b1000001;
                               3'd6:font_row=7'b0111110;default:font_row=7'b0;endcase
            "7": case(row)3'd0:font_row=7'b1111111;3'd1:font_row=7'b0000001;
                               3'd2:font_row=7'b0000010;3'd3:font_row=7'b0000100;
                               3'd4:font_row=7'b0001000;3'd5:font_row=7'b0010000;
                               3'd6:font_row=7'b0100000;default:font_row=7'b0;endcase
            "8": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b0111110;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b1000001;3'd5:font_row=7'b1000001;
                               3'd6:font_row=7'b0111110;default:font_row=7'b0;endcase
            "9": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1000001;3'd3:font_row=7'b0111111;
                               3'd4:font_row=7'b0000001;3'd5:font_row=7'b0000001;
                               3'd6:font_row=7'b0111110;default:font_row=7'b0;endcase
            "+": case(row)3'd2:font_row=7'b0000100;3'd3:font_row=7'b0111110;
                               3'd4:font_row=7'b0000100;default:font_row=7'b0;endcase
            "-": case(row)3'd3:font_row=7'b0111110;default:font_row=7'b0;endcase
            "A": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1111111;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b1000001;default:font_row=7'b0;endcase
            "B": case(row)3'd0:font_row=7'b1111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1111110;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b1111110;default:font_row=7'b0;endcase
            "C": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1000000;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b0111110;default:font_row=7'b0;endcase
            default: font_row=7'b0;
        endcase
    endfunction

    // ---------- Narrow Font ROM (4 pixels wide for compact equation) ----------
    function [3:0] narrow_font_row;
        input [7:0] ch;
        input [2:0] row;
        case (ch)
            "0": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b1010;3'd3:narrow_font_row=4'b1010;
                               3'd4:narrow_font_row=4'b1010;3'd5:narrow_font_row=4'b1010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "1": case(row)3'd0:narrow_font_row=4'b0100;3'd1:narrow_font_row=4'b1100;
                               3'd2:narrow_font_row=4'b0100;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b0100;3'd5:narrow_font_row=4'b0100;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "2": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b0010;
                               3'd2:narrow_font_row=4'b0010;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b1000;3'd5:narrow_font_row=4'b1000;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "3": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b0010;
                               3'd2:narrow_font_row=4'b0110;3'd3:narrow_font_row=4'b0010;
                               3'd4:narrow_font_row=4'b0010;3'd5:narrow_font_row=4'b0010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "4": case(row)3'd0:narrow_font_row=4'b1010;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b1110;3'd3:narrow_font_row=4'b0010;
                               3'd4:narrow_font_row=4'b0010;3'd5:narrow_font_row=4'b0010;
                               3'd6:narrow_font_row=4'b0010;default:narrow_font_row=4'b0;endcase
            "5": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b1000;
                               3'd2:narrow_font_row=4'b1110;3'd3:narrow_font_row=4'b0010;
                               3'd4:narrow_font_row=4'b0010;3'd5:narrow_font_row=4'b0010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "6": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b1000;
                               3'd2:narrow_font_row=4'b1110;3'd3:narrow_font_row=4'b1010;
                               3'd4:narrow_font_row=4'b1010;3'd5:narrow_font_row=4'b1010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "7": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b0010;
                               3'd2:narrow_font_row=4'b0010;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b0100;3'd5:narrow_font_row=4'b1000;
                               3'd6:narrow_font_row=4'b1000;default:narrow_font_row=4'b0;endcase
            "8": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b1110;3'd3:narrow_font_row=4'b1010;
                               3'd4:narrow_font_row=4'b1010;3'd5:narrow_font_row=4'b1010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "9": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b1010;3'd3:narrow_font_row=4'b1110;
                               3'd4:narrow_font_row=4'b0010;3'd5:narrow_font_row=4'b0010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "+": case(row)3'd2:narrow_font_row=4'b0100;3'd3:narrow_font_row=4'b1110;
                               3'd4:narrow_font_row=4'b0100;default:narrow_font_row=4'b0;endcase
            "-": case(row)3'd3:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "=": case(row)3'd2:narrow_font_row=4'b1110;3'd4:narrow_font_row=4'b1110;
                               default:narrow_font_row=4'b0;endcase
            "a": case(row)3'd1:narrow_font_row=4'b1110;3'd2:narrow_font_row=4'b0010;
                               3'd3:narrow_font_row=4'b1110;3'd4:narrow_font_row=4'b1010;
                               3'd5:narrow_font_row=4'b1010;3'd6:narrow_font_row=4'b0110;
                               default:narrow_font_row=4'b0;endcase
            "b": case(row)3'd0:narrow_font_row=4'b1000;3'd1:narrow_font_row=4'b1000;
                               3'd2:narrow_font_row=4'b1110;3'd3:narrow_font_row=4'b1010;
                               3'd4:narrow_font_row=4'b1010;3'd5:narrow_font_row=4'b1010;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "c": case(row)3'd1:narrow_font_row=4'b1110;3'd2:narrow_font_row=4'b1000;
                               3'd3:narrow_font_row=4'b1000;3'd4:narrow_font_row=4'b1000;
                               3'd5:narrow_font_row=4'b1000;3'd6:narrow_font_row=4'b1110;
                               default:narrow_font_row=4'b0;endcase
            "x": case(row)3'd0:narrow_font_row=4'b1010;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b0100;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b1010;3'd5:narrow_font_row=4'b1010;
                               default:narrow_font_row=4'b0;endcase
            "y": case(row)3'd0:narrow_font_row=4'b1010;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b0100;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b0100;3'd5:narrow_font_row=4'b1000;
                               default:narrow_font_row=4'b0;endcase
            "l": case(row)3'd0:narrow_font_row=4'b1100;3'd1:narrow_font_row=4'b0100;
                               3'd2:narrow_font_row=4'b0100;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b0100;3'd5:narrow_font_row=4'b0100;
                               3'd6:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "o": case(row)3'd1:narrow_font_row=4'b1110;3'd2:narrow_font_row=4'b1010;
                               3'd3:narrow_font_row=4'b1010;3'd4:narrow_font_row=4'b1010;
                               3'd5:narrow_font_row=4'b1010;3'd6:narrow_font_row=4'b1110;
                               default:narrow_font_row=4'b0;endcase
            "g": case(row)3'd1:narrow_font_row=4'b0110;3'd2:narrow_font_row=4'b1010;
                               3'd3:narrow_font_row=4'b1010;3'd4:narrow_font_row=4'b1110;
                               3'd5:narrow_font_row=4'b0010;3'd6:narrow_font_row=4'b1110;
                               default:narrow_font_row=4'b0;endcase
            "Q": case(row)3'd0:narrow_font_row=4'b1110;3'd1:narrow_font_row=4'b1010;
                               3'd2:narrow_font_row=4'b1010;3'd3:narrow_font_row=4'b1010;
                               3'd4:narrow_font_row=4'b1010;default:narrow_font_row=4'b0;endcase
            "L": case(row)3'd0:narrow_font_row=4'b1000;3'd1:narrow_font_row=4'b1000;
                               3'd2:narrow_font_row=4'b1000;3'd3:narrow_font_row=4'b1000;
                               3'd4:narrow_font_row=4'b1110;default:narrow_font_row=4'b0;endcase
            "(": case(row)3'd0:narrow_font_row=4'b0010;3'd1:narrow_font_row=4'b0100;
                               3'd2:narrow_font_row=4'b0100;3'd3:narrow_font_row=4'b0100;
                               3'd4:narrow_font_row=4'b0100;3'd5:narrow_font_row=4'b0010;
                               default:narrow_font_row=4'b0;endcase
            ")": case(row)3'd0:narrow_font_row=4'b0100;3'd1:narrow_font_row=4'b0010;
                               3'd2:narrow_font_row=4'b0010;3'd3:narrow_font_row=4'b0010;
                               3'd4:narrow_font_row=4'b0010;3'd5:narrow_font_row=4'b0100;
                               default:narrow_font_row=4'b0;endcase
            default: narrow_font_row=4'b0;
        endcase
    endfunction

    // Standard character draw (7 pixels wide)
    function draw_char_pixel;
        input [7:0] ch;
        input [6:0] px;
        input [5:0] py;
        input [6:0] base_x;
        input [5:0] base_y;
        reg [6:0] bits;
        reg [2:0] row, col;
    begin
        draw_char_pixel = 0;
        if (px >= base_x && px < base_x + 7 && py >= base_y && py < base_y + 7) begin
            row = py - base_y;
            col = px - base_x;
            bits = font_row(ch, row);
            draw_char_pixel = bits[6 - col];
        end
    end
    endfunction

    // Narrow character draw (4 pixels wide)
    function draw_narrow_char;
        input [7:0] ch;
        input [6:0] px;
        input [5:0] py;
        input [6:0] base_x;
        input [5:0] base_y;
        reg [3:0] bits;
        reg [2:0] row, col;
    begin
        draw_narrow_char = 0;
        if (px >= base_x && px < base_x + 4 && py >= base_y && py < base_y + 7) begin
            row = py - base_y;
            col = px - base_x;
            bits = narrow_font_row(ch, row);
            draw_narrow_char = bits[3 - col];
        end
    end
    endfunction

    // Row arrays
    wire [7:0] chars_a[0:5], chars_b[0:5], chars_c[0:5];
    assign chars_a[0]="A"; assign chars_a[1]=sign_a?"-":"+"; assign chars_a[2]="0"+digit_a_3; assign chars_a[3]="0"+digit_a_2; assign chars_a[4]="0"+digit_a_1; assign chars_a[5]="0"+digit_a_0;
    assign chars_b[0]="B"; assign chars_b[1]=sign_b?"-":"+"; assign chars_b[2]="0"+digit_b_3; assign chars_b[3]="0"+digit_b_2; assign chars_b[4]="0"+digit_b_1; assign chars_b[5]="0"+digit_b_0;
    assign chars_c[0]="C"; assign chars_c[1]=sign_c?"-":"+"; assign chars_c[2]="0"+digit_c_3; assign chars_c[3]="0"+digit_c_2; assign chars_c[4]="0"+digit_c_1; assign chars_c[5]="0"+digit_c_0;

    // Main pixel generator
    reg [15:0] color;
    integer i;
    always @(posedge clk) begin
        color = BLACK;

        // Compact equation at top using narrow font (4 pixels wide + 1 pixel spacing)
        // Show all 4 digits for each coefficient: y = +/- XXXXx^2 +/- XXXXx +/- XXXX
        if (y >= 1 && y < 9) begin
            if (draw_narrow_char("y",x,y,1,1)) color = WHITE;
            else if (draw_narrow_char("=",x,y,6,1)) color = WHITE;
            else if (draw_narrow_char(sign_a?"-":"+",x,y,11,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_a_3,x,y,16,1)) color = WHITE;  // A: 4 digits
            else if (draw_narrow_char("0"+digit_a_2,x,y,21,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_a_1,x,y,26,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_a_0,x,y,31,1)) color = WHITE;
            else if (draw_narrow_char("x",x,y,36,1)) color = WHITE;
            else if (draw_narrow_char("2",x,y,40,0)) color = WHITE;  // Superscript
            else if (draw_narrow_char(sign_b?"-":"+",x,y,45,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_b_3,x,y,50,1)) color = WHITE;  // B: 4 digits
            else if (draw_narrow_char("0"+digit_b_2,x,y,55,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_b_1,x,y,60,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_b_0,x,y,65,1)) color = WHITE;
            else if (draw_narrow_char("x",x,y,70,1)) color = WHITE;
            else if (draw_narrow_char(sign_c?"-":"+",x,y,75,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_c_3,x,y,80,1)) color = WHITE;  // C: 4 digits
            else if (draw_narrow_char("0"+digit_c_2,x,y,85,1)) color = WHITE;
            else if (draw_narrow_char("0"+digit_c_1,x,y,90,1)) color = WHITE;
            // Note: digit_c_0 would be at x=95, which is at the edge - may need adjustment
        end

        // Coefficient rows - all show 6 characters (Letter, Sign, 4 digits)
        if (y >= 15 && y < 30) begin
            for (i=0;i<6;i=i+1)
                if (draw_char_pixel(chars_a[i],x,y,5+i*8,16))
                    color = (active_coeff==2'b00)?WHITE:CYAN;
        end
        else if (y>=32 && y<47) begin
            for (i=0;i<6;i=i+1)
                if (draw_char_pixel(chars_b[i],x,y,5+i*8,33))
                    color = (active_coeff==2'b01)?WHITE:CYAN;
        end
        else if (y>=49 && y<64) begin
            for (i=0;i<6;i=i+1)
                if (draw_char_pixel(chars_c[i],x,y,5+i*8,50))
                    color = (active_coeff==2'b10)?WHITE:CYAN;
        end

        // Cursor blink - spans all 4 digits
        // cursor_pos: 0=rightmost digit (ones), 1=tens, 2=hundreds, 3=thousands (leftmost)
        // Array positions: [0]=Letter, [1]=Sign, [2]=digit_3, [3]=digit_2, [4]=digit_1, [5]=digit_0
        // We want cursor on positions [2], [3], [4], [5] which are at x = 21, 29, 37, 45
        if (blink) begin
            if (active_coeff==2'b00 && y>=15 && y<30) begin
                if (cursor_pos==0 && x>=45 && x<52) color = YELLOW;      // digit_0 (ones)
                else if (cursor_pos==1 && x>=37 && x<44) color = YELLOW;  // digit_1 (tens)
                else if (cursor_pos==2 && x>=29 && x<36) color = YELLOW;  // digit_2 (hundreds)
                else if (cursor_pos==3 && x>=21 && x<28) color = YELLOW;  // digit_3 (thousands)
            end
            else if (active_coeff==2'b01 && y>=32 && y<47) begin
                if (cursor_pos==0 && x>=45 && x<52) color = YELLOW;      // digit_0 (ones)
                else if (cursor_pos==1 && x>=37 && x<44) color = YELLOW;  // digit_1 (tens)
                else if (cursor_pos==2 && x>=29 && x<36) color = YELLOW;  // digit_2 (hundreds)
                else if (cursor_pos==3 && x>=21 && x<28) color = YELLOW;  // digit_3 (thousands)
            end
            else if (active_coeff==2'b10 && y>=49 && y<64) begin
                if (cursor_pos==0 && x>=45 && x<52) color = YELLOW;      // digit_0 (ones)
                else if (cursor_pos==1 && x>=37 && x<44) color = YELLOW;  // digit_1 (tens)
                else if (cursor_pos==2 && x>=29 && x<36) color = YELLOW;  // digit_2 (hundreds)
                else if (cursor_pos==3 && x>=21 && x<28) color = YELLOW;  // digit_3 (thousands)
            end
        end

        pixel_data <= color;
    end
endmodule
