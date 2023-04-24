import cocotb
from cocotb_bus.monitors import BusMonitor
from cocotb.triggers import RisingEdge
from test_filter_drivers import parity_even, parity_odd

class SlaveMonitor(BusMonitor):
    
    def __init__(self, entity, clock,
                 name = '',
                 bus_separator='_',
                 signals = ['tvalid', 'tdata', 'tready', 'tlast']):
        
        self.dut = entity
        self._signals = signals
        BusMonitor.__init__(self, entity, name, clock, bus_separator = bus_separator, callback = None)
        self.clock = clock
        self.tvalid = getattr(self.bus,list(filter(lambda x: 'tvalid' in x, self._signals))[0])
        self.tready = getattr(self.bus,list(filter(lambda x: 'tready' in x, self._signals))[0])
        self.tdata  = getattr(self.bus,list(filter(lambda x: 'tdata' in x, self._signals))[0])
        self.tlast  = getattr(self.bus,list(filter(lambda x: 'tlast' in x, self._signals))[0])

        
    @cocotb.coroutine
    def _monitor_recv(self):
        
        while True:
            yield RisingEdge(self.clock)
            if self.tvalid.value == 1:

                self.log.info(f"{self.name} tvalid {int(self.tvalid)}")
                self.log.info(f"{self.name} tready {int(self.tready)}")
                self.log.info(f"{self.name} tdata {int(self.tdata)}")
                self.log.info(f"{self.name} tlast {int(self.tlast)}")


class MasterMonitor(BusMonitor):

    def __init__(self, entity, clock,
                 name = '',
                 bus_separator='_',
                 signals = ['tready', 'tvalid_odd',
                            'tdata', 'tlast_odd',
                            'tvalid_even', 'tlast_even']):
        
        self.dut = entity
        self._signals = signals
        BusMonitor.__init__(self, entity, name, clock, bus_separator = bus_separator, callback = None)
        self.clock = clock
        self.tready = getattr(self.bus,list(filter(lambda x: 'tready' in x, self._signals))[0])
        self.tvalid_odd = getattr(self.bus,list(filter(lambda x: 'tvalid_odd' in x, self._signals))[0])
        self.tdata  = getattr(self.bus,list(filter(lambda x: 'tdata' in x, self._signals))[0])
        self.tlast_odd  = getattr(self.bus,list(filter(lambda x: 'tlast_odd' in x, self._signals))[0])
        self.tvalid_even = getattr(self.bus,list(filter(lambda x: 'tvalid_even' in x, self._signals))[0])
        self.tlast_even  = getattr(self.bus,list(filter(lambda x: 'tlast_even' in x, self._signals))[0])
    
    @cocotb.coroutine
    def _monitor_recv(self):
        
        data_from_DUT = []
            
        even_data_from_DUT = []
        odd_data_from_DUT = []

        flag_tlast_even = 0
        flag_tlast_odd = 0

        while True: 
            yield RisingEdge(self.clock)

            # receive all data
            if self.tvalid_even.value == 1 or self.tvalid_odd.value == 1:
                data_from_DUT += [self.tdata.value]
            
            # assign data to appriopriate lists
            if self.tvalid_even.value == 1:
                even_data_from_DUT += [self.tdata.value]
                if self.tlast_even.value == 1:
                    flag_tlast_even = 1
                    assert even_data_from_DUT == parity_even(data_from_DUT), f"Test Failed. Received {even_data_from_DUT}, but should receive {parity_even(data_from_DUT)}"

            if self.tvalid_odd.value == 1:
                odd_data_from_DUT += [self.tdata.value]
                if self.tlast_odd.value == 1:
                    flag_tlast_odd = 1
                    self.log.info(f"{self.name} result ")
                    assert odd_data_from_DUT == parity_odd(data_from_DUT), f"Test Failed. Received {odd_data_from_DUT}, but should receive {parity_odd(data_from_DUT)}"
            
            if flag_tlast_even == 1 and flag_tlast_odd == 1:
                data_from_DUT = []
                odd_data_from_DUT = []
                even_data_from_DUT = []
                flag_tlast_even = 0
                flag_tlast_odd = 0
