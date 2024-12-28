`timescale 1ns / 1ps

module clock_gen_tb();
reg clk_in, rst;
reg [1:0] en;
wire clk_out;
wire [1:0] which_clk;

clk_gen_top dut (clk_in, rst,en,clk_out,which_clk);

initial
clk_in=0;

always
#5 clk_in = ~clk_in;

initial
begin
rst=1'b1; en=2'b00;
#20 rst=1'b1; en=2'b01;
#20 rst=1'b1; en=2'b10;
#20 rst=1'b1; en=2'b11;
#20
//stop the reset
rst=1'b0; en=2'b00;
#100 rst=1'b0; en=2'b01;
#100 rst=1'b0; en=2'b10;
#100 rst=1'b0; en=2'b11;
#100
$finish;
end

endmodule