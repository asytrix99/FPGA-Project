`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student(
    input wire CLK100MHZ,
    
    // Switches
    input wire [15:13] sw,
    
    // Buttons
    input wire BTNC,
    input wire BTNL,
    input wire BTNR,
    input wire BTNU,
    input wire BTND,
    
    // LEDs for debugging
    output wire [15:0] led,
    
    // OLED SPI interface
    output wire [7:0] JB,
    
    output wire [3:0] an,
    output wire [6:0] seg
);

    // Reset logic - no reset, system always running
    wire RST = 1'b0;
    
    // Internal wires from input_top
    wire [1:0] active_coeff;
    wire [1:0] cursor_pos;
    wire [3:0] digit_a_0, digit_a_1, digit_a_2, digit_a_3;
    wire [3:0] digit_b_0, digit_b_1, digit_b_2, digit_b_3;
    wire [3:0] digit_c_0, digit_c_1, digit_c_2, digit_c_3;
    wire sign_a, sign_b, sign_c;
    wire input_valid;
    wire [7:0] error_code;
    wire signed [15:0] coeff_a, coeff_b, coeff_c;
    wire [1:0] function_type;
    wire input_done;
    wire clk_1kHz, clk_10Hz, clk_100Hz;
    
    // OLED signals
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    wire [15:0] pixel_data;
    
    // Clock for OLED (6.25MHz from 100MHz)
    reg [3:0] oled_clk_div;
    wire clk_6_25MHz;
    
    always @(posedge CLK100MHZ or posedge RST) begin
        if (RST)
            oled_clk_div <= 0;
        else
            oled_clk_div <= oled_clk_div + 1;
    end
    assign clk_6_25MHz = oled_clk_div[3];  // Divide by 16
    
    // Your input system - now properly connected
    input_system input_sys(
        .CLOCK(CLK100MHZ),
        .RST(RST),
        .sw(sw),
        .BTNC(BTNC),
        .BTNL(BTNL),
        .BTNR(BTNR),
        .BTNU(BTNU),
        .BTND(BTND),
        .active_coeff_top(active_coeff),
        .cursor_pos_top(cursor_pos),
        .digit_a_0_top(digit_a_0),
        .digit_a_1_top(digit_a_1),
        .digit_a_2_top(digit_a_2),
        .digit_a_3_top(digit_a_3),
        .digit_b_0_top(digit_b_0),
        .digit_b_1_top(digit_b_1),
        .digit_b_2_top(digit_b_2),
        .digit_b_3_top(digit_b_3),
        .digit_c_0_top(digit_c_0),
        .digit_c_1_top(digit_c_1),
        .digit_c_2_top(digit_c_2),
        .digit_c_3_top(digit_c_3),
        .sign_a_top(sign_a),
        .sign_b_top(sign_b),
        .sign_c_top(sign_c),
        .input_valid_top(input_valid),
        .error_code_top(error_code),
        .coeff_a_top(coeff_a),
        .coeff_b_top(coeff_b),
        .coeff_c_top(coeff_c),
        .function_type_top(function_type),
        .input_done_top(input_done),
        .clk_1kHz_top(clk_1kHz),
        .clk_10Hz_top(clk_10Hz),
        .clk_100Hz_top(clk_100Hz)
    );
    
    // Enhanced OLED display with sign indicator
    simple_oled_display oled_gen(
        .clk(clk_6_25MHz),
        .reset(RST),
        .pixel_index(pixel_index),
        .active_coeff(active_coeff),
        .cursor_pos(cursor_pos),
        .digit_a_0(digit_a_0),
        .digit_a_1(digit_a_1),
        .digit_a_2(digit_a_2),
        .digit_a_3(digit_a_3),
        .digit_b_0(digit_b_0),
        .digit_b_1(digit_b_1),
        .digit_b_2(digit_b_2),
        .digit_b_3(digit_b_3),
        .digit_c_0(digit_c_0),
        .digit_c_1(digit_c_1),
        .digit_c_2(digit_c_2),
        .digit_c_3(digit_c_3),
        .sign_a(sign_a),
        .sign_b(sign_b),
        .sign_c(sign_c),
        .function_type(function_type),
        .input_done(input_done),
        .sw_sign(sw[13]),
        .clk_10Hz(clk_10Hz),
        .pixel_data(pixel_data)
    );
    
    // OLED controller
    Oled_Display #(
        .ClkFreq(6250000)
    ) oled_ctrl (
        .clk(clk_6_25MHz),
        .reset(RST),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(pixel_data),
        .cs(JB[0]),
        .sdin(JB[1]),
        .sclk(JB[3]),
        .d_cn(JB[4]),
        .resn(JB[5]),
        .vccen(JB[6]),
        .pmoden(JB[7])
    );
    
    // 7-segment display shows current coefficient being edited
    wire [3:0] show0, show1, show2, show3;
    assign {show3, show2, show1, show0} =
       (active_coeff == 2'b00) ? {digit_a_3, digit_a_2, digit_a_1, digit_a_0} :
       (active_coeff == 2'b01) ? {digit_b_3, digit_b_2, digit_b_1, digit_b_0} :
                                 {digit_c_3, digit_c_2, digit_c_1, digit_c_0};

    seg_display seg_driver(
       .clk_1kHz(clk_1kHz),
       .d0(show0), .d1(show1), .d2(show2), .d3(show3),
       .an(an),
       .seg(seg)
    );
    
    // LED indicators for debugging
    assign led[15:14] = function_type;      // Function type on top LEDs
    assign led[13] = sw[13];                // SW13 state (sign toggle switch)
    assign led[12] = input_done;            // Input done indicator
    assign led[11:10] = active_coeff;       // Which coefficient is active
    assign led[9] = sign_a;                 // Sign of A
    assign led[8] = sign_b;                 // Sign of B  
    assign led[7] = sign_c;                 // Sign of C
    assign led[6] = input_valid;            // Input validation status
    assign led[5:0] = 6'b0;
   
endmodule
