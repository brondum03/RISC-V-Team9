/*
 *  Verifies the results of the ALU module.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

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
class ALUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override {
        top->ALUop1 = 0;
        top->ALUop2 = 0;
        top->ALUctrl = 0;
    }
};

TEST_F(ALUTestbench, AddBasic)
{
    top->ALUop1 = 5;
    top->ALUop2 = 3;
    top->ALUctrl = ADD;
    top->eval();
    EXPECT_EQ(top->ALUout, 8);
}

TEST_F(ALUTestbench, SubBasic)
{
    top->ALUop1 = 10;
    top->ALUop2 = 4;
    top->ALUctrl = SUB;
    top->eval();
    EXPECT_EQ(top->ALUout, 6);
}

TEST_F(ALUTestbench, ZeroFlagWorks)
{
    top->ALUop1 = 7;
    top->ALUop2 = 7;
    top->ALUctrl = SUB;
    top->eval();
    EXPECT_EQ(top->Zero, 1);
}

TEST_F(ALUTestbench, AndOperation)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = AND;
    top->eval();
    EXPECT_EQ(top->ALUout, 0b1000);
}

TEST_F(ALUTestbench, OrOperation)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = ORR;
    top->eval();
    EXPECT_EQ(top->ALUout, 0b1110);
}

TEST_F(ALUTestbench, XorOperation)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = XORR;
    top->eval();
    EXPECT_EQ(top->ALUout, 0b0110);
}

TEST_F(ALUTestbench, SllOperation)
{
    top->ALUop1 = 1;
    top->ALUop2 = 3;
    top->ALUctrl = SLL;
    top->eval();
    EXPECT_EQ(top->ALUout, 8);
}

TEST_F(ALUTestbench, SrlOperation)
{
    top->ALUop1 = 0b1000;
    top->ALUop2 = 3;
    top->ALUctrl = SRL;
    top->eval();
    EXPECT_EQ(top->ALUout, 0b0001);
}

TEST_F(ALUTestbench, SraOperation)
{
    top->ALUop1 = int32_t(0xF0000000);  // negative number
    top->ALUop2 = 4;
    top->ALUctrl = SRA;
    top->eval();
    EXPECT_EQ(top->ALUout, 0xFF000000); // arithmetic shift
}

TEST_F(ALUTestbench, SltTrue)
{
    top->ALUop1 = -8;
    top->ALUop2 = 5;
    top->ALUctrl = SLT;
    top->eval();
    EXPECT_EQ(top->ALUout, 1);
}

TEST_F(ALUTestbench, SltFalse)
{
    top->ALUop1 = 7;
    top->ALUop2 = 2;
    top->ALUctrl = SLT;
    top->eval();
    EXPECT_EQ(top->ALUout, 0);
}

TEST_F(ALUTestbench, SltuTrue)
{
    top->ALUop1 = 3;
    top->ALUop2 = 5;
    top->ALUctrl = SLTU;
    top->eval();
    EXPECT_EQ(top->ALUout, 1);
}

TEST_F(ALUTestbench, SltuFalse)
{
    top->ALUop1 = 15;
    top->ALUop2 = 2;
    top->ALUctrl = SLTU;
    top->eval();
    EXPECT_EQ(top->ALUout, 0);
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
