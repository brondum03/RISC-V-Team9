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
        top->rst = 0;
        top->trigger = 0;

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

    void resetPipeline() {
        top->rst = 1;
        runSimulation(1);
        top->rst = 0;
        runSimulation(1);
    }
};


// 1. Word store + load
TEST_F(MemoryTestbench, WordStoreAndLoad) {
    resetPipeline();
    
    // Write 0x11223344 at address 0
    top->MemWriteM = 1;
    top->AddressingModeM = 0b010; // word
    top->ALUResultM = 0;
    top->WriteDataM = 0x11223344;
    top->ResultSrcM = 1; // Select ReadData for result
    top->RegWriteM = 1;
    top->RdM = 5;
    
    runSimulation(1); // Write happens, data propagates to pipeline reg
    
    // Check outputs after pipeline register
    EXPECT_EQ(top->RegWriteW, 1);
    EXPECT_EQ(top->RdW, 5);
    
    // Now do a read operation
    top->MemWriteM = 0;
    top->ALUResultM = 0; // Read from address 0
    top->ResultSrcM = 1; // Select ReadData
    top->RdM = 6;
    
    runSimulation(1); // Read happens
    
    // Check the result after pipeline
    EXPECT_EQ(top->ResultW, 0x11223344u) << "Read data should match written value";
    EXPECT_EQ(top->RdW, 6);
}

// 2. Byte store + load
TEST_F(MemoryTestbench, ByteStoreAndLoad) {
    resetPipeline();
    
    top->MemWriteM = 1;
    top->AddressingModeM = 0b011;  // byte
    top->ALUResultM = 4;
    top->WriteDataM = 0x000000AA;
    top->ResultSrcM = 1;
    top->RegWriteM = 1;
    
    runSimulation(1);
    
    // Read back
    top->MemWriteM = 0;
    top->ALUResultM = 4;
    
    runSimulation(1);
    
    EXPECT_EQ(top->ResultW, 0x000000AAu);
}

// 3. Pass-through signals
TEST_F(MemoryTestbench, PassThroughTest) {
    resetPipeline();

    top->RegWriteM = 1;
    top->ResultSrcM = 0; // Select ALU result
    top->ALUResultM = 0xDEADBEEF;
    top->PCPlus4M = 0x2000;
    top->RdM = 7;
    top->MemWriteM = 0;
    
    runSimulation(1);
    
    EXPECT_EQ(top->RegWriteW, 1);
    EXPECT_EQ(top->ResultW, 0xDEADBEEFu) << "Should pass through ALU result";
    EXPECT_EQ(top->RdW, 7);
}

// 4. PC+4 pass-through (ResultSrcM = 2)
TEST_F(MemoryTestbench, PCPlus4PassThrough) {
    resetPipeline();
    
    top->RegWriteM = 1;
    top->ResultSrcM = 2; // Select PC+4
    top->ALUResultM = 0x12345678;
    top->PCPlus4M = 0x2000;
    top->RdM = 10;
    top->MemWriteM = 0;
    
    runSimulation(1);
    
    EXPECT_EQ(top->RegWriteW, 1);
    EXPECT_EQ(top->ResultW, 0x2000u) << "Should pass through PC+4";
    EXPECT_EQ(top->RdW, 10);
}

// 5. Pipeline stall test (trigger = 1)
TEST_F(MemoryTestbench, PipelineStall) {
    resetPipeline();
    
    // First value
    top->RegWriteM = 1;
    top->ResultSrcM = 0;
    top->ALUResultM = 0x1111;
    top->RdM = 5;
    
    runSimulation(1);
    EXPECT_EQ(top->ResultW, 0x1111u);
    EXPECT_EQ(top->RdW, 5);
    
    // Stall the pipeline
    top->trigger = 1;
    top->ALUResultM = 0x2222; // Try to change input
    top->RdM = 6;
    
    runSimulation(1);
    
    // Should still have old values
    EXPECT_EQ(top->ResultW, 0x1111u) << "Pipeline should be stalled";
    EXPECT_EQ(top->RdW, 5) << "Rd should not update when stalled";
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
