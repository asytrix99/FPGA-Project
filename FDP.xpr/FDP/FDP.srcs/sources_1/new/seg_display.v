`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: seg_display
// Description: 7-segment display driver for showing 4 digits
//////////////////////////////////////////////////////////////////////////////////

module seg_display(
    input wire clk_1kHz,
    input wire [3:0] d0,  // rightmost digit
    input wire [3:0] d1,
    input wire [3:0] d2,
    input wire [3:0] d3,  // leftmost digit
    output reg [3:0] an,
    output reg [6:0] seg
);

    reg [1:0] digit_select;
    
    // Digit to 7-segment decoder
    function [6:0] digit_to_seg;
        input [3:0] digit;
        case (digit)
            4'd0: digit_to_seg = 7'b1000000;  // 0
            4'd1: digit_to_seg = 7'b1111001;  // 1
            4'd2: digit_to_seg = 7'b0100100;  // 2
            4'd3: digit_to_seg = 7'b0110000;  // 3
            4'd4: digit_to_seg = 7'b0011001;  // 4
            4'd5: digit_to_seg = 7'b0010010;  // 5
            4'd6: digit_to_seg = 7'b0000010;  // 6
            4'd7: digit_to_seg = 7'b1111000;  // 7
            4'd8: digit_to_seg = 7'b0000000;  // 8
            4'd9: digit_to_seg = 7'b0010000;  // 9
            default: digit_to_seg = 7'b1111111;  // blank
        endcase
    endfunction
    
    always @(posedge clk_1kHz) begin
        digit_select <= digit_select + 1;
        
        case (digit_select)
            2'b00: begin
                an <= 4'b1110;  // Enable rightmost digit
                seg <= digit_to_seg(d0);
            end
            2'b01: begin
                an <= 4'b1101;
                seg <= digit_to_seg(d1);
            end
            2'b10: begin
                an <= 4'b1011;
                seg <= digit_to_seg(d2);
            end
            2'b11: begin
                an <= 4'b0111;  // Enable leftmost digit
                seg <= digit_to_seg(d3);
            end
        endcase
    end
    
endmodule
