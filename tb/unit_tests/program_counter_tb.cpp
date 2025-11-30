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
        top->PCNext = 0;
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

    top->PCNext = 4;
    runSimulation(1);
    EXPECT_EQ(top->out, 4);

    // Cycle 3: PC = 8
    top->PCNext = 8;
    runSimulation(1);
    EXPECT_EQ(top->out, 8);

    // Cycle 4: PC = 12
    top->PCNext = 12;
    runSimulation(1);
    EXPECT_EQ(top->out, 12);
}


TEST_F(PCTestbench, JumpTest)
{
    top->rst = 0;
    top->PCNext = 100;
    runSimulation(1);
    EXPECT_EQ(top->out, 100);
}

TEST_F(PCTestbench, SequentialUpdates)
{
    top->rst = 0;

    top->PCNext = 10;
    runSimulation(1);
    EXPECT_EQ(top->out, 10);

    top->PCNext = 20;
    runSimulation(1);
    EXPECT_EQ(top->out, 20);

    top->PCNext = 21;
    runSimulation(1);
    EXPECT_EQ(top->out, 21);
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