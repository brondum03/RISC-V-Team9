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

TEST_F(CpuTestbench, TestLoadByte)
{
    setupTest("8_load_byte");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestLoadHalf)
{
    setupTest("9_load_half");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x100);
}

TEST_F(CpuTestbench, TestLoadWord)
{
    setupTest("10_load_word");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x01007180);
}

TEST_F(CpuTestbench, TestLoadByteU)
{
    setupTest("11_load_byte_u");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestStoreByte)
{
    setupTest("12_store_byte");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestStoreHalf)
{
    setupTest("13_store_half");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1);
}

TEST_F(CpuTestbench, TestSrai)
{
    setupTest("14_srai");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, -16);
}

TEST_F(CpuTestbench, TestSltiu)
{
    setupTest("15_sltiu");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}