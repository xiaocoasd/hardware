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
		    6'b010001: begin y = $signed(a) + $signed(b); overflow = (~y[31] & a[31] & b[31]) | (y[31] & ~a[31] & ~b[31]); end//ÓÐ·ûºÅ¼Ó
		    6'b000001: y <=$unsigned(a)+$unsigned(b);//ÎÞ·ûºÅ¼Ó
		    6'b010010: begin y = $signed(a) - $signed(b); overflow = (~y[31] & a[31] & ~b[31]) | (y[31] & ~a[31] & b[31]); end//ÓÐ·ûºÅ¼õ
		    6'b000010: y <=  $unsigned(a)-$unsigned(b);//ÎÞ·ûºÅ¼õ
		    6'b010111: begin y <=$signed(a)<$signed(b);overflow = 0; end
		    6'b000111: begin y <=$unsigned(a)<$unsigned(b);overflow = 0;end
		    6'b000110: begin y  = a ^ b;     overflow = 0; end //xor??xori
		    6'b000101: begin y  = ~(a | b);  overflow = 0; end//nor
			6'b010001: begin y = a & b;   overflow = 0; end  //and??andi
			6'b000100: begin y = a | b;   overflow = 0; end  //or
			6'b001010: begin y ={ b[15:0],16'b0 };overflow = 0; end  //lui
			6'b001000: begin y <=  b << sa;overflow = 0;end//sll
			6'b001001: begin y <= b >> sa;overflow = 0;end // srl
			6'b011001: begin y <= $signed(b) >>> sa;overflow = 0;end//sra
			6'b101000: begin y <= b << a[4:0];overflow = 0;end//sllv;
			6'b101001: begin y <= b >> a[4:0];overflow = 0;end//srlv;
			6'b111001: begin y <= $signed(b) >>> a[4:0];overflow = 0;end//srav
			6'b011011: begin hilo_out <= $signed(a) * $signed(b);overflow = 0;end//mult
			6'b001011: begin hilo_out <= $unsigned(a) * $unsigned(b);overflow = 0;end //multu
			6'b100000: begin hilo_out = {a,hilo_in[31:0]};overflow = 0;end //mthi
			6'b100001: begin hilo_out = {hilo_in[31:0],a};overflow = 0;end //mtlo
			6'b100010: begin y = hilo_in[63:32];overflow = 0;end//mfhi
			6'b100011: begin y = hilo_in[31:0];overflow = 0;end//mflo
			default :  begin y = 32'h00000000; overflow = 0; hilo_out = 0;end  
		endcase	
	end
endmodule
