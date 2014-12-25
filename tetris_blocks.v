`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:41:11 11/25/2009 
// Design Name: 
// Module Name:    tetris_blocks 
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

//------------------------------------------------------------------------
// given a type and rotation outputs the block encoded in a 16 bit int
//------------------------------------------------------------------------
module JIZLOTS_sel(input[2:0] type, input[1:0] rot, output reg[0:15] block);

wire[0:15] block_t, block_z, block_s, block_j, block_l, block_o, block_i;

T_sel t(rot, block_t);
Z_sel z(rot, block_z);
S_sel s(rot, block_s);
J_sel j(rot, block_j);
L_sel l(rot, block_l);
O_sel o(rot, block_o);
I_sel i(rot, block_i);

always @*
begin
    case(type)
        0: block = block_t;
        1: block = block_z;
        2: block = block_s;
        3: block = block_j;
        4: block = block_l;
        5: block = block_o;
        6: block = block_i;
        default: block = 0; //shouldn't happen
    endcase
end

endmodule

module T_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] t0 = 16'b1110010000000000;
wire[0:15] t1 = 16'b0010011000100000;
wire[0:15] t2 = 16'b0000010011100000;
wire[0:15] t3 = 16'b1000110010000000;

always @*
begin
    case(rot)
        0: block = t0;
        1: block = t1;
        2: block = t2;
        3: block = t3;
        default: block = t0;
    endcase
end

endmodule

module Z_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] z0 = 16'b1100011000000000;
wire[0:15] z1 = 16'b0010011001000000;
wire[0:15] z2 = 16'b0000110001100000;
wire[0:15] z3 = 16'b0100110010000000;

always @*
begin
    case(rot)
        0: block = z0;
        1: block = z1;
        2: block = z2;
        3: block = z3;
        default: block = z0;
    endcase
end

endmodule

module S_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] s0 = 16'b0110110000000000;
wire[0:15] s1 = 16'b0100011000100000;
wire[0:15] s2 = 16'b0000011011000000;
wire[0:15] s3 = 16'b1000110001000000;

always @*
begin
    case(rot)
        0: block = s0;
        1: block = s1;
        2: block = s2;
        3: block = s3;
        default: block = s0;
    endcase
end

endmodule

module J_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] j0 = 16'b0100010011000000;
wire[0:15] j1 = 16'b1000111000000000;
wire[0:15] j2 = 16'b0110010001000000;
wire[0:15] j3 = 16'b0000111000100000;

always @*
begin
    case(rot)
        0: block = j0;
        1: block = j1;
        2: block = j2;
        3: block = j3;
        default: block = j0;
    endcase
end

endmodule

module L_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] l0 = 16'b0100010011000000;
wire[0:15] l1 = 16'b0000111010000000;
wire[0:15] l2 = 16'b1100010001000000;
wire[0:15] l3 = 16'b0010111000000000;

always @*
begin
    case(rot)
        0: block = l0;
        1: block = l1;
        2: block = l2;
        3: block = l3;
        default: block = l0;
    endcase
end

endmodule

module O_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] o0 = 16'b1100110000000000;

always @*
begin
    case(rot)
        default: block = o0;
    endcase
end

endmodule

module I_sel(input[1:0] rot, output reg[0:15] block);

wire[0:15] i0 = 16'b1000100010001000;
wire[0:15] i1 = 16'b0000000011110000;

always @*
begin
    case(rot)
        0: block = i0;
        1: block = i1;
        2: block = i0;
        3: block = i1;
        default: block = i0;
    endcase
end

endmodule

