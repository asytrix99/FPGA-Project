`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: simple_oled_display
// Description: Enhanced OLED display with prominent sign indicators
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
    input  wire input_done,
    input  wire sw_sign,
    input  wire clk_10Hz,

    output reg  [15:0] pixel_data
);

    localparam WIDTH  = 96;
    localparam HEIGHT = 64;
    localparam BLACK  = 16'h0000;
    localparam WHITE  = 16'hFFFF;
    localparam CYAN   = 16'h07FF;
    localparam YELLOW = 16'hFFE0;
    localparam GREEN  = 16'h07E0;
    localparam RED    = 16'hF800;
    localparam MAGENTA = 16'hF81F;

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
            "S": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000000;
                               3'd2:font_row=7'b0111110;3'd3:font_row=7'b0000001;
                               3'd4:font_row=7'b0111110;default:font_row=7'b0;endcase
            "T": case(row)3'd0:font_row=7'b1111111;3'd1:font_row=7'b0001000;
                               3'd2:font_row=7'b0001000;3'd3:font_row=7'b0001000;
                               3'd4:font_row=7'b0001000;default:font_row=7'b0;endcase
            "O": case(row)3'd0:font_row=7'b0111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1000001;3'd3:font_row=7'b1000001;
                               3'd4:font_row=7'b0111110;default:font_row=7'b0;endcase
            "R": case(row)3'd0:font_row=7'b1111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1111110;3'd3:font_row=7'b1000100;
                               3'd4:font_row=7'b1000010;default:font_row=7'b0;endcase
            "E": case(row)3'd0:font_row=7'b1111111;3'd1:font_row=7'b1000000;
                               3'd2:font_row=7'b1111110;3'd3:font_row=7'b1000000;
                               3'd4:font_row=7'b1111111;default:font_row=7'b0;endcase
            "D": case(row)3'd0:font_row=7'b1111110;3'd1:font_row=7'b1000001;
                               3'd2:font_row=7'b1000001;3'd3:font_row=7'b1000010;
                               3'd4:font_row=7'b1111100;default:font_row=7'b0;endcase
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

        // Compact equation at top - changes based on function_type
        if (y >= 1 && y < 9) begin
            // Always show y =
            if (draw_narrow_char("y",x,y,1,1)) color = WHITE;
            else if (draw_narrow_char("=",x,y,6,1)) color = WHITE;
            
            // Show equation based on function type
            else if (function_type == 2'b00) begin
                // Quadratic: y = ax^2 + bx + c
                if (draw_narrow_char("a",x,y,11,1)) color = WHITE;
                else if (draw_narrow_char("x",x,y,16,1)) color = WHITE;
                else if (draw_narrow_char("2",x,y,20,0)) color = WHITE;
                else if (draw_narrow_char("+",x,y,25,1)) color = WHITE;
                else if (draw_narrow_char("b",x,y,30,1)) color = WHITE;
                else if (draw_narrow_char("x",x,y,35,1)) color = WHITE;
                else if (draw_narrow_char("+",x,y,40,1)) color = WHITE;
                else if (draw_narrow_char("c",x,y,45,1)) color = WHITE;
            end
            else if (function_type == 2'b01) begin
                // Linear: y = bx + c
                if (draw_narrow_char("b",x,y,11,1)) color = WHITE;
                else if (draw_narrow_char("x",x,y,16,1)) color = WHITE;
                else if (draw_narrow_char("+",x,y,21,1)) color = WHITE;
                else if (draw_narrow_char("c",x,y,26,1)) color = WHITE;
            end
            else if (function_type == 2'b10) begin
                // Constant: y = c
                if (draw_narrow_char("c",x,y,11,1)) color = WHITE;
            end
            else begin
                // Logarithmic: y = a*log_b(x) + c
                if (draw_narrow_char("a",x,y,11,1)) color = WHITE;
                else if (draw_narrow_char("l",x,y,16,1)) color = WHITE;
                else if (draw_narrow_char("o",x,y,21,1)) color = WHITE;
                else if (draw_narrow_char("g",x,y,26,1)) color = WHITE;
                else if (draw_narrow_char("b",x,y,30,-1)) color = WHITE;  // subscript
                else if (draw_narrow_char("(",x,y,34,1)) color = WHITE;
                else if (draw_narrow_char("x",x,y,38,1)) color = WHITE;
                else if (draw_narrow_char(")",x,y,42,1)) color = WHITE;
                else if (draw_narrow_char("+",x,y,47,1)) color = WHITE;
                else if (draw_narrow_char("c",x,y,52,1)) color = WHITE;
            end
            
            // Function type indicator (top right corner)
            if (function_type == 2'b00) begin
                if (draw_narrow_char("Q",x,y,88,1)) color = CYAN;  // Quadratic
            end
            else if (function_type == 2'b01) begin
                if (draw_narrow_char("L",x,y,88,1)) color = CYAN;  // Linear
            end
            else if (function_type == 2'b10) begin
                if (draw_narrow_char("c",x,y,88,1)) color = CYAN;  // Constant
            end
            else begin
                if (draw_narrow_char("l",x,y,85,1)) color = CYAN;
                else if (draw_narrow_char("o",x,y,90,1)) color = CYAN;  // log
            end
        end

        // SW13 status indicator at top right (below function type)
        if (y >= 10 && y < 13) begin
            if (x >= 85 && x < 95) begin
                if (sw_sign)
                    color = GREEN;   // SW13 is ON (ready to toggle)
                else
                    color = RED;     // SW13 is OFF
            end
        end

        // "STORED" indicator when input_done (blinking green)
        if (input_done && blink) begin
            if (y >= 10 && y < 15) begin
                if (draw_narrow_char("S",x,y,2,10)) color = GREEN;
                else if (draw_narrow_char("T",x,y,7,10)) color = GREEN;
                else if (draw_narrow_char("O",x,y,12,10)) color = GREEN;
                else if (draw_narrow_char("R",x,y,17,10)) color = GREEN;
                else if (draw_narrow_char("E",x,y,22,10)) color = GREEN;
                else if (draw_narrow_char("D",x,y,27,10)) color = GREEN;
            end
        end

        // Coefficient rows - all show 6 characters (Letter, Sign, 4 digits)
        // ENHANCED: Sign is now colored based on its value
        if (y >= 15 && y < 30) begin
            for (i=0;i<6;i=i+1) begin
                if (draw_char_pixel(chars_a[i],x,y,5+i*8,16)) begin
                    if (i == 1) begin
                        // Sign position - colored prominently
                        color = sign_a ? RED : GREEN;
                    end else begin
                        color = (active_coeff==2'b00)?WHITE:CYAN;
                    end
                end
            end
        end
        else if (y>=32 && y<47) begin
            for (i=0;i<6;i=i+1) begin
                if (draw_char_pixel(chars_b[i],x,y,5+i*8,33)) begin
                    if (i == 1) begin
                        // Sign position - colored prominently
                        color = sign_b ? RED : GREEN;
                    end else begin
                        color = (active_coeff==2'b01)?WHITE:CYAN;
                    end
                end
            end
        end
        else if (y>=49 && y<64) begin
            for (i=0;i<6;i=i+1) begin
                if (draw_char_pixel(chars_c[i],x,y,5+i*8,50)) begin
                    if (i == 1) begin
                        // Sign position - colored prominently
                        color = sign_c ? RED : GREEN;
                    end else begin
                        color = (active_coeff==2'b10)?WHITE:CYAN;
                    end
                end
            end
        end

        // Cursor blink - spans the selected digit
        if (blink) begin
            if (active_coeff==2'b00 && y>=15 && y<30) begin
                if (cursor_pos==0 && x>=45 && x<52) color = YELLOW;      // digit_0 (ones)
                else if (cursor_pos==1 && x>=37 && x<44) color = YELLOW;  // digit_1 (tens)
                else if (cursor_pos==2 && x>=29 && x<36) color = YELLOW;  // digit_2 (hundreds)
                else if (cursor_pos==3 && x>=21 && x<28) color = YELLOW;  // digit_3 (thousands)
            end
            else if (active_coeff==2'b01 && y>=32 && y<47) begin
                if (cursor_pos==0 && x>=45 && x<52) color = YELLOW;
                else if (cursor_pos==1 && x>=37 && x<44) color = YELLOW;
                else if (cursor_pos==2 && x>=29 && x<36) color = YELLOW;
                else if (cursor_pos==3 && x>=21 && x<28) color = YELLOW;
            end
            else if (active_coeff==2'b10 && y>=49 && y<64) begin
                if (cursor_pos==0 && x>=45 && x<52) color = YELLOW;
                else if (cursor_pos==1 && x>=37 && x<44) color = YELLOW;
                else if (cursor_pos==2 && x>=29 && x<36) color = YELLOW;
                else if (cursor_pos==3 && x>=21 && x<28) color = YELLOW;
            end
        end

        pixel_data <= color;
    end
endmodule
