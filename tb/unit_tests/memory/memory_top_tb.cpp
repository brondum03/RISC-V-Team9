#include "../testbench.h"
#include "Vdut.h"
#include "verilated_vcd_c.h"

Vdut* top;
VerilatedVcdC* tfp;
unsigned int ticks = 0;

class MemoryTB : public Testbench {
protected:
    void initializeInputs() override {
        top->clk = 0;

        top->ALUResult = 0;
        top->WriteData = 0;
        top->ImmExt = 0;
        top->PCPlus4 = 0;
        top->MemWrite = 0;
        top->AddressingMode = 0;
        top->ResultSrc = 0;
    }
};

// ====== TEST CASES ======

TEST_F(MemoryTB, WordStoreAndLoad) {
    // Store 0x12345678 at address 0
    top->ALUResult = 0;
    top->WriteData = 0x12345678;
    top->MemWrite = 1;
    top->AddressingMode = 0; // word

    runSimulation(); // rising-edge write

    // Read back
    top->MemWrite = 0;
    top->ResultSrc = 1; // select ReadData

    runSimulation(); // read

    EXPECT_EQ(top->Result, 0x12345678u);
}

TEST_F(MemoryTB, ByteStoreAndLoad) {
    // Store byte 0xAA at address 4
    top->ALUResult = 4;
    top->WriteData = 0x000000AA;
    top->MemWrite = 1;
    top->AddressingMode = 1; // byte

    runSimulation(); // write

    // Read back
    top->MemWrite = 0;
    top->ResultSrc = 1;

    runSimulation();

    EXPECT_EQ(top->Result & 0xFF, 0xAAu);
}

TEST_F(MemoryTB, SelectsALUResult) {
    top->ALUResult = 0xDEADBEEF;
    top->ResultSrc = 0; // choose ALUResult

    top->eval();
    EXPECT_EQ(top->Result, 0xDEADBEEF);
}

TEST_F(MemoryTB, SelectsPCPlus4) {
    top->PCPlus4 = 0x1004;
    top->ResultSrc = 2;

    top->eval();
    EXPECT_EQ(top->Result, 0x1004);
}

TEST_F(MemoryTB, SelectsImmExt) {
    top->ImmExt = 0x55AA;
    top->ResultSrc = 3;

    top->eval();
    EXPECT_EQ(top->Result, 0x55AA);
}

// MAIN
int main(int argc, char** argv) {
    // Create empty memory file for datamemory
    system("echo 0 > data.hex");

    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("memory_top.vcd");

    testing::InitGoogleTest(&argc, argv);
    int res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;
    return res;
}
