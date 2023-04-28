
import cocotb
from cocotb.clock import Clock

from test_filter_drivers import MasterDriver, SlaveDriver
from test_filter_monitors import MasterMonitor, SlaveMonitor


class TbParityFilterTester(object):
    def __init__(self, dut):
        self.dut = dut
    
    def start_clock(self, clk_period = 10):
        self.dut._log.info("Running clock")
        cocotb.start_soon(Clock(self.dut.a_clk, clk_period,units='ns').start())


class ParityFilterTester(TbParityFilterTester):
    def __init__(self, dut):
        super(ParityFilterTester, self).__init__(dut)

        self.dut = dut
        self.expected_output = []
        self.dut.axis_s_tvalid.value = 0 
        self.dut.axis_m_tready.value = 0
        self.dut.axis_s_tdata.value = 0
        self.dut.axis_s_tlast.value = 0


        self.axis_m_driver = MasterDriver(self.dut, "axis_m", dut.a_clk)
        self.axis_s_driver = SlaveDriver(self.dut, "axis_s", dut.a_clk)

        
        self.axis_m_monitor = MasterMonitor(self.dut, name = "axis_m",
                                           clock = dut.a_clk)
        self.axis_s_monitor = SlaveMonitor(self.dut, name = "axis_s",
                                           clock = dut.a_clk)
        