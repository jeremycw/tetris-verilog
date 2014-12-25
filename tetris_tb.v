`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:51:39 11/23/2009 
// Design Name: 
// Module Name:    tetris_tb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module grid_tb;

reg clk;
reg[4:0] row;
reg[3:0] col;
reg[2:0] type;
reg[1:0] rot;
reg en, start;
wire ready;

reg[2:0] count;

wire[2:0] n_lines;

grid mem(clk, row, col, type, rot, en, n_lines, start, ready);

initial begin
    start <= 1;
    type <= 5;
    rot <= 0;
    clk <= 1;
    row <= 18;
end

always @(posedge clk) begin
    if(count == 4)
        count <= 0;
    else
        count <= count +1;
    if(start == 1) begin
        start <= 0;
        count <= 4;
        col <= 0;
    end
end

always @(posedge clk) begin
    if(count == 3)
        col <= col + 2;
    if(count == 4)
        en <= 1;
    else
        en <= 0;
end

always begin
    #5 clk = !clk;
end

endmodule

module jizlots_tb;

reg clk;

reg[2:0] type;
reg[1:0] rot;

wire[0:15] block_out;

JIZLOTS_sel write(type, rot, block_out);

initial begin
    clk <= 0;
    type <= 0;
    rot <= 0;
end

always begin
    #5 clk = !clk;
end

endmodule

module check_move_tb;

reg clk;
wire[4:0] row;
wire[3:0] col;
reg[2:0] type;
wire[1:0] rot_out;
reg start, left, right, down, rot, rst;
wire done, ok, hit;

reg[0:13] d;
wire[4:0] addr_row;

wire[0:15] fake[0:19];

assign fake[0] = 14'b00000000000000;
assign fake[1] = 14'b00000000000000;
assign fake[2] = 14'b00000000000000;
assign fake[3] = 14'b00000000000000;
assign fake[4] = 14'b00000000000000;
assign fake[5] = 14'b00000000000000;
assign fake[6] = 14'b00000000000000;
assign fake[7] = 14'b00000000000000;
assign fake[8] = 14'b00000000000000;
assign fake[9] = 14'b00000000000000;
assign fake[10] = 14'b00000000000000;
assign fake[11] = 14'b00000000000000;
assign fake[12] = 14'b00000000000000;
assign fake[13] = 14'b00000000000000;
assign fake[14] = 14'b00000000000000;
assign fake[15] = 14'b00000000000000;
assign fake[16] = 14'b00000000000000;
assign fake[17] = 14'b00000000000000;
assign fake[18] = 14'b00000000000000;
assign fake[19] = 14'b11111111111111;

check_move chk1(clk, d, addr_row, rst, left, right, down, rot, type, row, col, rot_out, ok, hit, done);

initial begin
    rst = 1;
    left <= 0;
    right <= 0;
    down <= 1;
    rot <= 1;
    type <= 5;
    clk = 1;
    #10 rst <= 0;
end

always @(posedge clk)
begin
     d <= fake[addr_row];
end

always begin
    #5 clk = !clk;
end

endmodule

module sync_gen_tb;

reg clk;
reg rst;
wire h_sync, v_sync, gfx_clk;
wire[9:0] x,y;
wire[3:0] r,g,b;
wire[4:0] addr_row;

reg[0:13] d;
wire[0:13] fake[0:3];

assign fake[0] = 14'b00001100010001;
assign fake[1] = 14'b00011100010011;
assign fake[2] = 14'b11110000010001;
assign fake[3] = 14'b11000000011001;

sync_gen sg(clk, h_sync, v_sync, gfx_clk, x, y, rst);
colour_gen cg(gfx_clk, x, y, d, addr_row, r, g, b, rst);

initial begin
    rst = 1;
    clk <= 1;
    #10 rst <= 0;
end

always @(posedge clk)
begin
     d <= fake[addr_row];
end

always begin
    #5 clk = !clk;
end

endmodule

module tetris_tb;

reg clk = 1;
reg start = 1;
reg left, right, rot;
wire h_sync, v_sync;
wire[9:0] r,g,b;
reg drop;

tetris tet(clk, start, left, right, rot, drop, h_sync, v_sync, r, g, b);

initial begin
    #10 start <= 0;
    left <= 0;
    right <= 0;
    rot <= 0;
    #120 rot <= 1;
    drop <= 1;
end

always begin
    #5 clk = !clk;
end

endmodule
