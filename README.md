**IP5 BGEZ**

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