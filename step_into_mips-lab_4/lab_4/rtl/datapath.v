`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,
	input wire [3:0]branchD,
	input wire [1:0]jumpD,
	output wire equalD,equalD2,equalD3,equalD4,equalD5,
	output wire[31:0]instrD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,apE,apE2,
	input wire[5:0] alucontrolE,
	output wire flushE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,apM,apM2,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,apW,apW2,
	input wire imm_ctrlD,
	input wire isJRD,
	input wire isJALRD,
	output wire stallD
    );
	
	//fetch stage
	wire stallF;
	wire div_ready;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcplus8F,pcbranchD;
	//decode stage
	wire [31:0] pcplus4D,pcplus8D;
	wire [31:0]pcplus8M,pcplus8W;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallE; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE,saE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
	//mem stage
	wire [4:0] writeregM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
    wire [4:0] saD;
	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		alucontrolE,
		branchD,
		forwardaD,forwardbD,
		stallD,
		stallE,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,
		forwardaE,forwardbE,
		flushE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		//write back stage
		writeregW,
		regwriteW,
		isJRD,
		isJALRD,
		div_ready
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux3 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},srcaD,
		jumpD,pcnextFD);

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
    //hilo_reg  hilo(clk,rst,hilo_weW,hi_alu_outW,lo_alu_outW,hiD,loD);
	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	adder pcadd3(pcF,32'b1000,pcplus8F);
	//decode stage
	flopenr #(32) r1D(clk,rst,~stallD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenr #(32) r3D(clk,rst,~stallD,pcplus8F,pcplus8D);
	signext se(imm_ctrlD,instrD[15:0],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srcaD,srcbD,equalD,equalD2,equalD3,equalD4,equalD5);

	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
    assign saD = instrD[10:6];
    wire [31:0]pcplus8E;
    wire [4:0]writeregE1;
    wire [63:0]hilo_in,hilo_out;
    wire div_start,div_signed;
    wire [63:0]div_result;
	assign div_signed = (alucontrolE == 6'b011100)? 1'b1: 1'b0;  //div->1
	assign div_start = ((alucontrolE == 6'b011100 | alucontrolE == 6'b001100) & ~div_ready)? 1'b1: 1'b0;
	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);   //?????¡Â
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
    flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);  //3??1?¨¤?¡¤?????¡Â
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu(srca2E,srcb3E,saE,alucontrolE,aluoutE,hilo_in,hilo_out);
	div div_ex(
		.clk(clk),
		.rst(rst),
		.signed_div_i(div_signed),
		.opdata1_i(srca2E),
		.opdata2_i(srcb3E),
		.start_i(div_start),
		.annul_i(1'b0),
		.result_o(div_result),
		.ready_o(div_ready)
		);
	hilo hilo_reg(.clk(clk),
		.rst(rst),
		.flushE(flushE),
		.alucontrol(alucontrolE),
		.hi_in(hilo_out[63:32]),
		.lo_in(hilo_out[31:0]),
		.div_result(div_result),
		.hi_out(hilo_in[63:32]),
		.lo_out(hilo_in[31:0])
		); 
	mux3 #(5) wrmux(rtE,rdE,5'b11111,{apE,regdstE},writeregE1);
	mux2 #(5) wrmux2(writeregE1,rdE,apE2,writeregE);

    //divier_primarydiv_primary(clk,rst,alucontrolE,src2E,src3E,1'b0,{hi_div_outE,lo_div_out_E},reg...);
    //assign div_signalE=((alucontrolE=='DIV_CONTROL')|(alucontrolE=='DIVU_CONTROL'))?1:0;
    //mux2 #(32) hi_div(hi_alu_outE,hi_div_outE,div_signalE,hi_mux_outE);
    //mux2 #(32) lo_div(lo_alu_outE,lo_div_outE,div_signalE,lo_mux_outE);
	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);
    flopr #(32) r4M(clk,rst,pcplus8E,pcplus8M);
	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	flopr #(32) r4W(clk,rst,pcplus8M,pcplus8W);
	mux3 #(32) resmux(aluoutW,readdataW,pcplus8W,{(apW | apW2),memtoregW},resultW);
endmodule

