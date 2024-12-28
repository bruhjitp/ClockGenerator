`timescale 1ns / 1ps

module clk_gen_top
(
input clk_in, rst,
input [1:0] en, //00-en2; 01-en5; 10-en2_5; 11-en_doub
output reg clk_out,
output reg [1:0]which_clk //00-div2, 01-div5, 10-div2.5, 11-mul2
);
wire clk_div2, clk_div5, clk_div2_5, clk_mul_2;
div_2 d0 (clk_in, ~(en[1]|en[0]), rst, clk_div2);
div_5 d1 (clk_in, (~en[1])&en[0], rst, clk_div5);
div_2_5 d2 (clk_in, en[1]&(~en[0]), rst, clk_div2_5);
//mul_2 d3 (clk_in, en[1]&en[0], rst, clk_mul_2);
always @(*)
begin
case(en)

2'b00:
    begin
        clk_out   <= clk_div2;
        which_clk <=00;
    end
2'b01:
    begin
        clk_out   <= clk_div5;
        which_clk <=01;
    end
    
2'b10:
    begin
        clk_out = clk_div2_5;
        which_clk =10;
    end
 
2'b11:
    begin
        clk_out = clk_mul_2;
        which_clk =11;
    end
    endcase
end//always
endmodule

module div_2
(
input clk, en, rst,
output reg clk_div2
);
reg count_div2 = 1'b0;
always@ (posedge clk)
begin
if(en=='b1)
    begin
    if (count_div2<1)
        begin
        if (rst==1'b1)
            count_div2 <= 0;
        else
            count_div2 <= count_div2+1'b1;
        end
    else
        count_div2 <= 1'b0;
    end //en
else
    count_div2 <= 1'b0;
end //always

always@ (posedge clk or count_div2)
begin
clk_div2 <= count_div2;
end
endmodule


module div_5
(
input clk, en, rst,
output clk_div5
);
reg [2:0] count_div5 = 1'b0;
wire clk_div5_temp;
always@ (posedge clk)
begin
if(en==1'b1)
    begin
    if (count_div5<4)
        begin
        if (rst==1'b1)
            count_div5 <= 0;
        else
            count_div5 <= count_div5+1'b1;
        end
    else
        count_div5 <= 1'b0;
    end //en
else
    count_div5 <= 1'b0;
end //always
dff_neg d0 (clk, count_div5[1], rst, clk_div5_temp);
assign clk_div5 = clk_div5_temp | count_div5[2];
endmodule


module div_2_5
(
input clk, en, rst,
output clk_div2_5
);

wire [4:0] count;
wire phase_count2;
shiftreg_5 d0(clk,rst,en,count);
dff_pos d1(clk,count[2],rst,phase_count2);

assign clk_div2_5 = count[0] + phase_count2;
endmodule


module mul_2 //non synthesisable as it has delay element[practical only when done physically matching the delay y T/4]
(
input clk, en, rst,
output reg clk_mul_2
);
wire clk_del;

assign #2.5 clk_del = clk; //delay based on T=10ns
always @(*)
begin
if (rst==1'b1)
    clk_mul_2 = 1'b0;
else
    clk_mul_2 = clk_del ^ clk;
end
endmodule

module dff_neg
(
input clk,d_in,rst,
output reg q_out
);
always @(negedge clk)
begin
    if(rst==1'b1)
        q_out <= 1'b0;
    else
        q_out <= d_in;
end
endmodule

module dff_pos
(
input clk,d_in,rst,
output reg q_out
);
always @(posedge clk)
begin
    if(rst==1'b1)
        q_out <= 1'b0;
    else
        q_out <= d_in;
end
endmodule

module shiftreg_5
(
input clk, rst, en,
output [4:0]val
);
reg [4:0]temp_val=5'b1;
always @(negedge clk)
begin
if(en==1'b1)
begin
    if(rst==1'b0)
        begin
        if(temp_val<=5'h08)
            temp_val <= temp_val<<1;
        else if(temp_val==5'h10)
            temp_val <= 1'b1;
        end
    else
        temp_val = 5'b1;
end
else
    temp_val = 5'b1;
end

assign val = temp_val;
endmodule