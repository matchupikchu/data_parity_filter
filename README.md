## Parity filter module in Verilog 

This repo contains the project of parity filter project in Verilog. The communication with device is based upon one AXIS slave interface and two AXIS master interfaces. 

Firstly module receives data from master and filter data in its registers in order to transceive the data on master interfaces depending on received data parity.

Axis interface was implemented with the use AMBA 4 AXI4-Stream Protocol Specification: 
<https://developer.arm.com/documentation/ihi0051/a/Introduction/About-the-AXI4-Stream-protocol>

The whole interface consists of such signals as:
- global signals:
  - a_clk - global clock,
  - axis_aresetn - global reset signal
  - axis_m_tready - global master ready signal, 
  - axis_s_tready - global slave ready signal

- slave side:
  - axis_s_tvalid - slave valid signal,
  - axis_s_t_data - slave 8 bit wide data bus,
  - axis_s_tlast - slave last signal,

- master side:
  - data with odd number of ones 
    - axis_m_tvalid_odd - master valid signal,
    - axis_m_tdata_odd - master 8 bit wide bus,
    - axis_m_tlast_odd - master last signal
  - data with even number of ones 
    - axis_m_tvalid_even - master valid signal,
    - axis_m_tdata_even - master 8 bit wide bus,
    - axis_m_tlast_even - master last signal


## Requirements
  - Python 3.8.10 (or newer)
  - Cocotb 1.7.2
  - Icarus Verilog 10.3 

## Example waveform
![image](https://user-images.githubusercontent.com/56771910/233341240-ec43584e-2d11-4929-8781-b03318bcb7a5.png)
