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
	output wire flushW,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	input wire cp0weM ,cp0selM,
	output wire flushM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,apW,apW2,
	input wire imm_ctrlD,
	input wire isJRD,
	input wire isJALRD,
	output wire stallD,
	input wire breakD,syscallD,reserveD,eretD
    );
	
	
	//fetch stage
	wire stallF;
	wire branchjumpF,branchjumpD,branchjumpE,branchjumpM;
	wire overflowE;
	wire overflowM;
	wire div_ready;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcplus8F,pcbranchD;
	wire [31:0] pcD,pcE,pcM;
	//decode stage
	wire [31:0] pcplus4D,pcplus8D;
	wire [31:0]pcplus8M,pcplus8W;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallE; 
	wire flushF;
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
	wire [4:0] writeregM,rdM;
	wire [31:0]srcbM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;
	wire [31:0] excepttype_i;
	wire [31:0] bad_addr_i;
	wire [31:0] cp0out_data;
    wire [4:0] saD;
    wire [31:0] aluout2E,aluout2M;
    wire [31:0] count_o;
    wire [31:0] compare_o;
    wire [31:0] status_o;
    wire [31:0] cause_o;
    wire [31:0] epc_o;
    wire [31:0] config_o;
    wire [31:0] prid_o;
    wire [31:0] badvaddr;
    wire timer_int_o;
    wire [6:0] exceptD;
    wire [6:0] exceptE;
    wire [6:0] exceptM;
    wire [5:0] alucontrolM;
    wire [31:0] newPC;
	//hazard detection
	hazard h(
	    newPC,
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
		div_ready,
		excepttype_i,
		overflowM,
		epc_o,
		flushF,
		flushD,
		flushM,
		flushW
		);
	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	mux3 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},srcaD,
		jumpD,pcnextFD);
	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
	
	exception exception_type(
		.rst(rst),
		.pcM(pcM),
		.exceptM(exceptM),
		.cp0_status(status_o),
		.cp0_cause(cause_o),
		.aluoutM(aluoutM),
		.excepttype(excepttype_i),
		.bad_addr(bad_addr_i)
		);
    //hilo_reg  hilo(clk,rst,hilo_weW,hi_alu_outW,lo_alu_outW,hiD,loD);
	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newPC,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	adder pcadd3(pcF,32'b1000,pcplus8F);
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	flopenrc #(32) r4D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,branchjumpF,branchjumpD);
	
	
	signext se(imm_ctrlD,instrD[15:0],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srcaD,srcbD,equalD,equalD2,equalD3,equalD4,equalD5);
    assign exceptD[3:0] = {reserveD,breakD,syscallD,eretD};
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
    flopenrc #(32) 	r9E(clk,rst,~stallE,flushE,pcD,pcE);
    flopenrc #(1) 	r10E(clk,rst,~stallE,flushE,branchjumpD,branchjumpE);
    flopenrc #(4) 	r11E(clk,rst,~stallE,flushE,exceptD[3:0],exceptE[3:0]);
    
    
    
	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);  //3??1?¨¤?¡¤?????¡Â
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	alu alu(srca2E,srcb3E,saE,alucontrolE,aluoutE,hilo_in,hilo_out,overflowE);
	
	assign exceptE[4]= overflowE;
	
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

    mux2 #(32) wrmux23(aluoutE,pcplus8E,(apE |apE2),aluout2E);
    //divier_primarydiv_primary(clk,rst,alucontrolE,src2E,src3E,1'b0,{hi_div_outE,lo_div_out_E},reg...);
    //assign div_signalE=((alucontrolE=='DIV_CONTROL')|(alucontrolE=='DIVU_CONTROL'))?1:0;
    //mux2 #(32) hi_div(hi_alu_outE,hi_div_outE,div_signalE,hi_mux_outE);
    //mux2 #(32) lo_div(lo_alu_outE,lo_div_outE,div_signalE,lo_mux_outE);
	//mem stage
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluoutE,aluoutM);
	floprc #(5) r3M(clk,rst,flushM,writeregE,writeregM);
    //floprc #(32) r4M(clk,rst,flushM,pcplus8E,pcplus8M);
    floprc #(5) r5M(clk,rst,flushM,rdE,rdM);
    floprc #(32) r6M(clk,rst,flushM,srcb3E,srcbM);
    floprc #(32) r7M(clk,rst,flushM,pcE,pcM);
    floprc #(1) r8M(clk,rst,flushM,branchjumpE,branchjumpM);
    floprc #(32) r9M(clk,rst,flushM,aluout2E,aluout2M);
    floprc #(1) r10M(clk,rst,flushM,overflowE,overflowM);
    floprc #(5) r11M(clk,rst,flushM,exceptE[4:0],exceptM[4:0]);
    floprc #(6) r12M(clk,rst,flushM,alucontrolE,alucontrolM);
    
    mux2 #(32) cp0selmux(aluout2M,cp0out_data,cp0selM,aluoutM);
    
    addr_except addrexcept(
		.addrs(aluoutM),
		.alucontrolM(alucontrolM),
		.adelM(adelM),
		.adesM(adesM)
		);
		 
    assign exceptM[6:5]={adesM,adelM};
    
    
	//writeback stage
    floprc #(32) r1W(clk,rst,flushW,aluoutM,aluoutW);
	floprc #(32) r2W(clk,rst,flushW,readdataM,readdataW);
	floprc #(5) r3W(clk,rst,flushW,writeregM,writeregW);
	
	
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
	cp0_reg cp0reg(
		.clk(clk),  
		.rst(rst),
		.we_i(cp0weM),
		.waddr_i(rdM),
		.raddr_i(rdM),
		.data_i(srcbM),
		.int_i(0),
		.excepttype_i(excepttype_i),
		.current_inst_addr_i(pcM),
		.is_in_delayslot_i(branchjumpM),
		.bad_addr_i(bad_addr_i),
		.data_o(cp0out_data),
		.count_o(count_o),
		.compare_o(compare_o),
		.status_o(status_o),
		.cause_o(cause_o),
		.epc_o(epc_o),
		.config_o(config_o),
		.prid_o(prid_o),
		.badvaddr(badvaddr),
		.timer_int_o(timer_int_o)
		);
endmodule

