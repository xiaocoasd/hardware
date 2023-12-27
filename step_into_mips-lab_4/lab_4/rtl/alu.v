`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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


module alu(
	input wire[31:0] a,b,
	input wire[5:0] op,
	input wire[4:0]sa,
	output reg[31:0] y,
	output reg overflow
    );
    wire [4:0]d;
    assign d = a[4:0];
	always @(*) begin
		case (op)
		    6'b101000: y <= b << d; //sllv 
		    6'b001000: y <= b << sa; //sll
		    6'b000110: y <= a ^ b;  //xor��xori
		    6'b000101: y <= ~(a | b);//nor
			6'b010001: y <= a & b;  //and��andi
			6'b000100: y <= a | b;  //or
			6'b001010: y <= {b[15:0],16'b0};  //lui
			default : y <= 32'b0;
		endcase	
	end
endmodule
