// `include "data_parity_filter.v"

module data_parity_filter_wrapper(
    a_clk,
    axis_aresetn,
    axis_m_tready,
    axis_s_tready,

    // master
    axis_m_tvalid_odd,
    axis_m_tdata_odd,
    axis_m_tlast_odd,
    axis_m_tvalid_even,
    axis_m_tdata_even,
    axis_m_tlast_even,
    
    // slave
    axis_s_tvalid,
    axis_s_tdata,
    axis_s_tlast);

// global signals
output     reg     a_clk;
input            axis_aresetn;

input 			 axis_m_tready; // master
output  		 axis_s_tready; // slave

// master signals
// odd output interface
output     	 axis_m_tvalid_odd; 
output   [7:0] axis_m_tdata_odd;
output     	 axis_m_tlast_odd;

// even output interface
output     	 axis_m_tvalid_even; 
output  [7:0] axis_m_tdata_even;
output 		 axis_m_tlast_even;


// slave signals
input             axis_s_tvalid;
input      [7:0]  axis_s_tdata;
input 			  axis_s_tlast;


reg [3:0] i;

data_parity_filter dut(
    .a_clk(a_clk),
    .axis_aresetn(axis_aresetn),
    .axis_m_tready(axis_m_tready),
    .axis_s_tready(axis_s_tready),
    // master
    // odd output interface
    .axis_m_tvalid_odd(axis_m_tvalid_odd),
    .axis_m_tdata_odd(axis_m_tdata_odd),
    .axis_m_tlast_odd(axis_m_tlast_odd),
    // odd output interface
    .axis_m_tvalid_even(axis_m_tvalid_even),
    .axis_m_tdata_even(axis_m_tdata_even),
    .axis_m_tlast_even(axis_m_tlast_even),
    // slave
    .axis_s_tvalid(axis_s_tvalid),
    .axis_s_tdata(axis_s_tdata),
    .axis_s_tlast(axis_s_tlast)
);

initial begin
    $dumpfile("data_parity_filter.vcd");
	  $dumpvars;
    //   $dumpvars(1, "data_parity_filter.vcd".m_even_bytes);
    //   $dumpvars(1, m_odd_bytes);
      
    //   for(i = 0; i < 8; i = i + 1) begin
    //     $dumpvars(1, data_parity_filter.m_even_bytes[i]);
    //     $dumpvars(1, data_parity_filter.m_odd_bytes[i]);
    //   end
    // $dumpvars(1, m_even_bytes[0]);
    // $dumpvars(1, m_even_bytes[1]);
    // $dumpvars(1, m_even_bytes[2]);
	  a_clk=0;
	  forever begin
		  #5 a_clk=~a_clk;
	  end
end



endmodule