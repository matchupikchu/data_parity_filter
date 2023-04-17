module data_parity_filter(
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
input            a_clk;
input            axis_aresetn;

input 			 axis_m_tready; // master
output reg		 axis_s_tready; // slave

// master signals
// odd output interface
output reg    	 axis_m_tvalid_odd; 
output reg [7:0] axis_m_tdata_odd;
output reg		 axis_m_tlast_odd;

// even output interface
output reg    	 axis_m_tvalid_even; 
output reg [7:0] axis_m_tdata_even;
output reg		 axis_m_tlast_even;


// slave signals
input             axis_s_tvalid;
input      [7:0]  axis_s_tdata;
input 			  axis_s_tlast;

// temp regs and wires
wire w_parity;

reg [4:0] counter_even;
reg [4:0] counter_odd;

// Combinational logic
assign w_parity = axis_s_tdata[7] ^ axis_s_tdata[6] ^ axis_s_tdata[5] ^ axis_s_tdata[4] ^ axis_s_tdata[3] ^ axis_s_tdata[2] ^ axis_s_tdata[1] ^ axis_s_tdata[0];

// Procedural blocks, sequential logic
always @(posedge a_clk)
begin

    if (axis_aresetn) begin
        counter_even <= 0;
        counter_odd <= 0;
    end

    if (axis_s_tvalid) begin
        
        if (w_parity) begin
            counter_odd <= counter_odd + 1;
        end else begin
            counter_even <= counter_even + 1;
        end
    end


end



endmodule