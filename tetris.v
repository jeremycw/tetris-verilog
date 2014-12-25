`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UNB
// Engineer: Jeremy Williams
// 
// Create Date:    17:59:21 11/20/2009 
// Design Name: 
// Module Name:    tetris 
// Description:    Main module for a 14x20 tetris game.
//
//                 INPUTS:
//                     clk      50 mhz system clock
//                     start    pulse to tell the game to start
//                     left     pulse to signal the move left button has been pushed
//                     right    pulse to signal the move right button has been pushed
//                     rot      pulse to signal the rotate button has been pushed
//                     drop     pulse to signal the drop button has been pushed
//
//                 OUTPUTS:
//                     r        VGA red component
//                     g        VGA green component
//                     b        VGA blue component
//                     h_sync   VGA horizontal sync
//                     v_sync   VGA vertical sync
//
//                 PIN ASSIGNMENTS:
//                     clk      PIN_N2
//                     start    PIN_V2 (switch 17)
//                     left     PIN_G26 (button 0)
//                     right    PIN_N23 (button 1)
//                     rot      PIN_P23 (button 2)
//                     drop     PIN_W26 (button 3)
//                      
//                     h_sync   PIN_A7
//                     v_sync   PIN_D8
//
//                     r[9]     PIN_E10
//                     r[8]     PIN_F11
//                     r[7]     PIN_H12
//                     r[6]     PIN_H11
//                     r[5]     PIN_A8
//                     r[4]     PIN_C9
//                     r[3]     PIN_D9
//                     r[2]     PIN_G10
//                     r[1]     PIN_F10
//                     r[0]     PIN_C8
//
//                     g[9]     PIN_D12
//                     g[8]     PIN_E12
//                     g[7]     PIN_D11
//                     g[6]     PIN_G11
//                     g[5]     PIN_A10
//                     g[4]     PIN_B10
//                     g[3]     PIN_D10
//                     g[2]     PIN_C10
//                     g[1]     PIN_A9
//                     g[0]     PIN_B9
//
//                     b[9]     PIN_B12
//                     b[8]     PIN_C12
//                     b[7]     PIN_B11
//                     b[6]     PIN_C11
//                     b[5]     PIN_J11
//                     b[4]     PIN_J10
//                     b[3]     PIN_G12
//                     b[2]     PIN_F12
//                     b[1]     PIN_J14
//                     b[0]     PIN_J13
//
//////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
// Top module, connects the ticker to the logic and the logic to the vga
//------------------------------------------------------------------------
module tetris(input clk, input start, input left, input right, input rotate, input drop,
              output h_sync, output v_sync, output blank, output vga_clk,
              output[9:0] r, output[9:0] g, output[9:0] b, output[15:0] score);

wire gfx_clk, game_over, down;
wire[9:0] x,y;
wire[4:0] addr_row;
wire[0:13] d;
wire[7:0] level;
wire left_db, right_db, rotate_db, locked;

reg[31:0] seed = 0;

wire rst = start | game_over;
assign vga_clk = ~gfx_clk;

pll pll(start, clk, gfx_clk, locked); 
debounce db_lft(clk, ~left, left_db, rst);
debounce db_rght(clk, ~right, right_db, rst);
debounce db_rt(clk, ~rotate, rotate_db, rst);
debounce db_drp(clk, ~drop, drop_db, rst);
ticker down_ctrl(clk, level, down, rst);
tetris_logic log(clk, gfx_clk, rst, game_over, left_db, right_db, down, rotate_db, drop_db, seed,
                 addr_row, d, score, level);
sync_gen sg(clk, h_sync, v_sync, blank, gfx_clk, x, y, start);
colour_gen cg(gfx_clk, x, y, d, addr_row, r, g, b, start);

always @(posedge clk)
    seed <= seed+1;

endmodule

//------------------------------------------------------------------------
// Main tetris logic block that controls check_move and the grid
//------------------------------------------------------------------------
module tetris_logic(input clk, input gfx_clk, input start, output reg game_over,
                    input left, input right, input down, input rotate, input drop, input[31:0] seed,
                    input[4:0] addr_row_vga, output[0:13] d_vga,
                    output[15:0] score, output[7:0] level);

//state registers
wire[2:0] type;
wire[1:0] rot;
wire[4:0] row;
wire[3:0] col;
reg hit_flag;
reg left_buf, right_buf, down_buf, rotate_buf, drop_buf;
reg[2:0] count;

wire grid_ready, check_done, ok, hit;
wire[4:0] addr_row;
wire[0:13] d;
wire[2:0] n_lines;
wire[2:0] number;

wire next = grid_ready & hit_flag | start;

grid grid(clk, gfx_clk, row, col, type, rot, d, d_vga, addr_row, addr_row_vga, hit, n_lines, start, grid_ready);
check_move chk(clk, d, addr_row, next, left_buf, right_buf, down_buf, rotate_buf, type, row, col, rot, ok, hit, check_done);
scorer sc(clk, n_lines, grid_ready, score, level, start);
rand rand_gen(clk, seed, start, number);
next_block nb(clk, next, number, type, start);

//hold hit until grid is done writing
always @(posedge clk)
begin
    if(hit)
        hit_flag <= 1;
    if(grid_ready)
        hit_flag <= 0;
    if(start)
        hit_flag <= 0;
end

//buffer input
always @(posedge clk)
begin
    if(left)
        left_buf <= left;
    if(right)
        right_buf <= right;
    if(down || drop_buf)
        down_buf <= 1;
    if(rotate)
        rotate_buf <= rotate;
    if(drop)
        drop_buf <= drop;
    if(hit)
        drop_buf <= 0;
    if(count == 0) begin
        right_buf <= right;
        left_buf <= left;
        down_buf <= down;
        rotate_buf <= rotate;
    end
    if(count < 5)
        count <= count+3'd1;
    if(next || count == 5)
        count <= 0;
    if(start) begin
        right_buf <= 0;
        left_buf <= 0;
        down_buf <= 0;
        rotate_buf <= 0;
    end
end

//check for game over
always @*
begin
    if(row == 0 && col == 6 && check_done && !ok)
        game_over = 1;
    else
        game_over = 0;
end

endmodule

//------------------------------------------------------------------------
// generate pseudo random numbers from 0-7
//------------------------------------------------------------------------
module rand(input clk, input[31:0] seed, input start, output[2:0] number);

reg[31:0] seed_reg;

assign number = start ? seed[31:29] : seed_reg[31:29];

always @(posedge clk)
begin
    seed_reg <= seed_reg * 1103515245;
    if(start)
        seed_reg <= seed;
end

endmodule

//------------------------------------------------------------------------
// grid memory writes the current block to memory if en is high
//------------------------------------------------------------------------
module grid(input clk, input gfx_clk, input[4:0] row, input[3:0] col, input[2:0] type, input[1:0] rot,
            output reg[0:13] d, output reg[0:13] d_vga, input[4:0] addr_row, input[4:0] addr_row_vga,
            input en, output reg[2:0] n_lines, input rst, output ready);

reg[0:13] grid[0:19];
reg[2:0] count;

wire[0:15] block;
wire[0:13] block_row[0:3];

assign block_row[0] = {block[0:3], 10'b0000000000};
assign block_row[1] = {block[4:7], 10'b0000000000};
assign block_row[2] = {block[8:11], 10'b0000000000};
assign block_row[3] = {block[12:15], 10'b0000000000};

assign ready = count == 4;

JIZLOTS_sel write(type, rot, block);

reg[4:0] i;
always @(posedge clk)
begin
    i = 0;
    if(en == 1) begin
        for(i = 0; i < 4; i = i+5'd1) begin //write the block to the grid
            if(col != 15)
                grid[row+i] <= (block_row[i] >> col) | grid[row+i];
            else
                grid[row+i] <= (block_row[i] << 1) | grid[row+i];
        end
    end
    //after writing a block to the grid clear lines if they are full
    if(count < 4) begin
        if(grid[row+count] == 14'b11111111111111) begin
            n_lines <= n_lines + 3'd1;
            for(i = 5'd20; i > 0; i = i-5'd1)
                if(i-1 <= row+count)
                    if(i-1 > 0)
                        grid[i-5'd1] <= grid[i-5'd2];
                    else
                        grid[i-5'd1] <= 0;
        end
    end
    if(en)
        n_lines <= 0;
    if(rst) begin
        for(i = 0; i < 20; i = i+5'd1)
            grid[i] <= 0;
        n_lines <= 0;
    end
end

always @(posedge clk)
begin
    if(en)
        count <= 0;
    if(count < 5)
        count <= count+3'd1;
    if(rst) begin
        count <= 3'd5;
    end
end

always @(posedge clk)
    d <= grid[addr_row];
    

//overlay the current falling block before sending a row off to the vga
wire[0:13] row_overlay = col != 15 ? (block_row[addr_row_vga-row] >> col) : (block_row[addr_row_vga-row] << 1);
always @(posedge gfx_clk)
begin
    if(addr_row_vga >= row && addr_row_vga < row+4)
        d_vga <= grid[addr_row_vga] | row_overlay;
    else
        d_vga <= grid[addr_row_vga];
end

endmodule

//------------------------------------------------------------------------
// check_move checks if a move is valid, signals ok if it is and
// changes the current column, row and rotation to the new ones
//------------------------------------------------------------------------
module check_move(input clk, input[0:13] d, output reg[4:0] addr_row, input rst,
                  input left, input right, input down, input rotate, input[2:0] type,
                  output reg[4:0] row, output reg[3:0] col, output reg[1:0] rot,
                  output reg ok, output hit, output reg done);

reg[0:13] row_buf[0:3];
reg[2:0] count;
reg left_buf, right_buf, down_buf, rotate_buf;
reg[2:0] type_buf;

wire[0:15] block;
wire[0:13] block_row[0:3];
wire[0:3] block_col[0:3];

assign block_row[0] = {block[0:3], 10'b0000000000};
assign block_row[1] = {block[4:7], 10'b0000000000};
assign block_row[2] = {block[8:11], 10'b0000000000};
assign block_row[3] = {block[12:15], 10'b0000000000};

assign block_col[0] = {block[0], block[4], block[8], block[12]};
assign block_col[1] = {block[1], block[5], block[9], block[13]};
assign block_col[2] = {block[2], block[6], block[10], block[14]};
assign block_col[3] = {block[3], block[7], block[11], block[15]};

wire[3:0] new_col = col-left_buf+right_buf;
wire[4:0] new_row = row+down_buf;
wire[1:0] new_rot = rot+rotate_buf;

assign hit = !ok & done & down_buf;

JIZLOTS_sel check(type_buf, new_rot, block);

//read in the 4 rows under the current block from grid memory
always @(posedge clk)
begin
    case(count)
        1: row_buf[0] <= d;
        2: row_buf[1] <= d;
        3: row_buf[2] <= d;
        4: row_buf[3] <= d;
    endcase
end

always @*
begin
    case(count)
        0: addr_row = new_row;
        1: addr_row = new_row+5'd1;
        2: addr_row = new_row+5'd2;
        3: addr_row = new_row+5'd3;
        default: addr_row = 0;
    endcase
end

//buffer input
always @(posedge clk)
begin
    if(count == 0) begin
        left_buf <= left;
        right_buf <= right;
        rotate_buf <= rotate;
        down_buf <= down;
        type_buf <= type;
    end
    if(count < 5)
        count <= count + 3'd1;
    if(rst || count == 5)
        count <= 0;
end

reg[2:0] i,j;
always @*
begin
    ok = 1;
    for(i = 0; i < 4; i = i+3'd1) begin //general case
        if(new_col != 15) begin
            if(((block_row[i] >> new_col) & row_buf[i]) > 0)
                ok = 0;
        end
        else begin
            if(((block_row[i] << 1) & row_buf[i]) > 0)
                ok = 0;
        end
    end
    if(new_col == 14) //special case: 2 columns off the left
        ok = 0;
    if(new_col == 15) //special case: 1 column off the left
        if(block_col[0] > 0)
            ok = 0;
    j = 0;
    if(new_col > 10 && new_col != 15) begin //special case: off the right of the grid
        for(i = 3'd3; i > 0; i = i-3'd1) begin
            if(j < (4'd4 - (4'd14-new_col))) begin
                if(block_col[i] > 0)
                    ok = 0;
                j = j+3'd1;
            end
        end
    end
    j = 0;
    if(new_row > 16) begin //special case: off the bottom of the grid
        for(i = 3'd3; i > 0; i = i-3'd1) begin
            if(j < (5'd4 - (5'd20-new_row))) begin
                if(block_row[i] > 0)
                    ok = 0;
                j = j+3'd1;
            end
        end
    end
end

always @*
begin
    if(count == 5)
        done = 1;
    else
        done = 0;
end

//update row, column and rotation of the block if it is valid
always @(posedge clk)
begin
    if(ok && done) begin
        col <= new_col;
        row <= new_row;
        rot <= new_rot;
    end
    if(rst) begin
        col <= 4'd6;
        row <= 0;
        rot <= 0;
    end
end

endmodule

//------------------------------------------------------------------------
// keeps score, the forumal is
// new score = current score +
//                  (lines cleared with the last move)^2 * current level
// when 6 lines are cleared the level increases
//------------------------------------------------------------------------
module scorer(input clk, input[2:0] n_lines, input start, output reg[15:0] score, output reg[7:0] level, input rst);

reg[3:0] lines;

//calculate score and level
always @(posedge clk)
begin
    if(start) begin
        score <= score + n_lines * n_lines * level;
        lines <= lines + n_lines;
    end
    if(lines >= 6) begin
        lines <= 0;
        level <= level + 8'd1;
    end
    if(rst) begin
        level <= 1;
        lines <= 0;
        score <= 0;
    end
end

endmodule

//------------------------------------------------------------------------
// gets the next block
//------------------------------------------------------------------------
module next_block(input clk, input next, input[2:0] rand, output reg[2:0] type, input rst);

reg[2:0] count;

always @(posedge clk)
begin
    if(next) begin
        if(rand > 6) begin //compensates for when rand = 7
           type <= count;
           count <= count+3'd1;
        end
        else
            type <= rand;
    end
    if(count == 6)
        count <= 0;
    if(rst) begin
        count <= 0;
        if(rand > 6)
            type <= 0;
        else
            type <= rand;
    end
end

endmodule

//------------------------------------------------------------------------
// make an input only last one clock cycle
//------------------------------------------------------------------------
module debounce(input clk, input d, output q, input rst);

reg down;

assign q = d & !down;

always @(posedge clk)
begin
    if(q)
        down <= 1;
    if(!d)
        down <= 0;
    if(rst)
        down <= 0;
end

endmodule

//------------------------------------------------------------------------
// based on the level generate a constant tick for the down input
//------------------------------------------------------------------------
module ticker(input clk, input[7:0] level, output reg tick, input rst);

reg[31:0] cycles;
reg[4:0] count;

always @(posedge clk)
begin
    if(cycles < 2000000) //1/25th of a second
        cycles <= cycles+1;
    else begin
        cycles <= 0;
        count <= count+5'd1;
    end
    if(count == 5'd25-level) begin //25 levels until blocks fall at the rate of the clock
        count <= 0;
        tick <= 1;
    end
    if(tick)
        tick <= 0;
    if(rst) begin
        tick <= 0;
        count <= 0;
        cycles <= 0;
    end
end

endmodule
