`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.10.2025 11:09:44
// Design Name: 
// Module Name: button_debouncer
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


module button_debouncer(
    input wire clk_1kHz,
    input wire RST,
    input wire button_in,
    output reg button_pressed
    );
    
    reg [4:0] count;
    reg button_sync;
    reg button_state;
    reg button_prev;
    
    always @ (posedge clk_1kHz or posedge RST) begin
        if (RST) begin
            count <= 0;
            button_sync <= 1;
            button_state <= 1;
            button_prev <= 1;
            button_pressed <= 0;
        end else begin
            if (button_in != button_sync) begin
                button_sync <= button_in;
                count <= 0;
            end else if (count < 20) begin
                count <= count + 1;
            end else begin
                button_state <= button_sync;
            end
            
            button_pressed <= (button_prev == 1 && button_state == 0);
            button_prev <= button_state;
        end
    end
   
endmodule
