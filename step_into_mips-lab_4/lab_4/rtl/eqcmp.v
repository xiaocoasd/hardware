`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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


module eqcmp(
	input wire [31:0] a,b,
	output wire y1,
	output wire y2,
	output wire y3,
	output wire y4,
	output wire y5
    );

	assign y1 = (a == b) ? 1 : 0;
	assign y2 = ((a[31] == 1'b0) | (a == 32'b0));
	assign y3 = ((a[31] == 1'b0) & (a != 32'b0));
	assign y4 = ((a[31] == 1'b1) | (a == 32'b0));//BLEZ
	assign y5 = ((a[31] == 1'b1) & (a != 32'b0));//BLTZ
	
endmodule
