#include "../base_testbench.h"
#include "Vdut.h"
#include "verilated_vcd_c.h"

Vdut* top;
VerilatedVcdC* tfp;
unsigned int ticks = 0;

class ExecuteTB : public BaseTestbench {
protected:
    void initializeInputs() override {
        top->RD1 = 0;
        top->RD2 = 0;
        top->ImmExt = 0;
        top->ALUControl = 0;
        top->ALUSrc = 0;
    }
};

// ==== ALUCONTROL codes (match your ALU RTL) ====
enum {
    ADD  = 0b0000,
    SUB  = 0b0001,
    AND  = 0b0010,
    ORR  = 0b0011,
    XORR = 0b0100,
    SLL  = 0b0101,
    SRL  = 0b0110,
    SRA  = 0b0111,
    SLT  = 0b1000,
    SLTU = 0b1001
};

// ======================================================
//                        TESTS
// ======================================================

TEST_F(ExecuteTB, RegisterAdd) {
    top->RD1 = 5;
    top->RD2 = 7;
    top->ALUSrc = 0;       // use RD2
    top->ALUControl = ADD;

    top->eval();
    EXPECT_EQ(top->ALUResult, 12);
    EXPECT_EQ(top->WriteData, 7);  // pass-through
}

TEST_F(ExecuteTB, ImmAdd) {
    top->RD1 = 10;
    top->ImmExt = 3;
    top->ALUSrc = 1;       // use imm
    top->ALUControl = ADD;

    top->eval();
    EXPECT_EQ(top->ALUResult, 13);
}

TEST_F(ExecuteTB, Subtract) {
    top->RD1 = 20;
    top->RD2 = 8;
    top->ALUSrc = 0;
    top->ALUControl = SUB;

    top->eval();
    EXPECT_EQ(top->ALUResult, 12);
    EXPECT_EQ(top->Zero, 0);
}

TEST_F(ExecuteTB, ZeroFlagWorks) {
    top->RD1 = 10;
    top->RD2 = 10;
    top->ALUSrc = 0;
    top->ALUControl = SUB;

    top->eval();
    EXPECT_EQ(top->Zero, 1);
}

TEST_F(ExecuteTB, NegativeFlagWorks) {
    top->RD1 = 5;
    top->RD2 = 10;
    top->ALUSrc = 0;
    top->ALUControl = SUB;

    top->eval();
    EXPECT_EQ(top->Negative, 1);
}

TEST_F(ExecuteTB, AndOperation) {
    top->RD1 = 0b1100;
    top->RD2 = 0b1010;
    top->ALUSrc = 0;
    top->ALUControl = AND;

    top->eval();
    EXPECT_EQ(top->ALUResult, 0b1000);
}

TEST_F(ExecuteTB, ShiftLeftLogical) {
    top->RD1 = 1;
    top->RD2 = 3;
    top->ALUSrc = 0;
    top->ALUControl = SLL;

    top->eval();
    EXPECT_EQ(top->ALUResult, 8);
}

TEST_F(ExecuteTB, ShiftRightArithmetic) {
    top->RD1 = int32_t(0xF0000000);   // negative value
    top->RD2 = 4;
    top->ALUSrc = 0;
    top->ALUControl = SRA;

    top->eval();
    EXPECT_EQ(top->ALUResult, int32_t(0xFF000000));
}

TEST_F(ExecuteTB, ImmXor) {
    top->RD1 = 0b1010;
    top->ImmExt = 0b1100;
    top->ALUSrc = 1;
    top->ALUControl = XORR;

    top->eval();
    EXPECT_EQ(top->ALUResult, 0b0110);
}

int main(int argc, char** argv) {
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("execute.vcd");

    testing::InitGoogleTest(&argc, argv);
    int res = RUN_ALL_TESTS();

    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return res;
}
