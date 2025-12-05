#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"
#include "Vdut.h"

#define MAX_SIM_CYCLE 1000000

int main (int argc, char **argv) {
    int simcyc; // simulation clock count
    int tick; // each clock cycle has two ticks for two edges (rising and falling)

    std::ignore = system("../assemble.sh ../asm/f1_fsm.s"); // assemble the program
    std::ignore = system("touch data.hex"); // create empty data.hex if not present
    
    Verilated::commandArgs(argc, argv);
    Vdut* top = new Vdut;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    if (vbdOpen() != 1) return -1;
    vbdHeader("RISC V F1 FSM");
    vbdSetMode(0);   

    // initialize simulation inputs
    top->clk = 0;
    top->rst = 0;
    top->trigger = 1;

    for (simcyc =0; simcyc<MAX_SIM_CYCLE; simcyc++){
        
        for (tick=0; tick<2; tick++){
            tfp->dump(2*simcyc + tick);
            top->clk = !top->clk; // toggle clock
            top->eval(); // evaluate model
        }

        top->trigger = !vbdFlag(); // get enable signal from Vbuddy


        vbdBar(top->a0 & 0xFF);
        // for debugging:
        // std::cout << "a0 = " << top->a0 << std::endl;
        // std::cout << "trigger = " << int(top->trigger) << std::endl;
        vbdCycle(simcyc);

        if ((Verilated::gotFinish()) || (vbdGetkey()=='q'))
            exit(0);
    }
    
    vbdClose();
    tfp->close();
    exit(0);
    
}