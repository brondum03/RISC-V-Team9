/*
 *  Verifies the results of the ALU module.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ALUTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->ALUop1 = 0;
        top->ALUop2 = 0;
        top->ALUctrl = 0;
    }
};

TEST_F(ALUTestbench, AddBasic)
{
    top->ALUop1 = 5;
    top->ALUop2 = 3;
    top->ALUctrl = 0; // ADD
    top->eval();
    EXPECT_EQ(top->ALUout, 8);
}

TEST_F(ALUTestbench, SubBasic)
{
    top->ALUop1 = 10;
    top->ALUop2 = 4;
    top->ALUctrl = 1; // SUB
    top->eval();
    EXPECT_EQ(top->ALUout, 6);
}

TEST_F(ALUTestbench, ZeroFlagWorks)
{
    top->ALUop1 = 7;
    top->ALUop2 = 7;
    top->ALUctrl = 1; // SUB (7-7=0)
    top->eval();
    EXPECT_EQ(top->EQ, 1);
}

TEST_F(ALUTestbench, AndOperation)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = 2; // AND
    top->eval();
    EXPECT_EQ(top->ALUout, 0b1000);
}

TEST_F(ALUTestbench, OrOperation)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = 3; // OR
    top->eval();
    EXPECT_EQ(top->ALUout, 0b1110);
}

TEST_F(ALUTestbench, XorOperation)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = 4; // XOR
    top->eval();
    EXPECT_EQ(top->ALUout, 0b0110);
}

TEST_F(ALUTestbench, SltOperation)
{
    top->ALUop1 = -8;   //-8 in 2's complement
    top->ALUop2 = 5;   //5
    top->ALUctrl = 5; // SLT
    top->eval();
    EXPECT_EQ(top->ALUout, 1); // -8 < 5
}

TEST_F(ALUTestbench, SltOperationFalse)
{
    top->ALUop1 = 7;   
    top->ALUop2 = 2;  
    top->ALUctrl = 5; // SLT
    top->eval();
    EXPECT_EQ(top->ALUout, 0); // 7 !< 2
}

TEST_F(ALUTestbench, SltUOperation)
{
    top->ALUop1 = 3; 
    top->ALUop2 = 5;   
    top->ALUctrl = 6; // SLTU
    top->eval();
    EXPECT_EQ(top->ALUout, 1); // 3 < 5
}

TEST_F(ALUTestbench, SltUOperationFalse)
{
    top->ALUop1 = 15;   
    top->ALUop2 = 2;  
    top->ALUctrl = 6; // SLTU
    top->eval();
    EXPECT_EQ(top->ALUout, 0); // 15 !< 2
}


int main(int argc, char **argv)
{
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
