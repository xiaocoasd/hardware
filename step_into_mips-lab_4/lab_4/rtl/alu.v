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
	input wire [4:0]sa,
	input wire[5:0] op,
	output reg[31:0] y,
	output reg overflow
    );
	always @(*) begin
		case (op)
		    6'b010001: y <=$signed(a)+$signed(b);//l-s
		    6'b000110: y <= a ^ b;  //xor??xori
		    6'b000101: y <= ~(a | b);//nor
			6'b010001: y <= a & b;  //and??andi
			6'b000100: y <= a | b;  //or
			6'b001010: y <= {b[15:0],16'b0};  //lui
			6'b001000: y <=  b << sa;//sll
			6'b001001: y <= b >> sa; // srl
			6'b011001: y <= $signed(b) >>> sa;//sra
			6'b101000: y <= b << a[4:0];//sllv;
			6'b101001: y <= b >> a[4:0];//srlv;
			6'b111001: y <= $signed(b) >>> a[4:0];//srav
			default : y <= 32'b0;
		endcase	
	end
endmodule
