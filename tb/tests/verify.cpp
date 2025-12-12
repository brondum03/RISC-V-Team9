#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

#define CYCLES 10000

TEST_F(CpuTestbench, TestInProc1)
{
    setupTest("inprocess1");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestInProc2)
{
    setupTest("inprocess2");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 155);
}


int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}