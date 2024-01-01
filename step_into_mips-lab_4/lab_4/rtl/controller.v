`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	output reg pcsrcD,
	output wire[3:0]branchD,
	input wire equalD,equalD2,equalD3,equalD4,equalD5,
	output wire [1:0]jumpD,
	input wire [31:0]instrD,
	//execute stage
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,
	output wire apE,apE2,	
	output wire[5:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	output wire apM,apM2,
	output wire cp0weM,cp0selM,flushM,
	//write back stage
	output wire memtoregW,regwriteW,
	output wire apW,apW2,flushW,
    output wire imm_ctrlD,
    output wire[2:0]DMread_ctrlM,
    output wire[1:0]DMwrite_ctrlM,
    output wire isJRD,
    output wire isJALRD,
    input wire stallD,
    output wire breakD,syscallD,reserveD,eretD
    );
	
	//decode stage
	wire apD,apD2;
	wire[5:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[5:0] alucontrolD;
    wire[2:0]DMread_ctrlD;
    wire[2:0]DMread_ctrlE;
    wire[1:0]DMwrite_ctrlD;
    wire[1:0]DMwrite_ctrlE;
	//execute stage
	wire memwriteE;
	wire cp0weD,cp0weE;
	wire cp0selD,cp0selE;
	maindec md(
		instrD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		aluopD,
		imm_ctrlD,
		DMread_ctrlD,
		DMwrite_ctrlD,
		isJRD,
		isJALRD,
		cp0weD,
		cp0selD,
		breakD,syscallD,reserveD,eretD
		);
    assign alucontrolD = aluopD;
	always@(branchD)
    begin
      case(branchD)
        4'b0001:pcsrcD <= equalD;//BEQ
        4'b0010:pcsrcD <= ~equalD;//BNE
        4'b0011:pcsrcD <= equalD2;//BGEZ
        4'b1000:pcsrcD <= equalD2;//BGEZAL
        4'b0110:pcsrcD <= equalD3;//BGTZ
        4'b0111:pcsrcD <= equalD4;//BLEZ
        4'b0100:pcsrcD <= equalD5;//BLTZ
        4'b0101:pcsrcD <= equalD5;//BLTZAL
        default:pcsrcD <= 0;
      endcase
    end
    branch_jump_dec bd(
        instrD,
        apD	,
        apD2
	);
	//pipeline registers
	flopenrc #(22) regE(
		clk,
		rst,
		~stallD,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,DMread_ctrlD,DMwrite_ctrlD,apD,apD2,cp0weD,cp0selD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,DMread_ctrlE,DMwrite_ctrlE,apE,apE2,cp0weE,cp0selE}
		);
	floprc #(20) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,regwriteE,DMread_ctrlE,DMwrite_ctrlE,apE,apE2,cp0weE,cp0selE},
		{memtoregM,memwriteM,regwriteM,DMread_ctrlM,DMwrite_ctrlM,apM,apM2,cp0weM,cp0selM}
		);
	floprc #(20) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM,apM,apM2},
		{memtoregW,regwriteW,apW,apW2}
		);
endmodule