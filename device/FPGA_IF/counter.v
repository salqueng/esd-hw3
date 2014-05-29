module counter_demo (clk_1Hz, nreset,data_from_android,nSET,nSTART,clk_1KHz,data_to_seg_demo);
	input clk_1Hz, nreset, data_from_android,clk_1KHz;
	input nSET,nSTART;
	output [15:0] data_to_seg_demo;
	
	assign data_to_seg_demo = data;
	
	reg[15:0] data_input = 16'hf;
	reg[15:0] data_set;
	reg[15:0] data;
	
	reg start_flag;
	integer cnt_1000;

	always @(posedge clk_1KHz or negedge nreset) begin
		if(nreset == 1'b0) begin
			data <= 16'b0;
			cnt_1000 <= 0;
		end else if(nSET==1'b0) begin
			data <= data_input;
			cnt_1000 <=0;
		end else begin
			if(data != 16'b0) begin	
				if(start_flag ==1'b1) begin
					if(cnt_1000==999) begin
						data <= data-1;
						cnt_1000 <= 0;
					end else begin
						cnt_1000 <= cnt_1000 + 1;
					end
				end else begin
					cnt_1000 <= 0;
				end
			end
		end
	end
	
	always @(negedge nreset or negedge nSTART) begin
			if(nreset == 1'b0) begin
				start_flag <= 1'b0; 
			end else if(start_flag==1'b0)begin
				start_flag <= 1'b1;
			end else begin
				start_flag <= 1'b0;
			end
	end
	
	
endmodule
