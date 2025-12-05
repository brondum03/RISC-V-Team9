#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, TestAddiBne)
{
    setupTest("1_addi_bne");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 254);
}

TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    setData("reference/gaussian.mem");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 15363);
}

TEST_F(CpuTestbench, TestAllLogical)
{
    setupTest("6_all_logical");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0);
}

TEST_F(CpuTestbench, TestAllImm)
{
    setupTest("7_all_imm");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0);
}

TEST_F(CpuTestbench, TestAllLoad)
{
    setupTest("8_all_load");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0);
}

TEST_F(CpuTestbench, TestSrai)
{
    setupTest("13_srai");
    initSimulation();
    runSimulation(CYCLES);

    // Debug output
    std::cout << "a0 value (hex): 0x" << std::hex << top_->a0 << std::dec << std::endl;
    std::cout << "a0 value (signed): " << (int32_t)top_->a0 << std::endl;
    std::cout << "a0 value (unsigned): " << top_->a0 << std::endl;
    
    EXPECT_EQ(top_->a0, -16);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}