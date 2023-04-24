from cocotb_bus.drivers import BusDriver
from cocotb.triggers import Timer

def bit_count(self):
    return bin(self).count("1")

def parity_odd(data):
    data_parity = [i for i in data if bit_count(i) % 2 == 1]
    return data_parity
    
def parity_even(data):
    data_parity = [i for i in data if bit_count(i) % 2 == 0]
    return data_parity
    

class SlaveDriver(BusDriver):
    _signals = ["tvalid", "tready", "tdata", "tlast"]

    def __init__(self, entity, name, clock, **kwargs):
        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.bus.tready.value = 0
        self.bus.tvalid.value = 0
        self.bus.tdata.value  = 0
        self.bus.tlast.value  = 0
    
    async def _driver_send(self, data, sync=False):

        self.log.info(f"Sending x = {data}")
        self.log.info(f"Expected even bytes {parity_even(data)}")
        self.log.info(f"Expected odd bytes {parity_odd(data)}")
        
        for data_i in data[:-1]:
            self.bus.tvalid.value = 1
            self.bus.tdata.value = data_i
            await Timer(10, "ns")


        self.bus.tvalid.value = 1
        self.bus.tlast.value = 1
        self.bus.tdata.value = data[-1]
        await Timer(10, "ns")
        
        self.bus.tvalid.value = 0
        self.bus.tlast.value = 0
        self.bus.tdata.value = 0
        await Timer(10, "ns")

        while self.bus.tready.value == 0:
            self.bus.tvalid.value = 0
            self.bus.tlast.value = 0
            self.bus.tdata.value = 0
            await Timer(10, "ns")


class MasterDriver(BusDriver):
    _signals = ['tready', 'tvalid_odd',
                'tdata', 'tlast_odd',
                'tvalid_even',
                'tlast_even']

    def __init__(self, entity, name, clock, **kwargs):
        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.bus.tready.value = 1
        self.bus.tdata.value = 0
        self.bus.tvalid_odd.value = 0
        self.bus.tlast_odd.value = 0
        self.bus.tvalid_even.value = 0
        self.bus.tlast_even.value = 0