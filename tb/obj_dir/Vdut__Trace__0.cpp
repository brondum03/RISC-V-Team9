// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vdut__Syms.h"


void Vdut___024root__trace_chg_0_sub_0(Vdut___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vdut___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_chg_0\n"); );
    // Init
    Vdut___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdut___024root*>(voidSelf);
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vdut___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vdut___024root__trace_chg_0_sub_0(Vdut___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_chg_0_sub_0\n"); );
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgBit(oldp+0,(vlSelfRef.clk));
    bufp->chgBit(oldp+1,(vlSelfRef.rst));
    bufp->chgCData(oldp+2,(vlSelfRef.PCsrc),2);
    bufp->chgIData(oldp+3,(vlSelfRef.ImmExt),32);
    bufp->chgIData(oldp+4,(vlSelfRef.ALUResult),32);
    bufp->chgIData(oldp+5,(vlSelfRef.Instr),32);
    bufp->chgIData(oldp+6,(vlSelfRef.PCPlus4),32);
    bufp->chgIData(oldp+7,(vlSelfRef.fetch_top__DOT__ProgramCounter__DOT__pc),32);
    bufp->chgIData(oldp+8,((vlSelfRef.ImmExt + vlSelfRef.fetch_top__DOT__ProgramCounter__DOT__pc)),32);
    bufp->chgIData(oldp+9,(((2U & (IData)(vlSelfRef.PCsrc))
                             ? ((1U & (IData)(vlSelfRef.PCsrc))
                                 ? vlSelfRef.fetch_top__DOT__ProgramCounter__DOT__pc
                                 : vlSelfRef.ALUResult)
                             : ((1U & (IData)(vlSelfRef.PCsrc))
                                 ? (vlSelfRef.ImmExt 
                                    + vlSelfRef.fetch_top__DOT__ProgramCounter__DOT__pc)
                                 : vlSelfRef.PCPlus4))),32);
}

void Vdut___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vdut___024root__trace_cleanup\n"); );
    // Init
    Vdut___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vdut___024root*>(voidSelf);
    Vdut__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
