`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 13:11:35
// Design Name: 
// Module Name: sign_toggle
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


module sign_toggle(
    input wire CLOCK,
    input wire RST,
    input wire sw_sign,
    input wire [1:0] active_coeff,
    
    output reg sign_a,
    output reg sign_b,
    output reg sign_c
    );
    
    reg sw_sign_prev;
    reg sign_toggle_pulse;
    
    always @ (posedge CLOCK or posedge RST) begin
        if (RST) begin
            sign_a <= 0;
            sign_b <= 0;
            sign_c <= 0;
            sw_sign_prev <= 0;
            sign_toggle_pulse <= 0;
        end else begin
            sw_sign_prev <= sw_sign;
            
            if (sw_sign && !sw_sign_prev) begin
                sign_toggle_pulse <= 1;
            end else begin
                sign_toggle_pulse <= 0;
            end
            
            if (sign_toggle_pulse) begin
                case (active_coeff)
                    2'b00: sign_a <= ~sign_a;
                    2'b01: sign_b <= ~sign_b;
                    2'b10: sign_c <= ~sign_c;
                endcase
            end
        end
    end
    
endmodule
