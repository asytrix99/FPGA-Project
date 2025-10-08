`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2025 22:07:37
// Design Name: 
// Module Name: horizontal_movement
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


module horizontal_movement(
    input clk,
    input STOP, 
    output reg [6:0] x_offset
    );
    
    // move left in 3 sec -> 38ms per offset
    
    reg STATE = 0; //0 to move right, 1 to move left
    reg [17:0] COUNT = 18'b0; 
    
    initial begin
        x_offset = 0;
    end
    
    always @ (posedge clk) begin
        if (STOP) begin 
            // Do nothing
        end 
        
        else if (!STATE) begin
            if (COUNT == 18'd237499) begin
                COUNT <= 0;
                if (x_offset == 78) begin
                    x_offset <= x_offset + 1;
                    STATE <= ~STATE;
                end else begin
                    x_offset <= x_offset + 1;
                end
            end else begin
                COUNT <= COUNT + 1;
            end
            
        end else begin
            if (COUNT == 18'd237499) begin
                COUNT <= 0;
                
                if (x_offset == 1) begin
                    x_offset <= x_offset - 1;
                    STATE <= ~STATE;
                end else begin
                    x_offset <= x_offset - 1;
                end
                
            end else begin
                COUNT <= COUNT + 1;
            end
        end
    end
    
    
endmodule
