/*
 * Verifies the behaviour of execute_top.sv.
 */

#include "../testbench.h"
#include "Vdut.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ExecuteTestbench : public Testbench {
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;
        top->trigger = 0;

        top->RD1E = 0;
        top->RD2E = 0;
        top->ResultW = 0;

        top->ALUControlE = 0;
        top->ALUSrcE = 0;

        top->PCE = 0;
        top->ImmExtE = 0;
        top->PCPlus4E = 0;
        top->RdE = 0;

        top->AddressingModeE = 0;
        top->ResultSrcE = 0;
        top->RegWriteE = 0;
        top->MemWriteE = 0;

        top->Rs1E = 0;
        top->Rs2E = 0;
        top->RdW = 0;
        top->RegWriteW = 0;

        top->Rs1D = 0;
        top->Rs2D = 0;

        top->BranchE = 0;
        top->JumpE = 0;
    }

    void resetPipeline()
    {
        top->rst = 1;
        runSimulation(1);
        top->rst = 0;
        runSimulation(1);
    }
};

TEST_F(ExecuteTestbench, PipelineRegisterMovesRegWrite)
{
    resetPipeline();

    top->RegWriteE = 1;
    top->RdE = 7;

    runSimulation(1);   // move into MEM stage

    EXPECT_EQ(top->RegWriteM, 1);
    EXPECT_EQ(top->RdM, 7);
}

// alu operand A
TEST_F(ExecuteTestbench, ForwardAFromMemPipeline)
{
    resetPipeline();

    top->RD1E = 10;
    top->RD2E = 3;
    top->ALUControlE = 1;   // subtract
    top->RegWriteE = 1;
    top->RdE = 5;

    runSimulation(2);

    top->Rs1E = 5;
    top->Rs2E = 0;
    top->RD1E = 123;   // stale
    top->RD2E = 0;
    top->ALUControlE = 0;   // add

    runSimulation(2);

    EXPECT_EQ(top->ALUResultM, 7);
}

// alu operand B
TEST_F(ExecuteTestbench, ForwardBFromMemPipeline)
{
    resetPipeline();

    top->RD1E = 9;
    top->RD2E = 5;
    top->ALUControlE = 1;  // subtract
    top->RegWriteE = 1;
    top->RdE = 6;

    runSimulation(2);

    top->Rs1E = 0;
    top->Rs2E = 6;
    top->RD1E = 0;
    top->RD2E = 888;   // stale
    top->ALUControlE = 0; // add

    runSimulation(2);

    EXPECT_EQ(top->ALUResultM, 4);
}

TEST_F(ExecuteTestbench, BNETakenAfterForward)
{
    resetPipeline();

    // produce x3 = 1 + 1 = 2
    top->RD1E = 1;
    top->RD2E = 1;
    top->ImmExtE = 1;
    top->ALUSrcE = 1;
    top->ALUControlE = 0; // add
    top->RegWriteE = 1;
    top->RdE = 3;

    runSimulation(2);

    // BNE x3, x0
    top->Rs1E = 3;
    top->Rs2E = 0;
    top->RD1E = 111; // stale
    top->RD2E = 0;
    top->BranchE = 0b010; // bne
    top->ALUControlE = 1; // add

    runSimulation(2);

    EXPECT_EQ(top->PCSrcE, 1);
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