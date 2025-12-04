#include "gtest/gtest.h"
#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

class decode_topTest : public ::testing::Test {
public:
    Vdut* dut;

protected:
    virtual void SetUp() override {
        dut = new Vdut;

        Verilated::traceEverOn(true);
        auto tfp = new VerilatedVcdC;
        dut->trace(tfp, 99);
        tfp->open("waveform.vcd");

        dut->rst = 1;
        dut->clk = 0;
        dut->Instr = 0;
        dut->WD3 = 0;
        dut->Zero = 0;
        dut->negative = 0;
        evaluate();
        clockTick();
        dut->rst = 0;
        evaluate();
    }

    virtual void TearDown() override {
        delete dut;
    }

    void evaluate() {
        dut->eval();
    }

    void clockTick() {
        dut->clk = 1;
        evaluate();
        dut->clk = 0;
        evaluate();
    }
};

TEST_F(decode_topTest, ResetTest) {
    dut->rst = 1;
    clockTick();
    dut->rst = 0;

    EXPECT_EQ(dut->PCSrc, 0);
    EXPECT_EQ(dut->ResultSrc, 0);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->ALUControl, 0);
    EXPECT_EQ(dut->ALUSrc, 0);
    EXPECT_EQ(dut->RD1, 0);
    EXPECT_EQ(dut->RD2, 0);
    EXPECT_EQ(dut->ImmExt, 0);
}

TEST_F(decode_topTest, InstructionDecoding) {
    dut->Instr = 0x001000B3;  // add x1, x0, x1
    evaluate();

    EXPECT_EQ(dut->ALUSrc, 0);
    EXPECT_EQ(dut->MemWrite, 0);
}

TEST_F(decode_topTest, ImmediateExtension) {
    dut->Instr = 0x00500113;  // addi x1, x0, 5
    evaluate();

    EXPECT_EQ(dut->ImmExt, 0x5);
}

TEST_F(decode_topTest, ALUOperations) {
    dut->Instr = 0x004000B3; // add x1, x0, x1 (x1 = 0 + 0)
    dut->WD3 = 0;
    evaluate();
    clockTick();

    dut->Instr = 0x40410133; // sub x2, x2, x1 (x2 = 0 - 0)
    dut->WD3 = 0;
    evaluate();
    clockTick();

    dut->Instr = 0x0011A193; // xori x3, x3, 1 (x3 = x3 ^ 1)
    dut->WD3 = 1;
    evaluate();
    clockTick();

    dut->Instr = 0x0021A213; // ori x4, x4, 2 (x4 = x4 | 2)
    dut->WD3 = 2;
    evaluate();
    clockTick();

    dut->Instr = 0x0031A393; // andi x5, x5, 3 (x5 = x5 & 3)
    dut->WD3 = 3;
    evaluate();
    clockTick();

    EXPECT_EQ(dut->RD1, 3);
}

TEST_F(decode_topTest, MemoryAccessOperations) {
    dut->Instr = 0x00002003; // lb x4, 0(x0) (load byte from memory at x0+0 into x4)
    dut->WD3 = 0xFF; // Assume memory[0] = 0xFF
    evaluate();
    clockTick();

    dut->Instr = 0x00412023; // sb x4, 4(x2) (store byte x4 at memory[x2+4])
    evaluate();
    clockTick();

    EXPECT_EQ(dut->RD1, 0xFF);
    EXPECT_EQ(dut->MemWrite, 1);
}

TEST_F(decode_topTest, BranchInstructions) {
    dut->Instr = 0x00018663; // beq x3, x0, offset=12 (branch if x3 == x0)
    dut->Zero = 1; // Assume x3 == x0
    evaluate();
    EXPECT_EQ(dut->PCSrc, 1);

    dut->Instr = 0x0011C063; // bne x3, x1, offset=16 (branch if x3 != x1)
    dut->Zero = 0; // Assume x3 != x1
    evaluate();
    EXPECT_EQ(dut->PCSrc, 1);
}

TEST_F(decode_topTest, ImmediateInstructions) {
    dut->Instr = 0x000000B7; // lui x1, 0x1 (load upper immediate into x1)
    dut->WD3 = 0x1000;
    evaluate();
    clockTick();

    dut->Instr = 0x00100197; // auipc x3, 0x1 (x3 = PC + 0x1000)
    dut->WD3 = 0x1000; 
    evaluate();
    clockTick();

    EXPECT_EQ(dut->RD1, 0x1000);
}

TEST_F(decode_topTest, ShiftOperations) {
    dut->Instr = 0x001081B3; // sll x3, x1, x2 (x3 = x1 << x2)
    dut->WD3 = 0;
    evaluate();
    clockTick();

    dut->Instr = 0x0010A1B3; // srl x3, x1, x2 (x3 = x1 >> x2)
    dut->WD3 = 0;
    evaluate();
    clockTick();

    dut->Instr = 0x4010A1B3; // sra x3, x1, x2 (x3 = x1 >>> x2)
    dut->WD3 = 0;
    evaluate();
    clockTick();

    EXPECT_EQ(dut->RD1, 0);
}

TEST_F(decode_topTest, ComprehensiveControlUnitVerification) {
    dut->Instr = 0x00400093; // addi x1, x0, 4
    dut->WD3 = 4;
    evaluate();
    clockTick();

    EXPECT_EQ(dut->ALUControl, 0x0); // ALU should perform addition
    EXPECT_EQ(dut->ALUSrc, 1);       // Immediate value should be selected

    dut->Instr = 0x00018663; // beq x3, x0, offset=12
    dut->Zero = 1;
    evaluate();

    EXPECT_EQ(dut->PCSrc, 1);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}