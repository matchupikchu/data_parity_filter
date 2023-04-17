import random
import cocotb
from test_filter_tester import ParityTester
from schemdraw import logic

@cocotb.test()
def test(dut):
    
    tb = ParityTester(dut)
    
    tb.start_clock()

    for _ in range(10):
        x = random.sample(range(0, 256), 8)

        yield tb.axis_s_driver._driver_send(x)
    return 0
    
    
