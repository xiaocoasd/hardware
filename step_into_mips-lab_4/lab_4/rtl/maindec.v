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
	output wire[3:0]branch,
	output wire alusrc,
	output wire regdst,regwrite,
	output wire [1:0]jump,
	output wire[5:0] aluop,
	output wire imm_ctrl,
	output wire[2:0]DMread_ctrl,
	output wire[1:0]DMwrite_ctrl,
	output wire isJR,
	output wire isJALR
    );//alusrc信号控制是否选择立即数
    wire [4:0]funct2;
    assign funct2=instrD[20:16];
    wire [5:0]funct;
    assign funct=instrD[5:0];
    wire [5:0]op;
    assign op=instrD[31:26];
	reg[22:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,imm_ctrl,DMread_ctrl,DMwrite_ctrl,aluop} = controls;
	always @(*) begin
		 case (op)
		    //J-B
		    6'b000100:controls <= 23'b000_0001_00_00_0_000_00_000000;//beq
		    6'b000101:controls <= 23'b000_0010_00_00_0_000_00_000000;//bne
		    6'b000001:
		    begin
		        case(funct2)
		        5'b00001:controls <= 23'b000_0011_00_00_0_000_00_000000;//bgez
		        5'b00000:controls <= 23'b000_0100_00_00_0_000_00_000000;//bltz
		        5'b10000:controls <= 23'b000_0101_00_00_0_000_00_000000;//bltzal
		        5'b10001:controls <= 23'b000_1000_00_00_0_000_00_000000;//bgezal
		        default:controls <= 23'b000_0000_00_00_0_000_00_000000;
		        endcase
		    end
		    6'b000111:controls <= 23'b000_0110_00_00_0_000_00_000000;//bgtz
		    6'b000110:controls <= 23'b000_0111_00_00_0_000_00_000000;//blez
		    6'b000010:controls <= 23'b000_0000_01_00_0_000_00_000000;//j
		    6'b000011:controls <= 23'b000_0000_01_00_0_000_00_000000;//jal
		    //l-s
		    6'b100011:controls <= 23'b101_0000_01_00_0_101_00_010001;//lw
		    6'b100000:controls <= 23'b101_0000_01_00_0_001_00_010001;//lb
		    6'b100100:controls <= 23'b101_0000_01_00_0_010_00_010001;//lbu
		    6'b100001:controls <= 23'b101_0000_01_00_0_011_00_010001;//lh
		    6'b100101:controls <= 23'b101_0000_01_00_0_100_00_010001;//lhu
		    6'b101000:controls <= 23'b001_0000_10_00_0_000_01_010001;//sb
		    6'b101001:controls <= 23'b001_0000_10_00_0_000_10_010001;//sh
		    6'b101011:controls <= 23'b001_0000_10_00_0_000_11_010001;//sw
		    //逻辑运算
		    6'b001111:controls <= 23'b101_0000_00_00_1_000_00_001010;//lui
		    6'b001101:controls <= 23'b101_0000_00_00_1_000_00_000100;//ori
		    6'b001100:controls <= 23'b101_0000_00_00_1_000_00_010001;//andi
		    6'b001110:controls <= 23'b101_0000_00_00_1_000_00_000110;//xori
			6'b000000:
			    begin
			        case(funct)
			        6'b100111:controls <= 23'b110_0000_00_00_0_000_00_000101;//nor
			        6'b100100:controls <= 23'b110_0000_00_00_0_000_00_010001;//and
			        6'b100101:controls <= 23'b110_0000_00_00_0_000_00_000100;//or
			        6'b100110:controls <= 23'b110_0000_00_00_0_000_00_000110;//xor
			        6'b000000:controls <= 23'b110_0000_00_00_0_000_00_001000;//sll
			        6'b000010:controls <= 23'b110_0000_00_00_0_000_00_001001;//srl
			        6'b000011:controls <= 23'b110_0000_00_00_0_000_00_011001;//sra
			        6'b000100:controls <= 23'b110_0000_00_00_0_000_00_101000;//sllv
			        6'b000110:controls <= 23'b110_0000_00_00_0_000_00_101001;//srlv
			        6'b000111:controls <= 23'b110_0000_00_00_0_000_00_111001;//srav
			        6'b001000:controls <= 23'b000_0000_10_00_0_000_00_000000;//jr
			        6'b001001:controls <= 23'b000_0000_10_00_0_000_00_000000;//jalr
			        default:controls<=23'b000_0000_00_00_0_000_00_000000;
			        endcase
			    end
			default:  controls <= 23'b000_0000_00_00_0_000_00_000000;//illegal op
		endcase
	end
	assign isJR = (op == 6'b000000) & (funct == 6'b001000);
	assign isJALR = (op == 6'b000000) & (funct == 6'b001001);
endmodule