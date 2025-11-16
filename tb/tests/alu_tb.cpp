/*
 *  Verifies the results of the ALU module.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ALUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->ALUop1 = 0;
        top->ALUop2 = 0;
        top->ALUctrl = 0;
    }
};

TEST_F(ALUTestbench, AddBasic)
{
    top->ALUop1 = 5;
    top->ALUop2 = 3;
    top->ALUctrl = 1; // ADD
    top->eval();
    EXPECT_EQ(top->ALUout, 8);
}

TEST_F(ALUTestbench, SubBasic)
{
    top->ALUop1 = 10;
    top->ALUop2 = 4;
    top->ALUctrl = 2; // SUB
    top->eval();
    EXPECT_EQ(top->ALUout, 6);
}

TEST_F(ALUTestbench, ZeroFlagWorks)
{
    top->ALUop1 = 7;
    top->ALUop2 = 7;
    top->ALUctrl = 2; // SUB (7-7=0)
    top->eval();
    EXPECT_EQ(top->EQ, 1);
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
