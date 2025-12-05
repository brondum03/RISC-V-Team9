#include <csignal>
#include <cstdlib>
#include <string>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdut.h"
#include "vbuddy.cpp"

#define MAX_SIM_CYC 2000000

void cleanup(int sig) {
    std::ignore = system("rm -f program.hex data.hex");
    exit(sig);
}

int main(int argc, char **argv) {
    signal(SIGINT, cleanup);

    // distribution type
    std::string dist = "gaussian";   // "gaussian" or "triangle" or "noisy"
    std::string load_cmd = "cat ../reference/" + dist + ".mem > data.hex";

    std::ignore = system("../assemble.sh ../reference/pdf.s");
    std::ignore = system(load_cmd.c_str());

    Verilated::commandArgs(argc, argv);
    Vdut *top = new Vdut;

    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("test_out/vb-pdf/waveform.vcd");

    if (vbdOpen() != 1) return -1;
    vbdHeader(("PDF: " + dist).c_str());
    vbdSetMode(0); 

    top->clk = 0;
    top->rst = 1;
    top->trigger = 0;
    top->eval();
    for (int i = 0; i < 4; i++) {
        top->clk = 1; top->eval();
        top->clk = 0; top->eval();
    }
    top->rst = 0;

    // detect start of display loop
    bool plotting = false;
    uint32_t last_a0 = top->a0;
    int cycle = 0;

    for (int sim = 0; sim < MAX_SIM_CYC; sim++) {
        for (int tick = 0; tick < 2; tick++) {
            tfp->dump(2 * sim + tick);
            top->clk = !top->clk;
            top->eval();
        }

        // a0 changes from 0 -> first pdf bin
        if (!plotting && top->a0 != last_a0) {
            plotting = true;
        }

        last_a0 = top->a0;

        // plot :
        if (plotting) {

            // pause with button
            if (!vbdFlag()) {
                cycle++;
                
                // change if condition to the following line to let whole Gaussian 
                // graph fit on Vbuddy screen, ie graph compressed horizontally
                // if (cycle % 6 == 0) {
                if (cycle % 3 == 0) {
                    vbdPlot(top->a0, 0, 255); 
                    vbdCycle(cycle);
                }
            }
        }

        if ((Verilated::gotFinish()) || (vbdGetkey()=='q'))
            exit(0);
    }

    vbdClose();
    tfp->close();
    cleanup(0);
}
