#include "gtest/gtest.h"
#include "Vdut.h"     // correct verilated header
#include "verilated.h"

class ControlTest : public ::testing::Test {
public:
    Vdut* dut;

protected:
    void SetUp() override {
        dut = new Vdut;

        // initialize all inputs to stable defaults
        dut->op = 0;
        dut->funct3 = 0;
        dut->funct7 = 0;
        dut->Zero = 0;
        dut->stall = 0;
        dut->negative = 0;

        dut->eval();
    }

    void TearDown() override {
        delete dut;
    }

    void evaluate() {
        dut->eval();
    }
};

TEST_F(ControlTest, RTypeInstruction) {
    dut->op = 0b0110011;  // R-type
    dut->funct3 = 0b000;
    dut->funct7 = 0;
    evaluate();

    EXPECT_EQ(dut->RegWrite, 1);
    EXPECT_EQ(dut->ALUSrc, 0);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->ResultSrc, 0b00);
    EXPECT_EQ(dut->PCSrc, 0);
}

TEST_F(ControlTest, ITypeAddiInstruction) {
    dut->op = 0b0010011; 
    dut->funct3 = 0b000;
    evaluate();

    EXPECT_EQ(dut->RegWrite, 1);
    EXPECT_EQ(dut->ALUSrc, 1);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->ResultSrc, 0b00);
    EXPECT_EQ(dut->PCSrc, 0);
}

TEST_F(ControlTest, ITypeLoadInstruction) {
    dut->op = 0b0000011;
    dut->funct3 = 0b010;
    evaluate();

    EXPECT_EQ(dut->RegWrite, 1);
    EXPECT_EQ(dut->ALUSrc, 1);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->ResultSrc, 0b01);
    EXPECT_EQ(dut->PCSrc, 0);
}

TEST_F(ControlTest, BTypeBranchEqual) {
    dut->op = 0b1100011;
    dut->funct3 = 0b000;
    dut->Zero = 1; 
    evaluate();

    EXPECT_EQ(dut->RegWrite, 0);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->PCSrc, 1);  // branch
}

TEST_F(ControlTest, JTypeJal) {
    dut->op = 0b1101111;
    evaluate();

    EXPECT_EQ(dut->RegWrite, 1);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->PCSrc, 1);  // jumps use PCSrc = 2
}

TEST_F(ControlTest, DefaultCase) {
    dut->op = 0b1111111;
    evaluate();

    EXPECT_EQ(dut->RegWrite, 0);
    EXPECT_EQ(dut->MemWrite, 0);
    EXPECT_EQ(dut->PCSrc, 0);
}