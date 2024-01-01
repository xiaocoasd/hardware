`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	output wire[1:0]DMwrite_ctrl,
	output wire[2:0]DMread_ctrl 
    );
	wire[31:0]instrD;
	wire apE,apE2,apW,apW2,apM,apM2;
	wire equalD2,equalD3,equalD4,equalD5;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [5:0] alucontrolE;
	wire flushE,equalD;
    wire imm_ctrlD;
    wire [1:0]jumpD;
    wire [3:0]branchD;
    wire isJRD,isJALRD;
    
	controller c(
		clk,rst,
		//decode stage
		pcsrcD,branchD,equalD,equalD2,equalD3,equalD4,equalD5,jumpD,
		instrD,
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,apE,apE2,
		alucontrolE,

		//mem stage
		memtoregM,memwriteM,
		regwriteM,apM,apM2,
		//write back stage
		memtoregW,regwriteW,apW,apW2,
		imm_ctrlD,
		DMread_ctrl,
		DMwrite_ctrl,
		isJRD,
		isJALRD,
		stallD
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,equalD2,equalD3,equalD4,equalD5,
		instrD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,apE,apE2,
		alucontrolE,
		flushE,
		//mem stage
		memtoregM,
		regwriteM,apM,apM2,
		aluoutM,writedataM,
		readdataM,
		//writeback stage
		memtoregW,
		regwriteW,apW,apW2,
		imm_ctrlD,
		isJRD,
		isJALRD,
		stallD
	    );
	
endmodule