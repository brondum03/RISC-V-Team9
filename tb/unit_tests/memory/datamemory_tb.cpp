/*
 *  Verifies the results of the data memory module.
 */

#include "../testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class DataMemTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->write_enable = 0;
        top->write_data = 0;
        top->address = 0;
        top->addr_mode = 0; // word mode
        // output: read_data
    }
};


// Default read from uninitialized memory.
TEST_F(DataMemTestbench, DefaultRead) {
    top->address = 0;
    runSimulation();
    EXPECT_EQ(top->read_data, 0u);
}

// Single-word write and read back.
TEST_F(DataMemTestbench, WordWriteAndRead) {
    top->addr_mode = 0;       // word access
    top->write_enable = 1;
    top->address = 0;         // aligned address
    top->write_data = 0x11223344;

    runSimulation();          // perform write

    top->write_enable = 0;
    runSimulation();          // read

    EXPECT_EQ(top->read_data, 0x11223344u);
}


// Overwriting a word works correctly.
TEST_F(DataMemTestbench, OverwriteWord) {
    // Write initial word
    top->addr_mode = 0;
    top->write_enable = 1;
    top->address = 4;         // word-aligned at 4
    top->write_data = 0xAAAAAAAA;
    runSimulation();

    // Overwrite with new word
    top->address = 4;
    top->write_data = 0xBBBBBBBB;
    runSimulation();

    // Disable write, verify read
    top->write_enable = 0;
    top->address = 4;
    runSimulation();

    EXPECT_EQ(top->read_data, 0xBBBBBBBBu);
}

// Byte write followed by word read.
TEST_F(DataMemTestbench, ByteWriteAndReadbackWord) {
    // Pre-fill word
    top->addr_mode = 0;
    top->write_enable = 1;
    top->address = 8;
    top->write_data = 0xAABBCCDD;
    runSimulation();

    // Write ONLY low byte = 0x77
    top->addr_mode = 1;         // byte mode
    top->write_data = 0x00000077;
    runSimulation();

    // Read full word
    top->write_enable = 0;
    top->addr_mode = 0;
    runSimulation();

    EXPECT_EQ(top->read_data, 0xAABBCC77u);
}

// Asynchronous read during write (combinational read).
TEST_F(DataMemTestbench, AsyncReadDuringWrite) {
    // Write word at address 0
    top->addr_mode = 0;
    top->write_enable = 1;
    top->address = 0;
    top->write_data = 0x11111111;
    runSimulation();

    // Write another at address 4
    top->address = 4;
    top->write_data = 0x22222222;
    runSimulation();

    // Read back both without writing
    top->write_enable = 0;

    top->address = 0;
    top->eval();
    EXPECT_EQ(top->read_data, 0x11111111u);

    top->address = 4;
    top->eval();
    EXPECT_EQ(top->read_data, 0x22222222u);
}

// Writes should not occur when write_enable = 0.
TEST_F(DataMemTestbench, WriteEnableOff) {
    // Write with WE = 1
    top->addr_mode = 0;
    top->write_enable = 1;
    top->address = 12;
    top->write_data = 0x12345678;
    runSimulation();

    // Attempt overwrite with WE = 0 (should do nothing)
    top->write_enable = 0;
    top->write_data = 0xFFFFFFFF;
    runSimulation();

    EXPECT_EQ(top->read_data, 0x12345678u);
}

int main(int argc, char **argv)
{
    system("echo 0 > data.hex");
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