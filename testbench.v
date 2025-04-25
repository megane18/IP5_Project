///////////////////////////////////////////////////////////////////////////////////
// Testbench for Component: CPU_Pipelined (CLK=100)
// Package: FIUSCIS-CDA
// Course: CDA3102 (Computer Architecture), Florida International University
// Developer: Trevor Cickovski
// Extended By: CDA3102 students
// License: MIT, (C) 2020-2022 All Rights Reserved
///////////////////////////////////////////////////////////////////////////////////

module testbench();
`include "../Test/Test.v"
///////////////////////////////////////////////////////////////////////////////////
// Inputs: clk, reset (1-bit)
   reg clk, rst;
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
// Outputs: PC (32-bit), IFIR (6-bit), IDIR (6-bit), EXIR (6-bit), MEMIR (6-bit), WBIR (6-bit)
   wire[31:0] PC, IFIR, IDIR, EXIR, MEMIR, WBIR;
///////////////////////////////////////////////////////////////////////////////////////////////

   integer i;  // Define integer for loops
   reg case1_passed, case2_passed; // Test case status flags
   reg case1_checked, case2_checked; // Test case tracking flags

///////////////////////////////////////////////////////////////////////////////////
// Component is CLOCKED
// Set clk period to 100 in wave
// Approximating clock period as 100 (one access to RAM)
localparam CLK_PERIOD=100;
///////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Use a smaller terminal PC value since we have a shorter program
localparam TERMINALPC=60;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Branch prediction strategy
// 00=NOT TAKEN 
// 01=TAKEN 
// 10=DELAY SLOT (works if the program uses delay slots - the bubble sort below does not)  
localparam BRANCH_PRED=2'b00;
////////////////////////////////////////////////////////////////////////////////////////////////////

 
CPU_Pipelined myCPU(.clk(clk), .reset(rst), .Strategy(BRANCH_PRED), .EXIR(EXIR), 
                       .IDIR(IDIR), .IFIR(IFIR), .MEMIR(MEMIR), .PC(PC), .WBIR(WBIR)); 
   
initial begin
   // Initialize test case flags
   case1_passed = 0;
   case2_passed = 0;
   case1_checked = 0;
   case2_checked = 0;

   // Clear all memory locations first to avoid X values
   for (i = 0; i < 64; i = i + 1) begin
      myCPU.b2v_IFStage.b2v_MYIM.memory[i] = 32'b0;
   end
   
   ////////////////////////////////////////////////////////////////////////////////
   // Improved BGEZ Test Program with enough NOPs to handle pipeline delays
   ////////////////////////////////////////////////////////////////////////////////

   // Case 1: rs >= 0 (should take the branch)
   myCPU.b2v_IFStage.b2v_MYIM.memory[0] = 32'b00100000000010000000000000000001; // addi $t0, $zero, 1
   myCPU.b2v_IFStage.b2v_MYIM.memory[1] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[2] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[3] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[4] = 32'b00000101000000010000000000000010; // bgez $t0, +2
   myCPU.b2v_IFStage.b2v_MYIM.memory[5] = 32'b00100000000100100000000000000001; // addi $s2, $zero, 1 (skipped if branch taken)
   myCPU.b2v_IFStage.b2v_MYIM.memory[6] = 32'b00100000000100110000000000000001; // addi $s3, $zero, 1

   // Case 2: rs < 0 (should NOT take the branch)
   myCPU.b2v_IFStage.b2v_MYIM.memory[8] = 32'b00100000000010001111111111111111; // addi $t0, $zero, -1
   myCPU.b2v_IFStage.b2v_MYIM.memory[9] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[10] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[11] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[12] = 32'b00000101000000010000000000000010; // bgez $t0, +2
   myCPU.b2v_IFStage.b2v_MYIM.memory[13] = 32'b00100000000101000000000000000010; // addi $s4, $zero, 2 (should execute)
   myCPU.b2v_IFStage.b2v_MYIM.memory[14] = 32'b00100000000101010000000000000010; // addi $s5, $zero, 2
   
   // End program with NOP
   myCPU.b2v_IFStage.b2v_MYIM.memory[15] = 32'b00000000000000000000000000000000; // nop

   // Power on with longer reset period
   rst = 1;  
   #(CLK_PERIOD*2); // Hold reset for 2 clock cycles
   rst = 0;
end

always begin
   clk = 0; #(CLK_PERIOD/2);
   clk = 1; #(CLK_PERIOD/2);
end

// Enhanced Debug Monitoring without direct register file access
// Enhanced Debug Monitoring without direct register file access
always @(posedge clk) begin
   // Print register values from r1d (register value used by branch decision)
   $display("Time=%0t, PC=%d, Instruction=%h", $time, PC, IFIR);
   $display("BranchGEZ=%b, BranchGEZTaken=%b, rs[31]=%b (rs value=%d)", 
            myCPU.b2v_IDStage.BranchGEZ,
            myCPU.b2v_IDStage.BranchGEZTaken,
            myCPU.b2v_IDStage.r1d[31],
            myCPU.b2v_IDStage.r1d);
   
   // Check for Case 1: BGEZ with positive/zero number should take branch
   if (IFIR == 32'h05010002 && myCPU.b2v_IDStage.BranchGEZ == 1 && myCPU.b2v_IDStage.r1d[31] == 0) begin
      case1_checked = 1;
      if (myCPU.b2v_IDStage.BranchGEZTaken == 1) begin
         case1_passed = 1;
         $display("CASE 1 PASSED: BGEZ correctly taken when rs = %d (positive/zero)", myCPU.b2v_IDStage.r1d);
      end else begin
         $display("CASE 1 FAILED: BGEZ should be taken when rs = %d (positive/zero)", myCPU.b2v_IDStage.r1d);
      end
   end
   
   // Check for Case 2: BGEZ with negative number should NOT take branch
   if (IFIR == 32'h05010002 && myCPU.b2v_IDStage.BranchGEZ == 1 && myCPU.b2v_IDStage.r1d[31] == 1) begin
      case2_checked = 1;
      if (myCPU.b2v_IDStage.BranchGEZTaken == 0) begin
         case2_passed = 1;
         $display("CASE 2 PASSED: BGEZ correctly NOT taken when rs = %d (negative)", myCPU.b2v_IDStage.r1d);
      end else begin
         $display("CASE 2 FAILED: BGEZ should NOT be taken when rs = %d (negative)", myCPU.b2v_IDStage.r1d);
      end
   end
   
   $display("-----------------------------------------------------");
   
   // Display final summary at the end of the test
   if (PC > TERMINALPC) begin
      $display("\n\n==================================================");
      $display("               BGEZ TEST SUMMARY                  ");
      $display("==================================================");
      $display("Case 1 (Positive/Zero rs): %s", case1_passed ? "PASSED" : (case1_checked ? "FAILED" : "NOT TESTED"));
      $display("Case 2 (Negative rs): %s", case2_passed ? "PASSED" : (case2_checked ? "FAILED" : "NOT TESTED"));
      
      if (case1_passed && case2_passed)
         $display("\nSUCCESS! Your BGEZ implementation is working correctly!");
      else if (case1_passed || case2_passed)
         $display("\nPARTIAL SUCCESS - Some test cases passed, others failed or weren't properly tested.");
      else
         $display("\nFAILURE - No test cases passed!");
      
      $display("==================================================\n");
      $stop;
   end
end

endmodule