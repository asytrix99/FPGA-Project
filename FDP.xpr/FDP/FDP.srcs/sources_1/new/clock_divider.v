`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 14:00:00
// Design Name: 
// Module Name: clock_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Clock divider to generate 1kHz, 10Hz, and 100Hz clocks from 100MHz
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider(
    input wire CLOCK,      // 100MHz input clock
    input wire RST,
    output reg clk_1kHz,   // 1kHz clock output
    output reg clk_10Hz,   // 10Hz clock output
    output reg clk_100Hz   // 100Hz clock output
    );
    
    // Counter for 1kHz (divide by 100,000): 100MHz / 100,000 = 1kHz
    reg [16:0] counter_1kHz = 0;
    localparam COUNT_1KHZ = 50000 - 1;  // Toggle every 50,000 cycles for 1kHz
    
    // Counter for 100Hz (divide by 1,000,000): 100MHz / 1,000,000 = 100Hz
    reg [19:0] counter_100Hz = 0;
    localparam COUNT_100HZ = 500000 - 1;  // Toggle every 500,000 cycles for 100Hz
    
    // Counter for 10Hz (divide by 10,000,000): 100MHz / 10,000,000 = 10Hz
    reg [23:0] counter_10Hz = 0;
    localparam COUNT_10HZ = 5000000 - 1;  // Toggle every 5,000,000 cycles for 10Hz
    
    always @(posedge CLOCK or posedge RST) begin
        if (RST) begin
            counter_1kHz <= 0;
            counter_100Hz <= 0;
            counter_10Hz <= 0;
            clk_1kHz <= 0;
            clk_100Hz <= 0;
            clk_10Hz <= 0;
        end else begin
            // 1kHz clock generation
            if (counter_1kHz >= COUNT_1KHZ) begin
                counter_1kHz <= 0;
                clk_1kHz <= ~clk_1kHz;
            end else begin
                counter_1kHz <= counter_1kHz + 1;
            end
            
            // 100Hz clock generation
            if (counter_100Hz >= COUNT_100HZ) begin
                counter_100Hz <= 0;
                clk_100Hz <= ~clk_100Hz;
            end else begin
                counter_100Hz <= counter_100Hz + 1;
            end
            
            // 10Hz clock generation
            if (counter_10Hz >= COUNT_10HZ) begin
                counter_10Hz <= 0;
                clk_10Hz <= ~clk_10Hz;
            end else begin
                counter_10Hz <= counter_10Hz + 1;
            end
        end
    end
    
endmodule
