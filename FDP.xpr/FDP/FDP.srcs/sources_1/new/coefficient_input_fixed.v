`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: coefficient_input
// Description: Handles coefficient input with integrated sign toggling
//////////////////////////////////////////////////////////////////////////////////

module coefficient_input(
    input CLOCK,
    input RST,
    
    input wire BTNC,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU,
    input wire BTND,
    
    input wire [1:0] function_type,
    input wire sw_sign,          // Sign toggle switch
    
    output reg signed [15:0] coeff_a,
    output reg signed [15:0] coeff_b,
    output reg signed [15:0] coeff_c,
    output reg [1:0] active_coeff,
    output reg [1:0] cursor_pos,
    
    output wire [3:0] digit_a_0,
    output wire [3:0] digit_a_1,
    output wire [3:0] digit_a_2,
    output wire [3:0] digit_a_3,
    output wire [3:0] digit_b_0,
    output wire [3:0] digit_b_1,
    output wire [3:0] digit_b_2,
    output wire [3:0] digit_b_3,
    output wire [3:0] digit_c_0,
    output wire [3:0] digit_c_1,
    output wire [3:0] digit_c_2,
    output wire [3:0] digit_c_3,
    
    output reg sign_a,
    output reg sign_b,
    output reg sign_c,
    output reg input_done
    );
    
    localparam state_a = 2'b00;
    localparam state_b = 2'b01;
    localparam state_c = 2'b10;
    
    reg [3:0] a_digits [0:3];
    reg [3:0] b_digits [0:3];
    reg [3:0] c_digits [0:3];
    
    assign digit_a_0 = a_digits[0];
    assign digit_a_1 = a_digits[1];
    assign digit_a_2 = a_digits[2];
    assign digit_a_3 = a_digits[3];
    assign digit_b_0 = b_digits[0];
    assign digit_b_1 = b_digits[1];
    assign digit_b_2 = b_digits[2];
    assign digit_b_3 = b_digits[3];
    assign digit_c_0 = c_digits[0];
    assign digit_c_1 = c_digits[1];
    assign digit_c_2 = c_digits[2];
    assign digit_c_3 = c_digits[3];
    
    function [15:0] bcd_to_bin;
        input [3:0] d0, d1, d2, d3;
        begin
            bcd_to_bin = d0 + (d1 * 10) + (d2 * 100) + (d3 * 1000);
        end
    endfunction
    
    // Sign toggle logic
    reg sw_sign_prev;
    reg sign_toggle_pulse;
    
    integer i;
    
    always @ (posedge CLOCK or posedge RST) begin
        if (RST) begin
            for (i = 0; i < 4; i = i + 1) begin
                a_digits[i] <= 0;
                b_digits[i] <= 0;
                c_digits[i] <= 0;
            end
            
            a_digits[0] <= 1;
            
            sign_a <= 0;
            sign_b <= 0;
            sign_c <= 0;
            
            active_coeff <= state_a;
            cursor_pos <= 2'b00;
            input_done <= 0;
            
            coeff_a <= 16'sd1;
            coeff_b <= 16'sd0;
            coeff_c <= 16'sd0;
            
            sw_sign_prev <= 0;
            sign_toggle_pulse <= 0;
        end else begin
            // Handle sign toggle switch
            sw_sign_prev <= sw_sign;
            
            if (sw_sign && !sw_sign_prev) begin
                sign_toggle_pulse <= 1;
            end else begin
                sign_toggle_pulse <= 0;
            end
            
            if (sign_toggle_pulse) begin
                case (active_coeff)
                    state_a: sign_a <= ~sign_a;
                    state_b: sign_b <= ~sign_b;
                    state_c: sign_c <= ~sign_c;
                endcase
            end
            
            // Handle cursor movement
            if (BTNL) begin
                if (cursor_pos < 3)
                    cursor_pos <= cursor_pos + 1;
            end
            
            if (BTNR) begin
                if (cursor_pos > 0)
                    cursor_pos <= cursor_pos - 1;
            end
            
            // Handle digit increment
            if (BTNU) begin
                case (active_coeff)
                    state_a: begin
                        if (a_digits[cursor_pos] < 9) 
                            a_digits[cursor_pos] <= a_digits[cursor_pos] + 1;
                        else
                            a_digits[cursor_pos] <= 0;
                    end
                    state_b: begin
                        if (b_digits[cursor_pos] < 9) 
                            b_digits[cursor_pos] <= b_digits[cursor_pos] + 1;
                        else
                            b_digits[cursor_pos] <= 0;
                    end
                    state_c: begin
                        if (c_digits[cursor_pos] < 9) 
                            c_digits[cursor_pos] <= c_digits[cursor_pos] + 1;
                        else
                            c_digits[cursor_pos] <= 0;
                    end
                endcase
            end
            
            // Handle digit decrement
            if (BTND) begin
                case (active_coeff)
                    state_a: begin
                        if (a_digits[cursor_pos] > 0) 
                            a_digits[cursor_pos] <= a_digits[cursor_pos] - 1;
                        else
                            a_digits[cursor_pos] <= 9;
                    end
                    state_b: begin
                        if (b_digits[cursor_pos] > 0) 
                            b_digits[cursor_pos] <= b_digits[cursor_pos] - 1;
                        else
                            b_digits[cursor_pos] <= 9;
                    end
                    state_c: begin
                        if (c_digits[cursor_pos] > 0) 
                            c_digits[cursor_pos] <= c_digits[cursor_pos] - 1;
                        else
                            c_digits[cursor_pos] <= 9;
                    end
                endcase
            end
            
            // Handle coefficient advance (BTNC)
            if (BTNC) begin
                case (active_coeff)
                    state_a: begin
                        active_coeff <= state_b;
                        cursor_pos <= 2'b00;
                    end
                    state_b: begin
                        active_coeff <= state_c;
                        cursor_pos <= 2'b00;
                    end
                    state_c: begin
                        active_coeff <= state_a;
                        cursor_pos <= 2'b00;
                        input_done <= 1;  // Mark as done when cycling back to A
                    end        
                endcase
            end
            
            // Update coefficient values
            coeff_a <= sign_a ? -$signed(bcd_to_bin(a_digits[0], a_digits[1], a_digits[2], a_digits[3]))
                              : $signed(bcd_to_bin(a_digits[0], a_digits[1], a_digits[2], a_digits[3]));
            coeff_b <= sign_b ? -$signed(bcd_to_bin(b_digits[0], b_digits[1], b_digits[2], b_digits[3]))
                              : $signed(bcd_to_bin(b_digits[0], b_digits[1], b_digits[2], b_digits[3]));
            coeff_c <= sign_c ? -$signed(bcd_to_bin(c_digits[0], c_digits[1], c_digits[2], c_digits[3]))
                              : $signed(bcd_to_bin(c_digits[0], c_digits[1], c_digits[2], c_digits[3]));
        end
    end
        
endmodule
