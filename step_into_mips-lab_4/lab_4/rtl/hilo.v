`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/30 10:51:44
// Design Name: 
// Module Name: hilo
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


module hilo(
	input wire clk,rst,flushE,
	input wire [5:0] alucontrol,
	input wire [31:0] hi_in,lo_in,
	input wire [63:0] div_result,
	output reg [31:0] hi_out,lo_out
    );

	always @(negedge clk) begin
		if(rst) begin
			hi_out <= 0;
			lo_out <= 0;
		end 
		else if(~flushE) begin
			if(alucontrol==6'b011100|alucontrol==6'b001100) //div or divu 
			begin
				hi_out <=div_result[63:32];
				lo_out <=div_result[31:0];
			end
			else if(alucontrol == 6'b011011 | alucontrol == 6'b001011) begin //mult or multu
				hi_out <=hi_in;
				lo_out <=lo_in;
			end
			else if(alucontrol == 6'b100000) begin //mthi
				hi_out <= hi_in;
			end
			else if(alucontrol == 6'b100001) begin  //mtlo
				lo_out <= lo_in;
			end
		end
	end
endmodule
