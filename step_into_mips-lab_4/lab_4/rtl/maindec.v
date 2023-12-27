`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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


module maindec(
	input wire[31:0]instrD,
	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire[5:0] aluop
	
    );//alusrc信号控制是否选择立即数
    wire [5:0]funct;
    assign funct=instrD[5:0];
    wire [5:0]op;
    assign op=instrD[31:26];
	reg[12:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,aluop} = controls;
	always @(*) begin
		 case (op)
		    6'b001111:controls <= 13'b1010000_001010;//lui
		    6'b001101:controls <= 13'b1010000_000100;//ori
		    6'b001100:controls <= 13'b1010000_010001;//andi
		    6'b001110:controls <= 13'b1010000_000110;//xori
			6'b000000:
			    begin
			        case(funct)
			        6'b100111:controls <= 13'b1100000_000101;//nor
			        6'b100100:controls <= 13'b1100000_010001;//and
			        6'b100101:controls <= 13'b1100000_000100;//or
			        6'b100110:controls <= 13'b1100000_000110;//xor
			        6'b000000:controls <= 13'b1100000_001000;//sll
			        6'b000010:controls <= 13'b1100000_001001;//srl
			        6'b000011:controls <= 13'b1100000_011001;//sra
			        6'b000100:controls <= 13'b1100000_101000;//sllv
			        6'b000110:controls <= 13'b1100000_101001;//srlv
			        6'b000111:controls <= 13'b1100000_111001;//srav
			        default:controls<=13'b0000000_000000;
			        endcase
			    end
			6'b100011:controls <= 13'b1010010_000000;//LW
			6'b101011:controls <= 13'b0010100_000000;//SW
			6'b000100:controls <= 13'b0001000_000001;//BEQ
			6'b001000:controls <= 13'b1010000_000000;//ADDI
			6'b000010:controls <= 13'b0000001_000000;//J
			default:  controls <= 13'b0000000_000000;//illegal op
		endcase
	end
endmodule