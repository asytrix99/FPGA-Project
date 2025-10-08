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


module Top_Student (
    input [15:0] sw,
    input clk,
    input btnC,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    output [7:0] seg,
    output [3:0] an,
    output [7:0] JB
);

    wire [15:0] JB_S, JB_R, JB_Q, JB_P;

    wire led_clk;
    clk6p25m u1 (clk, led_clk);
    
    // Define LED data
    wire [15:0] oled_data;
    
    // Define oled output
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
   
   seven_seg(clk, an, seg);
   
    basic_task_S S (clk, led_clk, btnU, btnD, btnL, btnR, pixel_index, JB_S);
    basic_task_R R (led_clk, 0, sw[1], sw[3],frame_begin,sample_pixel, JB_R);
    basic_task_Q Q (clk, led_clk, 0, btnL, btnC, btnR, pixel_index, JB_Q);
    basic_task_P P (clk, btnL, btnR, btnU, btnD, btnC, pixel_index, JB_P);
  
    assign oled_data = sw[15] ? JB_S :
                sw[14] ? JB_R :
                sw[13] ? JB_Q :
                sw[12] ? JB_P : 8'hZZ;

    Oled_Display display(led_clk, 0, frame_begin, sending_pixels,
        sample_pixel, pixel_index, oled_data,JB[0],JB[1],JB[3],JB[4],JB[5],JB[6],JB[7]);
endmodule