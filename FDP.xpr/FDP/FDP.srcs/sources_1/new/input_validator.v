`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 14:10:00
// Design Name: 
// Module Name: input_validator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Validates coefficient inputs based on function type
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module input_validator(
    input wire [1:0] function_type,
    input wire signed [15:0] coeff_a,
    input wire signed [15:0] coeff_b,
    input wire signed [15:0] coeff_c,
    output reg input_valid,
    output reg [7:0] error_code
    );
    
    // Error codes:
    // 8'h00 = No error
    // 8'h01 = Quadratic: A coefficient cannot be zero
    // 8'h02 = Linear: B coefficient cannot be zero
    // 8'h03 = Logarithmic: A coefficient cannot be zero
    // 8'h04 = Logarithmic: B coefficient must be > 1
    
    always @(*) begin
        input_valid = 1'b1;  // Default to valid
        error_code = 8'h00;  // Default to no error
        
        case (function_type)
            2'b00: begin  // Quadratic: y = ax^2 + bx + c
                if (coeff_a == 0) begin
                    input_valid = 1'b0;
                    error_code = 8'h01;
                end
            end
            
            2'b01: begin  // Linear: y = bx + c
                if (coeff_b == 0) begin
                    input_valid = 1'b0;
                    error_code = 8'h02;
                end
            end
            
            2'b10: begin  // Constant: y = c
                // Always valid for constant function
                input_valid = 1'b1;
                error_code = 8'h00;
            end
            
            2'b11: begin  // Logarithmic: y = a*log_b(x) + c
                if (coeff_a == 0) begin
                    input_valid = 1'b0;
                    error_code = 8'h03;
                end else if (coeff_b <= 1) begin
                    input_valid = 1'b0;
                    error_code = 8'h04;
                end
            end
            
            default: begin
                input_valid = 1'b1;
                error_code = 8'h00;
            end
        endcase
    end
    
endmodule
