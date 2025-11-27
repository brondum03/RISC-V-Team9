/*
 *  Verifies the results of the data memory module.
 */

#include "testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class DataMemTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->WE = 0;
        top->WD = 0;
        top->A = 0;
        // output: RD
    }
};

TEST_F(DataMemTestbench, ReadDefault)
{
    top->A = 1;

    runSimulation(1);

    EXPECT_EQ(top->RD, 0);
}

TEST_F(DataMemTestbench, WriteandRead)
{
    top->WE = 1;
    top->A = 2;
    top->WD = 0xABCDEF1;
    
    runSimulation(1);

    top->WE = 0;
    runSimulation(1);

    EXPECT_EQ(top->RD, 0xABCDEF1);
}

TEST_F(DataMemTestbench, Overwrite)
{
    // initial write
    top->WE = 1;
    top->A = 3;
    top->WD = 0xAAAAAAAA;
    runSimulation(1);

    // overwrite initial written data
    top->A = 3;
    top->WD = 0xBBBBBBBB;
    runSimulation(1);

    // read data
    top->WE = 0;
    top->A = 3;
    runSimulation(1);

    EXPECT_EQ(top->RD, 0xBBBBBBBB);

}

TEST_F(DataMemTestbench, AsyncReadDuringWrite)
{
    // write to address 1
    top->WE = 1;
    top->A = 1;
    top->WD = 0x11111111;
    runSimulation(1);

    // write to address 2
    top->WE = 1;
    top->A = 2;
    top->WD = 0x22222222;
    runSimulation(1);

    top->WE = 0;
    top->A = 1;
    top->eval();
    EXPECT_EQ(top->RD, 0x11111111);

    top->A = 2;
    top->eval();
    EXPECT_EQ(top->RD, 0x22222222);
}

TEST_F(DataMemTestbench, NoWriteWhenWEis0)
{
    top->WE = 1;
    top->A = 7;
    top->WD = 0x12345678;
    runSimulation(1);

    // when WE = 0, WD should not be written
    top->WE = 0;
    top->A = 7;
    top->WD = 0xFFFFFFFF;
    runSimulation(1);

    EXPECT_EQ(top->RD, 0x12345678);
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