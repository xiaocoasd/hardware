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
	input wire[63:0]hilo_in,
	output reg[63:0]hilo_out,
	output reg overflow
    );
	always @(*) begin
		case (op)
		    6'b010001: y <=$signed(a)+$signed(b);//ÓÐ·ûºÅ¼Ó
		    6'b000001: y <=$unsigned(a)+$unsigned(b);//ÎÞ·ûºÅ¼Ó
		    6'b010010: y <=$signed(a)-$signed(b);//ÓÐ·ûºÅ¼õ
		    6'b000010: y <=$unsigned(a)-$unsigned(b);//ÎÞ·ûºÅ¼õ
		    6'b010111: y <=$signed(a)<$signed(b);
		    6'b000111: y <=$unsigned(a)<$unsigned(b);
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
			6'b011011: hilo_out <= $signed(a) * $signed(b);//mult
			6'b001011: hilo_out <= $unsigned(a) * $unsigned(b); //multu
			6'b100000: hilo_out = {a,hilo_in[31:0]}; //mthi
			6'b100001: hilo_out = {hilo_in[31:0],a}; //mtlo
			6'b100010: y = hilo_in[63:32];//mfhi
			6'b100011: y = hilo_in[31:0];//mflo
			default : y <= 32'b0;
		endcase	
	end
endmodule
