**IP5 BGEZ**

Who Participated
##

**Megane Alexis, Huong Huynh, Volreka Senatus, Nicholas Ulloa, Santiago Defelice**


*Volreka, Nicholas and Santiago's changes can be found on the PC-Logic branch*

*Megane and Huong's changes are on the main branch*

##
**PART 1: CONTROL LOGIC - BGEZ Instruction Detecion**

**Objective**:
To detect the BGEZ instruction (opcode == 000001 and rt == 00001) in the Instruction Decode (ID) stage and output a new control signal: BranchGEZ.

**Implementation Overview**:
The id.bdf schematic was modified to include two custom comparator blocks and an AND gate that together detect the presence of the BGEZ instruction. The signal BranchGEZ is asserted only when both conditions are met:

The instruction's opcode field (Instruction[31:26]) is equal to 000001

The rt field (Instruction[20:16]) is equal to 00001

**Components Used**:
cmp_opcode_eq: A 6-bit comparator generated via the Quartus MegaWizard. It compares the opcode to a constant value of 1 (binary 000001).

cmp_rt_eq: A 5-bit comparator that compares the rt field to a constant value of 1 (binary 00001).

and2 gate: Combines the outputs of both comparators to produce the control signal BranchGEZ.

**Signal Flow**:
Instruction[31:26] is routed to cmp_opcode_eq and checked against constant 1.

Instruction[20:16] is routed to cmp_rt_eq and also checked against constant 1.

The outputs of both comparators (opcodeIsREGIMM and rtIsBGEZ) are fed into an AND gate.

The result, labeled BranchGEZ, is routed out of the ID stage for use in later pipeline stages.

# Component that was modified for this
**The ID of the CPU_Pipeline**
## To see the changes, go to the screenshots folder

**NEXT STEPS**
Use the modified components, modified_ID.bdf to finish the necessary part.

**Part 2: Datapath Logic - BranchGEZTaken Signal**

**Objective:**
To complete the BGEZ instruction logic by checking if the rs register value is greater than or equal to 0, and output a new control signal BranchGEZTaken that is asserted only when the branch should actually be taken.

**Implementation Overview:**
The datapath was extended in the id.bdf schematic to include logic for detecting whether the sign bit of the rs register is 0 (i.e., rs >= 0). This signal is then combined with the BranchGEZ signal (generated in Part 1) to determine the final branch decision: BranchGEZTaken.

**Signal Logic:**
The output of the register file corresponding to rs (r1d[31:0]) is tapped at bit 31, representing the sign bit.

A NOT gate inverts this sign bit to create the signal isRsPositive, which is 1 when rs >= 0.

An AND2 gate combines isRsPositive and BranchGEZ to form the final signal:


*BranchGEZTaken = BranchGEZ AND (r1d[31] == 0)*


## To see the changes, go to the screenshots folder

**Next Steps:**
In the next stage, BranchGEZTaken will be routed into the PC logic to influence whether the PC is updated to the branch target address or not.

**Huong test for Part 1 and 2**

We modified the testbench.v file so that it can test for compomnent 1 and 2 where both cases - positive and negative, passed. The **BGEZ** and **BranchGEZTaken signal** are working.

*The results can be viewed via the Screenshots folder.*

**Next Steps:**
We are waiting for the PC to be done to proceed a full testing of the entire BGEZ implementation.


**We were able ale to complete part 1 and part 2 which is to be able to detect BGEZ signal and know when it is taken**
**We took inspiration from the professor's testbench to create our own testbench that will test part 1 and part 2 and these can be verified under the CPU_Pipelined, Screenshots and Tests_for_part1npart2 folders**
**We stopped at part 3 like wiring the new ID in the CPU_Pipelined, we were unable to do so, as it would leave some input with no wire and cause errors when we compile**

