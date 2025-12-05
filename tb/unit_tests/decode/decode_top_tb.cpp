/*
 *  Verifies the behaviour of decode_top.sv.
 */

#include "../testbench.h"
#include "gtest/gtest.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class DecodeTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;

        top->trigger = 0;
        top->InstrD = 0;
        top->PCD = 0;
        top->PCPlus4D = 0;

        top->FlushD = 0;
        top->FlushE = 0;

        top->RegWriteW = 0;
        top->ResultW = 0;
        top->RdW = 0;
    }

    void loadInstr(uint32_t instr)
    {
        top->InstrD = instr;

        top->trigger = 0;

        runSimulation(1);
    }
};

TEST_F(DecodeTestbench, ResetPipeline)
{
    top->rst = 1;
    runSimulation(1);
    top->rst = 0;
    runSimulation(1);

    EXPECT_EQ(top->RegWriteE, 0);
    EXPECT_EQ(top->MemWriteE, 0);
    EXPECT_EQ(top->ALUControlE, 0);
    EXPECT_EQ(top->RD1E, 0);
    EXPECT_EQ(top->RD2E, 0);
    EXPECT_EQ(top->ImmExtE, 0);
}

// R-type add instruction
TEST_F(DecodeTestbench, DecodeAddInstruction)
{
    uint32_t add_instr = 0b0000000'00011'00010'000'00001'0110011; // add x1, x2, x3
    loadInstr(add_instr);

    EXPECT_EQ(top->ALUSrcE, 0);
    EXPECT_EQ(top->MemWriteE, 0);
    EXPECT_EQ(top->JumpE, 0);
    EXPECT_EQ(top->BranchE, 0);
}

// I-type addi instruction 
TEST_F(DecodeTestbench, DecodeImmediateADDI)
{
    loadInstr(0x00500113); // addi x1, x0, 5

    EXPECT_EQ(top->ImmExtE, 5); // immediate value
    EXPECT_EQ(top->ALUSrcE, 1); // R1 + immediate
}

// register writeback test
TEST_F(DecodeTestbench, RegisterWriteback)
{
    // write x1 = 0x12345678
    top->RegWriteW = 1;
    top->RdW = 1;
    top->ResultW = 0x12345678;
    runSimulation(2);

    top->RegWriteW = 0;

    runSimulation(1);
    
    loadInstr(0x00008033); // add x0, x1, x0, reads x1 as rs1

    EXPECT_EQ(top->RD1E, 0x12345678);
}

// flush decode pipeline
TEST_F(DecodeTestbench, FlushDecodeStage)
{
    loadInstr(0x00500113); // addi

    // flush
    top->FlushD = 1;
    runSimulation(1);
    top->FlushD = 0;

    EXPECT_EQ(top->RegWriteE, 0);
    EXPECT_EQ(top->MemWriteE, 0);
    EXPECT_EQ(top->ALUSrcE, 0);
}

// flushE
TEST_F(DecodeTestbench, FlushExecuteStage)
{
    top->FlushE = 1;
    
    loadInstr(0x000000B3); // add

    top->FlushE = 0;

    EXPECT_EQ(top->RegWriteE, 0);
    EXPECT_EQ(top->MemWriteE, 0);
    EXPECT_EQ(top->ALUControlE, 0);
}

// beq branch 
TEST_F(DecodeTestbench, DecodeBranchBEQ)
{
    loadInstr(0b0000000'00010'00001'000'00010'1100011);

    EXPECT_EQ(top->BranchE, 0b001);
}

// jal instruction
TEST_F(DecodeTestbench, DecodeJAL)
{
    loadInstr(0x000000EF); // jal x1, 0

    EXPECT_EQ(top->JumpE, 1);
}

// lw instruction
TEST_F(DecodeTestbench, DecodeLW)
{
    loadInstr(0x00002083); // lw x1, 0(x0)

    EXPECT_EQ(top->ResultSrcE, 1); // load selects memory
    EXPECT_EQ(top->ALUSrcE, 1); // immediate offset
}

// sw instruction
TEST_F(DecodeTestbench, DecodeSW)
{
    loadInstr(0x00102023); // sw x1, 0(x0)

    EXPECT_EQ(top->MemWriteE, 1);
    EXPECT_EQ(top->ALUSrcE, 1);
}


int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    int res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
