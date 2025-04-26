///////////////////////////////////////////////////////////////////////////////////
// Testbench for Component: CPU_Pipelined (CLK=100)
///////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module testbench();
`include "../Test/Test.v"

reg clk, rst;

wire[31:0] PC, IFIR, IDIR, EXIR, MEMIR, WBIR;

integer i;
reg case1_passed, case2_passed;
reg case1_checked, case2_checked;

localparam CLK_PERIOD=100;
localparam TERMINALPC=60;
localparam BRANCH_PRED=2'b00;

CPU_Pipelined myCPU(
    .clk(clk),
    .reset(rst),
    .Strategy(BRANCH_PRED),
    .EXIR(EXIR),
    .IDIR(IDIR),
    .IFIR(IFIR),
    .MEMIR(MEMIR),
    .PC(PC),
    .WBIR(WBIR)
);

initial begin
   case1_passed = 0;
   case2_passed = 0;
   case1_checked = 0;
   case2_checked = 0;

   for (i = 0; i < 64; i = i + 1) begin
      myCPU.b2v_IFStage.b2v_MYIM.memory[i] = 32'b0;
   end
   
   // Program memory initialization
   myCPU.b2v_IFStage.b2v_MYIM.memory[0] = 32'b00100000000010000000000000000001; // addi $t0, $zero, 1
   myCPU.b2v_IFStage.b2v_MYIM.memory[1] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[2] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[3] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[4] = 32'b00000101000000010000000000000010; // bgez $t0, +2
   myCPU.b2v_IFStage.b2v_MYIM.memory[5] = 32'b00100000000100100000000000000001; // addi $s2, $zero, 1
   myCPU.b2v_IFStage.b2v_MYIM.memory[6] = 32'b00100000000100110000000000000001; // addi $s3, $zero, 1

   myCPU.b2v_IFStage.b2v_MYIM.memory[8] = 32'b00100000000010001111111111111111; // addi $t0, $zero, -1
   myCPU.b2v_IFStage.b2v_MYIM.memory[9] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[10] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[11] = 32'b00000000000000000000000000000000; // nop
   myCPU.b2v_IFStage.b2v_MYIM.memory[12] = 32'b00000101000000010000000000000010; // bgez $t0, +2
   myCPU.b2v_IFStage.b2v_MYIM.memory[13] = 32'b00100000000101000000000000000010; // addi $s4, $zero, 2
   myCPU.b2v_IFStage.b2v_MYIM.memory[14] = 32'b00100000000101010000000000000010; // addi $s5, $zero, 2

   myCPU.b2v_IFStage.b2v_MYIM.memory[15] = 32'b00000000000000000000000000000000; // nop

   rst = 1;  
   #(CLK_PERIOD*2); 
   rst = 0;
end

always begin
   clk = 0; #(CLK_PERIOD/2);
   clk = 1; #(CLK_PERIOD/2);
end

// Variables to track BGEZ instructions in the pipeline
reg bgez_found_positive = 0;
reg bgez_found_negative = 0;

// MAIN TEST MONITOR
always @(posedge clk) begin
   $display("Time=%0t, PC=%d, IFIR=%h, IDIR=%h", $time, PC, IFIR, IDIR);
   $display("BranchGEZ=%b, BranchGEZTaken=%b, rs[31]=%b (rs value=%d)", 
            myCPU.b2v_IDStage.BranchGEZ,
            myCPU.b2v_IDStage.BranchGEZTaken,
            myCPU.b2v_IDStage.r1d[31],
            myCPU.b2v_IDStage.ReadData1);
   
   // Case 1: When BranchGEZ is active, register is NOT negative (rs[31]=0), and BranchGEZTaken is 1
if (myCPU.b2v_IDStage.BranchGEZ == 1 && myCPU.b2v_IDStage.r1d[31] == 0 && myCPU.b2v_IDStage.BranchGEZTaken == 1) begin
   case1_checked = 1;
   case1_passed = 1;
   $display("CASE 1 PASSED: BGEZ correctly taken when rs = %d (positive/zero)", 
          myCPU.b2v_IDStage.ReadData1);
end

// Case 2: When we're executing the BGEZ instruction with a negative value
if (IDIR == 32'h05010002 && myCPU.b2v_IDStage.r1d[31] == 1 && myCPU.b2v_IDStage.BranchGEZTaken == 0) begin
   case2_checked = 1;
   case2_passed = 1;
   $display("CASE 2 PASSED: BGEZ correctly NOT taken when rs = %d (negative)", 
          myCPU.b2v_IDStage.ReadData1);
end
   
   $display("-----------------------------------------------------");
   
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