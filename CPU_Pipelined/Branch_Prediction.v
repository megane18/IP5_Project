// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 20.1.1 Build 720 11/11/2020 SJ Lite Edition"
// CREATED		"Tue Jan 21 10:49:37 2025"

module Branch_Prediction(
	Taken,
	DelaySlot,
	IDA,
	IDB,
	IDop,
	IFop,
	Fix,
	Pick
);


input wire	Taken;
input wire	DelaySlot;
input wire	[31:0] IDA;
input wire	[31:0] IDB;
input wire	[31:26] IDop;
input wire	[31:26] IFop;
output wire	Fix;
output wire	[1:0] Pick;

wire	FixMUXOut;
wire	Ground;
wire	IDAeqIDB;
wire	IDAnoteqIDB;
wire	IDopisnotATakenBranch;
wire	IDopisTakenBranch;
wire	IFopisBEQorJandNoFix;
wire	IFopisBranch;
wire	IFopisBranchorIDisNotTakenBranch;
wire	IFopisJandNOTaNOTTakenBranch;
wire	IFopisJandNOTaTakenBranch;
wire	IFopJ;
wire	isNotTakenBranch;
wire	isTakenBranch2;
wire	NOTaNotTakenBranch;
wire	[1:0] S;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_7;
wire	SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;





BEQ	b2v_BEQ1(
	.Op(IFop),
	.Y(SYNTHESIZED_WIRE_5));


BEQ	b2v_BEQ2(
	.Op(IDop),
	.Y(SYNTHESIZED_WIRE_10));


MUX2	b2v_DelaySlotMUX(
	.S(DelaySlot),
	.A(FixMUXOut),
	.B(Ground),
	.Y(Fix));


EQ_32	b2v_EQ_checker(
	.A(IDA),
	.B(IDB),
	.Y(IDAeqIDB));


MUX2	b2v_FixMUX(
	.S(Taken),
	.A(isTakenBranch2),
	.B(isNotTakenBranch),
	.Y(FixMUXOut));

assign	IDopisnotATakenBranch =  ~IDopisTakenBranch;


BNE	b2v_inst1(
	.Op(IFop),
	.Y(SYNTHESIZED_WIRE_4));

assign	IDAnoteqIDB =  ~IDAeqIDB;

assign	IFopisJandNOTaTakenBranch = IFopJ & IDopisnotATakenBranch;

assign	IFopisJandNOTaNOTTakenBranch = IFopJ & NOTaNotTakenBranch;

assign	SYNTHESIZED_WIRE_6 = SYNTHESIZED_WIRE_10 & IDAeqIDB;

assign	SYNTHESIZED_WIRE_8 = SYNTHESIZED_WIRE_10 & IDAnoteqIDB;

assign	IFopisBranchorIDisNotTakenBranch = isNotTakenBranch | IFopisBranch;

assign	IFopisBEQorJandNoFix = IFopisBranch | IFopisJandNOTaNOTTakenBranch;

assign	SYNTHESIZED_WIRE_7 = SYNTHESIZED_WIRE_11 & IDAnoteqIDB;

assign	NOTaNotTakenBranch =  ~isNotTakenBranch;

assign	SYNTHESIZED_WIRE_9 = SYNTHESIZED_WIRE_11 & IDAeqIDB;

assign	IFopisBranch = SYNTHESIZED_WIRE_4 | SYNTHESIZED_WIRE_5;


BNE	b2v_inst4(
	.Op(IDop),
	.Y(SYNTHESIZED_WIRE_11));

assign	IDopisTakenBranch = SYNTHESIZED_WIRE_6 | SYNTHESIZED_WIRE_7;

assign	isNotTakenBranch = SYNTHESIZED_WIRE_8 | SYNTHESIZED_WIRE_9;



J	b2v_J1(
	.Op(IFop),
	.Y(IFopJ));


MUX2	b2v_pickMUX(
	.S(Taken),
	.A(IFopisJandNOTaTakenBranch),
	.B(IFopisBEQorJandNoFix),
	.Y(S[1]));


MUX2	b2v_S0MUX(
	.S(Taken),
	.A(IDopisTakenBranch),
	.B(IFopisBranchorIDisNotTakenBranch),
	.Y(S[0]));


SameBit	b2v_sameBit(
	.Ain(IDopisTakenBranch),
	.Aout(isTakenBranch2));

assign	Pick = S;
assign	Ground = 0;

endmodule
