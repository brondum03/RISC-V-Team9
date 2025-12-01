/*
  Memory stage testbench 
*/

#include "../testbench.h"

Vdut* top;
VerilatedVcdC* tfp;
unsigned int ticks = 0;

class MemoryTestbench : public Testbench 
{
protected:
    void initializeInputs() override {
        top->clk = 0;

        // default inputs
        top->RegWriteM       = 0;
        top->ResultSrcM      = 0;
        top->MemWriteM       = 0;
        top->AddressingModeM = 0; // word
        top->ALUResultM      = 0;
        top->WriteDataM      = 0;
        top->PCPlus4M        = 0x1000;
        top->RdM             = 5;
    }
};


// 1. Word store + load
TEST_F(MemoryTestbench, WordStoreAndLoad) {
    // Write 0x11223344 at address 0
    top->MemWriteM = 1;
    top->AddressingModeM = 0; // word
    top->ALUResultM = 0;
    top->WriteDataM = 0x11223344;

    runSimulation(); // rising edge -> write

    // Now read back
    top->MemWriteM = 0;
    runSimulation(); // read is combinational

    EXPECT_EQ(top->ReadData_outM, 0x11223344u);
}

// 2. Byte store + load
TEST_F(MemoryTestbench, ByteStoreAndLoad) {
    top->MemWriteM = 1;
    top->AddressingModeM = 1;  // byte
    top->ALUResultM = 4;
    top->WriteDataM = 0x000000AA;

    runSimulation();

    // Read back
    top->MemWriteM = 0;
    runSimulation();

    EXPECT_EQ(top->ReadData_outM, 0x000000AAu);
}

// 3. Pass-through signals
TEST_F(MemoryTestbench, PassThroughTest) {
    top->RegWriteM = 1;
    top->ResultSrcM = 2;
    top->ALUResultM = 0xDEADBEEF;
    top->PCPlus4M = 0x2000;
    top->RdM = 7;

    runSimulation();

    EXPECT_EQ(top->RegWrite_outM, 1);
    EXPECT_EQ(top->ResultSrc_outM, 2);
    EXPECT_EQ(top->ALUResult_outM, 0xDEADBEEFu);
    EXPECT_EQ(top->PCPlus4_outM, 0x2000u);
    EXPECT_EQ(top->Rd_outM, 7);
}


int main(int argc, char** argv)
{
    system("echo 0 > data.hex");
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("memory.vcd");

    testing::InitGoogleTest(&argc, argv);
    int res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
