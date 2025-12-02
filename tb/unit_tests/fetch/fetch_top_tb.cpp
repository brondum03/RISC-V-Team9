#include "base_testbench.h"
#include "Vdut.h"
#include "verilated_vcd_c.h"

Vdut* top;
VerilatedVcdC* tfp;
unsigned int ticks = 0;

class FetchTB : public ::testing::Test {
protected:
    void SetUp() override {
        initializeInputs();
        runReset();
    }

    void initializeInputs() {
        top->clk = 0;
        top->rst = 0;
        top->PCsrc = 0;
        top->ImmExt = 5;   // same as original
        top->ALUResult = 7;   // ALUALUResult
    }

    void runReset() {
        top->rst = 1;
        runSimulation();
        top->rst = 0;
    }

    void runSimulation() {
        for (int clk = 0; clk < 2; clk++) {
            top->eval();
            tfp->dump(2 * ticks + clk);
            top->clk = !top->clk;
        }
        ticks++;

        if (Verilated::gotFinish())
            exit(0);
    }
};

// ===================== TESTS ==========================

TEST_F(FetchTB, ResetStartsAtZero) {
    top->rst=1;
    top->eval();
    EXPECT_EQ(top->Instr, 0x11111111);
}

TEST_F(FetchTB, SequentialFetch) {
    top->PCsrc = 0;
    runReset();
    runSimulation();
    EXPECT_EQ(top->Instr, 0x22222222);

    runSimulation();
    EXPECT_EQ(top->Instr, 0x33333333);
}

TEST_F(FetchTB, BranchTest) {
    top->PCsrc = 1;
    top->ImmExt = 8;
    runSimulation();
    EXPECT_EQ(top->Instr, 0x33333333);
}

TEST_F(FetchTB, JumpTest) {
    top->PCsrc = 2;
    top->ALUResult = 16;
    runSimulation();
    EXPECT_EQ(top->Instr, 0x55555555);
}

TEST_F(FetchTB, JumpBackwards) {
    top->PCsrc = 2;
    top->ALUResult = 0;
    runSimulation();
    EXPECT_EQ(top->Instr, 0x11111111);
}

TEST_F(FetchTB, ALUALUResultIgnoredWhenPCsrcNotTwo) {
    top->PCsrc = 0;
    top->ALUResult = 100;
    runSimulation();
    EXPECT_NE(top->Instr, 0x00000000);
}

TEST_F(FetchTB, MisalignedALUALUResult) {
    top->PCsrc = 2;
    top->ALUResult = 6;       // byte address 6 → word index 1
    runSimulation();
    EXPECT_EQ(top->Instr, 0x33332222);
}

TEST_F(FetchTB, ConsecutiveJumps) {
    top->PCsrc = 2;
    top->ALUResult = 8;
    runSimulation();
    EXPECT_EQ(top->Instr, 0x33333333);

    top->ALUResult = 16;
    runSimulation();
    EXPECT_EQ(top->Instr, 0x55555555);
}

TEST_F(FetchTB, HoldPC) {
    top->PCsrc = 3;        // hold state
    runSimulation();
    EXPECT_EQ(top->Instr, 0x11111111);
}


int main(int argc, char** argv)
{
    system("cp ../rtl/fetch/program.hex ./program.hex");

    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("fetch.vcd");

    testing::InitGoogleTest(&argc, argv);
    int res = RUN_ALL_TESTS();

    top->final();
    tfp->close();
    delete top;
    delete tfp;

    return res;
}