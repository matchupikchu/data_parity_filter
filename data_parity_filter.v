module data_parity_filter(
    a_clk,
    axis_aresetn,
    axis_m_tready,
    axis_s_tready,
    axis_m_tdata,

    // master
    axis_m_tvalid_odd,
    axis_m_tlast_odd,
    axis_m_tvalid_even,
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

output reg [7:0] axis_m_tdata;  // master


// master signals
// odd output interface
output reg    	 axis_m_tvalid_odd; 
output reg		 axis_m_tlast_odd;

// even output interface
output reg    	 axis_m_tvalid_even; 
output reg		 axis_m_tlast_even;

// slave signals
input             axis_s_tvalid;
input      [7:0]  axis_s_tdata;
input 			  axis_s_tlast;

// control regs and wires
wire w_parity;

reg [3:0] r_counter_control_receiver;
reg [3:0] r_counter_control_transceiver;

reg [3:0] r_tlast_even;
reg [3:0] r_tlast_odd;


// regs of data

reg [7:0] r_data;

reg [63:0] r_even_bytes;
reg [63:0] r_odd_bytes;

reg [7:0] r_even_flag;
reg [7:0] r_odd_flag;

// Combinational logic
assign w_parity = r_data[7] ^ r_data[6] ^ r_data[5] ^ r_data[4] ^ r_data[3] ^ r_data[2] ^ r_data[1] ^ r_data[0];
assign axis_s_tready = (r_counter_control_receiver == 0) &&
                       (r_counter_control_transceiver == 0) &&
                       (!(r_counter_control_transceiver == r_tlast_even)) && 
                       (!(r_counter_control_transceiver == r_tlast_odd)) ? 1'b1 : 1'b0;

// Procedural blocks, sequential logic

// reset the device

always @(posedge a_clk or negedge axis_aresetn)
begin

    if (!axis_aresetn) begin
        r_counter_control_receiver <= 4'd0;
        r_counter_control_transceiver <= 4'd0;
        
        r_even_bytes <= 64'd0;
        r_odd_bytes <= 64'd0;

        r_even_flag <= 8'd0;
        r_odd_flag <= 8'd0;

        r_tlast_even <= 4'd0;
        r_tlast_odd <= 8'd0;

        r_data <= 8'd0;
    end

end

// reveive and store data
always @(posedge a_clk)
begin

    if (axis_s_tvalid) begin
        r_data <= axis_s_tdata;
        r_counter_control_receiver <= r_counter_control_receiver + 1;
    end

    case(r_counter_control_receiver)
                8'd1    : begin 
                            if(w_parity) begin
                                r_odd_bytes[63:56] = r_data;
                                r_odd_flag <= r_odd_flag ^ 8'b10000000;
                            end else begin 
                                r_even_bytes[63:56] = r_data;
                                r_even_flag <= r_even_flag ^ 8'b10000000;
                            end
                        end
                8'd2    : begin 
                            if(w_parity) begin
                                r_odd_bytes[55:48] = r_data;
                                r_odd_flag <= r_odd_flag ^ 8'b01000000;
                            end else begin 
                                r_even_bytes[55:48] = r_data;
                                r_even_flag <= r_even_flag ^ 8'b01000000;
                            end
                        end 
                8'd3    : begin
                            if(w_parity) begin
                                r_odd_bytes[47:40] = r_data; 
                                r_odd_flag <= r_odd_flag ^ 8'b00100000;
                            end else begin
                                r_even_bytes[47:40] = r_data;
                                r_even_flag <= r_even_flag ^ 8'b00100000;
                            end
                        end
                8'd4    : begin 
                            if(w_parity) begin
                                r_odd_bytes[39:32] = r_data;
                                r_odd_flag <= r_odd_flag ^ 8'b00010000;
                            end else begin 
                                r_even_bytes[39:32] = r_data;
                                r_even_flag <= r_even_flag ^ 8'b00010000;
                            end
                        end
                8'd5    : begin 
                            if(w_parity) begin 
                                r_odd_bytes[31:24] = r_data;
                                r_odd_flag <= r_odd_flag ^ 8'b00001000;
                            end else begin
                                r_even_bytes[31:24] = r_data;
                                r_even_flag <= r_even_flag ^ 8'b00001000;
                            end
                        end
                8'd6    : begin 
                            if(w_parity) begin
                                r_odd_bytes[23:16] = r_data;
                                r_odd_flag <= r_odd_flag ^ 8'b00000100;
                            end else begin
                                r_even_bytes[23:16] = r_data;
                                r_even_flag <= r_even_flag ^ 8'b00000100;
                            end
                        end
                8'd7    : begin 
                            if(w_parity) begin
                                r_odd_bytes[15:8]  = r_data;
                                r_odd_flag <= r_odd_flag ^ 8'b00000010;
                            end else begin 
                                r_even_bytes[15:8]  = r_data;
                                r_even_flag <= r_even_flag ^ 8'b00000010;
                            end
                        end
                8'd8    : begin 
                            if(w_parity) begin
                                if(r_counter_control_transceiver == 4'd0) begin
                                    r_odd_bytes[7:0]   = r_data;
                                    r_odd_flag <= r_odd_flag ^ 8'b00000001;
                                end
                            end else begin 
                                if(r_counter_control_transceiver == 4'd0) begin
                                    r_even_bytes[7:0]   = r_data;
                                    r_even_flag <= r_even_flag ^ 8'b00000001;
                                end
                            end
                        end
            endcase
end


// transceive data

always @(posedge a_clk)
begin

    if(r_counter_control_receiver == 8'd8) begin
        r_counter_control_transceiver <= r_counter_control_transceiver + 1;
    end

    if(r_counter_control_transceiver > 8'd0) begin
        if(r_even_flag[8-r_counter_control_transceiver]) begin
            axis_m_tvalid_even <= 1'b1;
        end else begin 
            axis_m_tvalid_even <= 1'b0;
        end

        if(r_odd_flag[8-r_counter_control_transceiver]) begin
            axis_m_tvalid_odd <= 1'b1;
        end else begin
            axis_m_tvalid_odd <= 1'b0;
        end
    end else begin
        axis_m_tvalid_even <= 1'b0;
        axis_m_tvalid_odd <= 1'b0;
    end


    case(r_counter_control_transceiver)
    8'd1    :   begin
                    if(r_even_flag[7])
                        axis_m_tdata <= r_even_bytes[63:56];
                    if(r_odd_flag[7]) 
                        axis_m_tdata <= r_odd_bytes[63:56];
                end
    8'd2    :   begin
                    if(r_even_flag[6])
                        axis_m_tdata <= r_even_bytes[55:48];
                    else if(r_odd_flag[6]) 
                        axis_m_tdata <= r_odd_bytes[55:48];
                end
    8'd3    :   begin
                    if(r_even_flag[5])
                        axis_m_tdata <= r_even_bytes[47:40];
                    else if(r_odd_flag[5]) 
                        axis_m_tdata <= r_odd_bytes[47:40];
                end
    8'd4    :   begin
                    if(r_even_flag[4])
                        axis_m_tdata <= r_even_bytes[39:32];
                    else if(r_odd_flag[4]) 
                        axis_m_tdata <= r_odd_bytes[39:32];
                end
    8'd5    :   begin
                    if(r_even_flag[3])
                        axis_m_tdata <= r_even_bytes[31:24];
                    else if(r_odd_flag[3]) 
                        axis_m_tdata <= r_odd_bytes[31:24];
                end
    8'd6    :   begin
                    if(r_even_flag[2])
                        axis_m_tdata <= r_even_bytes[23:16];
                    else if(r_odd_flag[2]) 
                        axis_m_tdata <= r_odd_bytes[23:16];
                end
    8'd7    :   begin
                    if(r_even_flag[1])
                        axis_m_tdata <= r_even_bytes[15:8];
                    else if(r_odd_flag[1]) 
                        axis_m_tdata <= r_odd_bytes[15:8];
                end
    8'd8    :   begin
                    if(r_even_flag[0])
                        axis_m_tdata <= r_even_bytes[7:0];
                    else if(r_odd_flag[0]) 
                        axis_m_tdata <= r_odd_bytes[7:0];
                    r_counter_control_receiver <= 4'd0;
                    r_counter_control_transceiver <= 4'd0;
                    
                    r_even_bytes <= 64'd0;
                    r_odd_bytes <= 64'd0;

                    r_even_flag <= 8'd0;
                    r_odd_flag <= 8'd0;

                    r_tlast_even <= 4'd0;
                    r_tlast_odd <= 8'd0;

                    r_data <= 8'd0;
                    
                end
    endcase

    if(r_even_flag[0] == 1'b1)
        r_tlast_even <= 8;
    else if(r_even_flag[1] == 1'b1)
        r_tlast_even <= 7;
    else if(r_even_flag[2] == 1'b1)
        r_tlast_even <= 6;
    else if(r_even_flag[3] == 1'b1)
        r_tlast_even <= 5;
    else if(r_even_flag[4] == 1'b1)
        r_tlast_even <= 4;    
    else if(r_even_flag[5] == 1'b1)
        r_tlast_even <= 3;
    else if(r_even_flag[6] == 1'b1)
        r_tlast_even <= 2;
    else if(r_even_flag[7] == 1'b1)
        r_tlast_even <= 1;


    if(r_odd_flag[0] == 1'b1)
        r_tlast_odd <= 8;
    else if(r_odd_flag[1] == 1'b1)
        r_tlast_odd <= 7;
    else if(r_odd_flag[2] == 1'b1)
        r_tlast_odd <= 6;
    else if(r_odd_flag[3] == 1'b1)
        r_tlast_odd <= 5;
    else if(r_odd_flag[4] == 1'b1)
        r_tlast_odd <= 4;    
    else if(r_odd_flag[5] == 1'b1)
        r_tlast_odd <= 3;
    else if(r_odd_flag[6] == 1'b1)
        r_tlast_odd <= 2;
    else if(r_odd_flag[7] == 1'b1)
        r_tlast_odd <= 1;

    if ((r_counter_control_transceiver == r_tlast_odd) && (r_counter_control_receiver == 8))
        axis_m_tlast_odd <= 1;
    else 
        axis_m_tlast_odd <= 0;


    if ((r_counter_control_transceiver == r_tlast_even) && (r_counter_control_receiver == 8))
        axis_m_tlast_even <= 1;
    else 
        axis_m_tlast_even <= 0;


end

endmodule