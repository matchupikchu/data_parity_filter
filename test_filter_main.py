import random
import cocotb
from test_filter_tester import ParityFilterTester
from cocotb.triggers import Timer


@cocotb.test()
def test(dut):
    
    tb = ParityFilterTester(dut)
    
    tb.start_clock()

    tb.dut.axis_aresetn.value = 0
    yield Timer(10, "ns")

    tb.dut.axis_aresetn.value = 1



    for _ in range(10):
        x = random.sample(range(0, 256), 8)

        yield tb.axis_s_driver._driver_send(x)
    return 0
    
    
