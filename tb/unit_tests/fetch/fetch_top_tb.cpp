/*
 * Verifies behaviour of fetch_top.sv 
 */

#include "../testbench.h"
#include "Vdut.h"
#include <fstream>
#include <vector>
#include <stdexcept>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

static std::vector<uint32_t> load_hex_program(const std::string &path)
{
    std::ifstream f(path);
    if (!f.is_open())
        throw std::runtime_error("Cannot open hex file: " + path);

    std::vector<uint8_t> bytes;
    std::string byteStr;

    while (f >> byteStr)
    {
        uint8_t b = std::stoi(byteStr, nullptr, 16);
        bytes.push_back(b);
    }

    std::vector<uint32_t> instr;
    for (size_t i = 0; i + 3 < bytes.size(); i += 4)
    {
        uint32_t w = bytes[i] | (bytes[i+1] << 8) | (bytes[i+2] << 16) | (bytes[i+3] << 24);

        instr.push_back(w);
    }
    return instr;
}
class FetchTestbench : public Testbench {
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;
        top->trigger = 0;

        top->StallF = 0;
        top->StallD = 0;
        top->FlushD = 0;

        top->PCsrcE = 0;
        top->PCTargetE = 0;
    }

    void resetPipeline()
    {
        top->rst = 1;
        runSimulation(1);
        top->rst = 0;
        runSimulation(1);
    }
};


static const std::vector<uint32_t> INSTR = load_hex_program("reference/pdf.hex");

const int INSTR_COUNT = INSTR.size();

TEST_F(FetchTestbench, FirstInstructionAfterReset)
{
    resetPipeline();
    EXPECT_EQ(top->InstrD, INSTR[0]);
}

TEST_F(FetchTestbench, SequentialPC)
{
    resetPipeline();

    for (int i = 0; i < INSTR.size(); i++)
    {
        EXPECT_EQ(top->InstrD, INSTR[i]);

        runSimulation(1); 
    }
}


TEST_F(FetchTestbench, BranchRedirectionBehaviour)
{
    std::vector<int> jumps = {6, 2, 10, 1, 12};

    resetPipeline();
    runSimulation(1);

    top->PCsrcE = 1;

    // first jump
    top->PCTargetE = jumps[0] * 4;
    runSimulation(1);

    // subsequent jumps
    for (int i = 1; i < jumps.size(); i++)
    {
        top->PCTargetE = jumps[i] * 4;
        runSimulation(1);

        EXPECT_EQ(top->InstrD, INSTR[jumps[i - 1]]);
    }
}

TEST_F(FetchTestbench, FetchStageStall)
{
    int index1 = 7;

    resetPipeline();

    // jump to firstIndex
    top->PCsrcE = 1;
    top->PCTargetE = index1 * 4;
    runSimulation(2);

    EXPECT_EQ(top->InstrD, INSTR[index1]);

    // stall → nothing should move
    top->StallF = 1;
    top->StallD = 1;
    runSimulation(1);

    EXPECT_EQ(top->InstrD, INSTR[index1]);
}


int main(int argc, char **argv)
{
    std::ignore = system("rm -f program.hex");
    std::ignore = system("cp reference/pdf.hex program.hex");    
    
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
    std::ignore = system("rm -f program.hex");
    return res;
}
