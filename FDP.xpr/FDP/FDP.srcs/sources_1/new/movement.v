`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2025 16:08:31
// Design Name: 
// Module Name: movement
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


module movement(input clk40,input [2:0]dir,output reg[6:0]offset_x,output reg[6:0]offset_y);
initial begin
offset_x = 48; 
offset_y = 32;
end
parameter  radius = 10;
parameter  box_offset = 3;
parameter  len_box = 26;
parameter left = box_offset;
parameter right =box_offset + len_box - 1;
parameter top = 64 - len_box - box_offset;
parameter bottom = 64 - box_offset;
//check if overlaps the hollow square

function in_box_condition; 
input [6:0]new_x;
input [6:0]new_y;
integer x1,y1,x_pixel,y_pixel; //x1x2 are horizontal/vertical offset from circle center
//x,y pixel are absolute coordinate of pixel we are checking
reg overlap;
begin
overlap = 0; //0 if false
//check for overlap of EVERY pixel of circle
for (x1 = -radius;x1<=radius;x1=x1+1) begin //all horizontal positions from circle center
    for (y1 = -radius; y1<=radius; y1=y1+1) begin //all vertical positions from circle center
        if((x1*x1 + y1*y1) <=radius*radius) begin //check if the pixel is part of the circle
            x_pixel = new_x + x1;
            y_pixel = new_y + y1; //compute x,y pixel coordinates
            if ((x_pixel>=left)&&(x_pixel<=right)&&(y_pixel>=top)&&(y_pixel<=bottom)) begin
                overlap = 1;
                end
            end
        end
    end
in_box_condition = overlap;
end
endfunction

always @(posedge clk40) begin
case(dir) 
3'b000:begin //program init: circle begins at center of scren
    offset_x = 48; 
    offset_y = 32;
end
3'b001:begin //move up
    if (offset_y>radius+2 && !in_box_condition(offset_x,offset_y-1))
    offset_y <= offset_y - 1;
end
3'b010:begin //move down
    if ((offset_y < 64 - radius - 2) && !in_box_condition(offset_x,offset_y+1))
    offset_y <= offset_y + 1;
end
3'b011:begin //move left
    if ((offset_x>radius + 3) && !in_box_condition(offset_x-1,offset_y))
    offset_x <= offset_x - 1;
end
3'b100:begin //move right
    if ((offset_x<96-radius-2) && !in_box_condition(offset_x+1,offset_y))
    offset_x <= offset_x + 1;
end
endcase
end

endmodule
