/*
 *  Verifies the results of the program counter module.
 */

#include "testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class PCTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;
        top->pcsrc = 0;
        top->immOP = 0;
        // output: out
    }
};

TEST_F(PCTestbench, ResetTest)
{
    top->rst = 1;
    
    runSimulation(1);

    EXPECT_EQ(top->out, 0);
}

TEST_F(PCTestbench, IncrementBy4)
{
    // First cycle: rst=1 makes PC=0
    top->rst = 1;
    runSimulation(1);
    EXPECT_EQ(top->out, 0);

    // Now release reset
    top->rst = 0;

    // Cycle 2: PC = 4
    runSimulation(1);
    EXPECT_EQ(top->out, 4);

    // Cycle 3: PC = 8
    runSimulation(1);
    EXPECT_EQ(top->out, 8);

    // Cycle 4: PC = 12
    runSimulation(1);
    EXPECT_EQ(top->out, 12);
}

TEST_F(PCTestbench, BranchTest)
{

    top->pcsrc = 1;
    top->immOP = 8;

    runSimulation(1);
    EXPECT_EQ(top->out, 8);
}

TEST_F(PCTestbench, MixedBranchAndIncrement)
{
    top->rst = 0;

    // branch
    top->pcsrc = 1;
    top->immOP = 12;
    runSimulation(1);
    EXPECT_EQ(top->out, 12);

    // normal increment
    top->pcsrc = 0;
    runSimulation(1);
    EXPECT_EQ(top->out, 16);
}

TEST_F(PCTestbench, UpdateOnClockEdge)
{
    top->rst = 0;

    top->pcsrc = 0;
    runSimulation(1);
    EXPECT_EQ(top->out, 4);

    top->pcsrc = 1;
    top->immOP = 20;

    // No eval yet → still 4
    EXPECT_EQ(top->out, 4);

    runSimulation(1);
    EXPECT_EQ(top->out, 24);
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
