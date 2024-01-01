module hazard(
    output wire [31:0]newPC,
	//fetch stage
	output wire stallF,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire [5:0]alucontrolE,
	input wire [3:0] branchD,
	output wire forwardaD,forwardbD,
	output wire stallD,
	output wire stallE,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,

	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	input wire isJRD,isJALRD,
	input wire div_ready,
	input wire[31:0] exception_type,
	input wire overflowM,
	input wire [31:0] epc,
	output wire flushF,
	output wire flushD,
	output wire flushM,
	output wire flushW
    );

	wire lwstallD,branchstallD,stall_divD;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	 assign newPC = (exception_type == 32'h0000_0001)? 32'hbfc00380:
                   (exception_type == 32'h0000_0004)? 32'hbfc00380:
                   (exception_type == 32'h0000_0005)? 32'hbfc00380:
                   (exception_type == 32'h0000_0008)? 32'hbfc00380:
                   (exception_type == 32'h0000_0009)? 32'hbfc00380:
                   (exception_type == 32'h0000_000a)? 32'hbfc00380:
                   (exception_type == 32'h0000_000c)? 32'hbfc00380:
                   (exception_type == 32'h0000_000e)? epc:
                   32'b0;
	assign stall_divE = ((alucontrolE==6'b011100|alucontrolE==6'b001100) & ~div_ready);
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign jumpstallD = (isJALRD | isJRD) & 
			(regwriteE & 				// §Õ????????????Ex??¦²?branch???????????????
			(writeregE == rsD | writeregE == rtD) |
			memtoregM &					// ??mem??§Õ?????????Mem??¦²?branch????????????Mem??????
			(writeregM == rsD | writeregM == rtD));
	assign branchstallD = (branchD[3]|branchD[2]|branchD[1]| branchD[0]) &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign #1 stallD = stallE | ((lwstallD | branchstallD| jumpstallD)) ;
	assign #1 stallF = stallD | (lwstallD | branchstallD| jumpstallD) ;
	assign stallE =    stall_divE;
	
		//stalling D stalls all previous stages
	assign #1 flushE = ((lwstallD | branchstallD | jumpstallD) & ~stallE);
	assign    flushF = 1'b0;
	assign    flushD=(exception_type!=0);
	assign    flushM=(exception_type!=0);
	assign    flushW=(exception_type!=0);
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule