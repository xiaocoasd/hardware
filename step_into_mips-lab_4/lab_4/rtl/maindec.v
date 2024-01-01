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
	output wire isJALR,
	output wire cp0we,cp0sel,
	output wire breakM,syscall,reserve,eret
    );//alusrc信号控制是否选择立即数
    wire [4:0]funct2;
    assign funct2=instrD[20:16];
    wire [5:0]funct;
    assign funct=instrD[5:0];
    wire [5:0]op;
    assign op=instrD[31:26];
	reg[28:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,imm_ctrl,DMread_ctrl,DMwrite_ctrl,aluop,breakM,syscall,reserve,eret,cp0we,cp0sel} = controls;
	always @(*) begin
		 case (op)
		    //J-B
		    6'b000100:controls <= 29'b000_0001_00_00_0_000_00_000000_000000;//beq
		    6'b000101:controls <= 29'b000_0010_00_00_0_000_00_000000_000000;//bne
		    6'b000001:
		    begin
		        case(funct2)
		        5'b00001:controls <= 29'b000_0011_00_00_0_000_00_000000_000000;//bgez
		        5'b00000:controls <= 29'b000_0100_00_00_0_000_00_000000_000000;//bltz
		        5'b10000:controls <= 29'b100_0101_00_00_0_000_00_000000_000000;//bltzal
		        5'b10001:controls <= 29'b100_1000_00_00_0_000_00_000000_000000;//bgezal
		        default:controls <= 29'b000_0000_00_00_0_000_00_000000_000000;
		        endcase
		    end
		    //算数运算指令
		    6'b001000:controls <= 29'b101_0000_00_00_0_000_00_010001_000000;//addi
		    6'b001001:controls <= 29'b101_0000_00_00_0_000_00_000001_000000;//addiu
		    6'b001010:controls <= 29'b101_0000_00_00_0_000_00_010111_000000;//slti
		    6'b001011:controls <= 29'b101_0000_00_00_0_000_00_000111_000000;//sltiu
		    //j-b
		    6'b000111:controls <= 29'b000_0110_00_00_0_000_00_000000_000000;//bgtz
		    6'b000110:controls <= 29'b000_0111_00_00_0_000_00_000000_000000;//blez
		    6'b000010:controls <= 29'b000_0000_00_01_0_000_00_000000_000000;//j
		    6'b000011:controls <= 29'b100_0000_00_01_0_000_00_000000_000000;//jal
		    //l-s
		    6'b100011:controls <= 29'b101_0000_01_00_0_101_00_010001_000000;//lw
		    6'b100000:controls <= 29'b101_0000_01_00_0_001_00_010001_000000;//lb
		    6'b100100:controls <= 29'b101_0000_01_00_0_010_00_010001_000000;//lbu
		    6'b100001:controls <= 29'b101_0000_01_00_0_011_00_010001_000000;//lh
		    6'b100101:controls <= 29'b101_0000_01_00_0_100_00_010001_000000;//lhu
		    6'b101000:controls <= 29'b001_0000_10_00_0_000_01_010001_000000;//sb
		    6'b101001:controls <= 29'b001_0000_10_00_0_000_10_010001_000000;//sh
		    6'b101011:controls <= 29'b001_0000_10_00_0_000_11_010001_000000;//sw
		    //逻辑运算
		    6'b001111:controls <= 29'b101_0000_00_00_1_000_00_001010_000000;//lui
		    6'b001101:controls <= 29'b101_0000_00_00_1_000_00_000100_000000;//ori
		    6'b001100:controls <= 29'b101_0000_00_00_1_000_00_010001_000000;//andi
		    6'b001110:controls <= 29'b101_0000_00_00_1_000_00_000110_000000;//xori
			6'b000000:
			    begin
			        case(funct)
			        6'b100000:controls <= 29'b110_0000_00_00_0_000_00_010001_000000;//add
			        6'b100001:controls <= 29'b110_0000_00_00_0_000_00_000001_000000;//addu
			        6'b100010:controls <= 29'b110_0000_00_00_0_000_00_010010_000000;//sub
			        6'b100011:controls <= 29'b110_0000_00_00_0_000_00_000010_000000;//subu
			        6'b101010:controls <= 29'b110_0000_00_00_0_000_00_010111_000000;//slt
			        6'b101011:controls <= 29'b110_0000_00_00_0_000_00_000111_000000;//sltu
			        6'b010000:controls <= 29'b110_0000_00_00_0_000_00_100010_000000;//mfhi
			        6'b010010:controls <= 29'b110_0000_00_00_0_000_00_100011_000000;//mflo
			        6'b010001:controls <= 29'b110_0000_00_00_0_000_00_100000_000000;//mthi
			        6'b010011:controls <= 29'b110_0000_00_00_0_000_00_100001_000000;//mtlo
			        6'b011000:controls <= 29'b110_0000_00_00_0_000_00_011011_000000;//mult
			        6'b011001:controls <= 29'b110_0000_00_00_0_000_00_001011_000000;//multu
			        6'b011010:controls <= 29'b110_0000_00_00_0_000_00_011100_000000;//div
			        6'b011011:controls <= 29'b110_0000_00_00_0_000_00_001100_000000;//divu
			        
			        
			        6'b100111:controls <= 29'b110_0000_00_00_0_000_00_000101_000000;//nor
			        6'b100100:controls <= 29'b110_0000_00_00_0_000_00_010001_000000;//and
			        6'b100101:controls <= 29'b110_0000_00_00_0_000_00_000100_000000;//or
			        6'b100110:controls <= 29'b110_0000_00_00_0_000_00_000110_000000;//xor
			        6'b000000:controls <= 29'b110_0000_00_00_0_000_00_001000_000000;//sll
			        6'b000010:controls <= 29'b110_0000_00_00_0_000_00_001001_000000;//srl
			        6'b000011:controls <= 29'b110_0000_00_00_0_000_00_011001_000000;//sra
			        6'b000100:controls <= 29'b110_0000_00_00_0_000_00_101000_000000;//sllv
			        6'b000110:controls <= 29'b110_0000_00_00_0_000_00_101001_000000;//srlv
			        6'b000111:controls <= 29'b110_0000_00_00_0_000_00_111001_000000;//srav
			        6'b001000:controls <= 29'b000_0000_00_10_0_000_00_000000_000000;//jr
			        6'b001001:controls <= 29'b110_0000_00_10_0_000_00_000000_000000;//jalr
			        6'b001101:controls <= 29'b000_0000_00_00_0_000_00_000000_100000;//break
			        6'b001100:controls <= 29'b000_0000_00_00_0_000_00_000000_010000;//syscall
			        default:controls<= 29'b110_0000_00_00_0_000_00_000000_000000;
			        endcase
			    end
			 6'b010000:
			 begin
                if (instrD == 32'b01000010000000000000000000011000)
                    controls = 29'b000_0000_00_00_0_000_00_000000_000100;      //eret
                else if (instrD[25:21]==5'b00100 && instrD[10:3]==0)
                    controls = 29'b000_0000_00_00_0_000_00_000000_000010;       //mtc0
                else if (instrD[25:21]==5'b00000 && instrD[10:3]==0)
                    controls = 29'b000_0000_00_00_0_000_00_000000_000001;      //mfc0
                else
                    controls = 29'b000_0000_00_00_0_000_00_000000_001000;
            end

                

			default:  controls <= 29'b000_0000_00_00_0_000_00_000000_001000;//illegal op
		endcase
	end
	assign isJR = (op == 6'b000000) & (funct == 6'b001000);
	assign isJALR = (op == 6'b000000) & (funct == 6'b001001);
endmodule