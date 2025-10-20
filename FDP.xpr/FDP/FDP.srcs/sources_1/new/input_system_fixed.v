`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: input_system
// Description: Integrates all input-related modules
//////////////////////////////////////////////////////////////////////////////////

module input_system(
    input wire CLOCK,
    input wire RST,
    input wire [15:13] sw,
    input wire BTNC,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU,
    input wire BTND,
    
    output wire [1:0] active_coeff_top,
    output wire [1:0] cursor_pos_top,
    output wire [3:0] digit_a_0_top,
    output wire [3:0] digit_a_1_top,
    output wire [3:0] digit_a_2_top,
    output wire [3:0] digit_a_3_top,
    output wire [3:0] digit_b_0_top,
    output wire [3:0] digit_b_1_top,
    output wire [3:0] digit_b_2_top,
    output wire [3:0] digit_b_3_top,
    output wire [3:0] digit_c_0_top,
    output wire [3:0] digit_c_1_top,
    output wire [3:0] digit_c_2_top,
    output wire [3:0] digit_c_3_top,
    output wire sign_a_top,
    output wire sign_b_top,
    output wire sign_c_top,
    output wire input_valid_top,
    output wire [7:0] error_code_top,
    output wire signed [15:0] coeff_a_top,
    output wire signed [15:0] coeff_b_top,
    output wire signed [15:0] coeff_c_top,
    output wire [1:0] function_type_top,
    output wire input_done_top,
    output wire clk_1kHz_top,
    output wire clk_10Hz_top,
    output wire clk_100Hz_top
);

    // Button debouncers
    wire btnc_db, btnl_db, btnr_db, btnu_db, btnd_db;
    
    debouncer db_c(.clk(CLOCK), .rst(RST), .btn_in(BTNC), .btn_out(btnc_db));
    debouncer db_l(.clk(CLOCK), .rst(RST), .btn_in(BTNL), .btn_out(btnl_db));
    debouncer db_r(.clk(CLOCK), .rst(RST), .btn_in(BTNR), .btn_out(btnr_db));
    debouncer db_u(.clk(CLOCK), .rst(RST), .btn_in(BTNU), .btn_out(btnu_db));
    debouncer db_d(.clk(CLOCK), .rst(RST), .btn_in(BTND), .btn_out(btnd_db));
    
    // Clock divider
    clock_divider clk_div(
        .CLOCK(CLOCK),
        .RST(RST),
        .clk_1kHz(clk_1kHz_top),
        .clk_10Hz(clk_10Hz_top),
        .clk_100Hz(clk_100Hz_top)
    );
    
    // Function selector
    function_selector func_sel(
        .CLOCK(CLOCK),
        .RST(RST),
        .sw_mode(sw[15:14]),
        .function_type(function_type_top)
    );
    
    // Coefficient input with integrated sign toggle
    coefficient_input coeff_in(
        .CLOCK(CLOCK),
        .RST(RST),
        .BTNC(btnc_db),
        .BTNL(btnl_db),
        .BTNR(btnr_db),
        .BTNU(btnu_db),
        .BTND(btnd_db),
        .function_type(function_type_top),
        .sw_sign(sw[13]),           // Sign toggle switch
        .coeff_a(coeff_a_top),
        .coeff_b(coeff_b_top),
        .coeff_c(coeff_c_top),
        .active_coeff(active_coeff_top),
        .cursor_pos(cursor_pos_top),
        .digit_a_0(digit_a_0_top),
        .digit_a_1(digit_a_1_top),
        .digit_a_2(digit_a_2_top),
        .digit_a_3(digit_a_3_top),
        .digit_b_0(digit_b_0_top),
        .digit_b_1(digit_b_1_top),
        .digit_b_2(digit_b_2_top),
        .digit_b_3(digit_b_3_top),
        .digit_c_0(digit_c_0_top),
        .digit_c_1(digit_c_1_top),
        .digit_c_2(digit_c_2_top),
        .digit_c_3(digit_c_3_top),
        .sign_a(sign_a_top),
        .sign_b(sign_b_top),
        .sign_c(sign_c_top),
        .input_done(input_done_top)
    );
    
    // Input validator
    input_validator validator(
        .function_type(function_type_top),
        .coeff_a(coeff_a_top),
        .coeff_b(coeff_b_top),
        .coeff_c(coeff_c_top),
        .input_valid(input_valid_top),
        .error_code(error_code_top)
    );

endmodule


// Simple debouncer module
module debouncer(
    input wire clk,
    input wire rst,
    input wire btn_in,
    output reg btn_out
);
    reg [19:0] counter;
    reg btn_sync_0, btn_sync_1;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync_0 <= 0;
            btn_sync_1 <= 0;
            counter <= 0;
            btn_out <= 0;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
            
            if (btn_sync_1) begin
                if (counter < 20'd1000000)
                    counter <= counter + 1;
                else
                    btn_out <= 1;
            end else begin
                counter <= 0;
                btn_out <= 0;
            end
        end
    end
endmodule
