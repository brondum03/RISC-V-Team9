#include <cstdlib>
#include <utility>

#include "cpu_debug.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CYCLES 10000

static vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

// Global tracer so that multiple tests can share it
static VerilatedVcdC* tfp = nullptr;

// TEST_F(CpuTestbench, TestAddiBne)
// {
//     setupTest("1_addi_bne");
//     initSimulation();
//     runSimulation(CYCLES);
//     EXPECT_EQ(top_->a0, 254);
// }

// TEST_F(CpuTestbench, TestLiAdd)
// {
//     setupTest("2_li_add");
//     initSimulation();
//     runSimulation(CYCLES);
//     EXPECT_EQ(top_->a0, 1000);
// }

TEST_F(CpuTestbench, TestDebug)
{
    setupTest("0_debug");
    setData("reference/data.mem");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 51200);
}

// TEST_F(CpuTestbench, TestPdfWithCache)
// {
//     // Runs the full PDF program that builds the distribution in memory
//     // and returns the sum of all bins in a0.
//     //
//     // The assembly for this test should be the pdf program
//     // (e.g. "pdf.S") wired up in the test harness under the name "pdf".
//     //
//     // Expected result (from spec): a0 = 15363.
//     setupTest("pdf");
//     initSimulation();
//     runSimulation(CYCLES);
//     EXPECT_EQ(top_->a0, 15363);
}

// TEST_F(CpuTestbench, TestJalRet)
// {
//     setupTest("4_jal_ret");
//     initSimulation();
//     runSimulation(CYCLES);
//     EXPECT_EQ(top_->a0, 53);
// }

// Uncomment these as needed—tracing will also apply.
// TEST_F(CpuTestbench, TestLiAdd)
// {
//     setupTest("2_li_add");
//     initSimulation();
//     Verilated::traceEverOn(true);
//     tfp = new VerilatedVcdC;
//     top_->trace(tfp, 99);
//     tfp->open("wave.vcd");
//     runSimulation(CYCLES);
//     tfp->close();
//     EXPECT_EQ(top_->a0, 1000);
// }

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
