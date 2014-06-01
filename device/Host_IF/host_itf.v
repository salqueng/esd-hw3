module host_itf (
	clk, nRESET, FPGA_nRST, HOST_nOE, HOST_nWE, HOST_nCS, HOST_ADD, HDI, HDO,
	COUNTER_SET, COUNTER_START, COUNTER_DATA_INPUT, COUNTER_DATA_OUTPUT,
	CLCD_RS, CLCD_RW, CLCD_E, CLCD_DQ, LED_D, SEG_COM, SEG_DATA, DOT_SCAN, DOT_DATA,
	Piezo, DIP_D, PUSH_RD, PUSH_LD, PUSH_SW,
	clk_3k, host_sel, sw);
	
	input clk, nRESET, FPGA_nRST, HOST_nOE, HOST_nWE, HOST_nCS;
	input [20:0] HOST_ADD;
	input [15:0] HDI;
	output reg [15:0] HDO;
	
	input [31:0] COUNTER_DATA_OUTPUT;
	output [31:0] COUNTER_DATA_INPUT;
	output COUNTER_SET, COUNTER_START;
	
	
	output CLCD_RS, CLCD_RW, CLCD_E;
	output [7:0] CLCD_DQ;
	output [7:0] LED_D;
	output [5:0] SEG_COM;
	output [7:0] SEG_DATA;
	output [9:0] DOT_SCAN;
	output [6:0] DOT_DATA;
	output Piezo ;
	input [15:0] DIP_D;
	input  [3:0] PUSH_RD;
	output [3:0] PUSH_LD;
	input  [3:0] PUSH_SW;
	
	input clk_3k, sw;
	output host_sel;
	
	reg [15:0] x8800_0010, x8800_0020, x8800_0030, x8800_0032, x8800_0040, x8800_0042, x8800_0050, x8800_0072, x8800_0090, x8800_00A0, x8800_00A2, x8800_00B0, x8800_00C0, x8800_00D0, x8800_00E0, x8800_00F0;
	/*
		reg [15:0] x8800_0010 // TextLCD Controller
		reg [15:0] x8800_0020 // LED Controller
		reg [15:0] x8800_0030; // 7-Segment controller
		reg [15:0] x8800_0032; // 7-Segment Data Register
		reg [15:0] x8800_0040; // Dot Matrix Scan Register(read/write)
		reg [15:0] x8800_0042;	// Dot Matrix Data Register(read/write)
		reg [15:0] x8800_0050; // Buzzer Controller
		wire [15:0] x8800_0062; // DIP Switch Data Register(read only)
		reg [15:0] x8800_00F0; // host mode 제어 - 
		
	*/
	
	// counter register & wires
	reg [15:0] x8800_0034, x8800_0054, x8800_0056;
	wire [15:0] x8800_0058, x8800_005A;
	// counter register & wires 끝
	
	wire [15:0] x8800_0062, x8800_0070, x8800_0080, x8800_0092;
	reg [1:0] reg_sw;
	reg V_SEL;
	integer clk_cnt;

	// input 제어
	always @(posedge clk or negedge nRESET) begin
		if (nRESET == 1'b0) begin
			x8800_0010 <= 16'b0;
			x8800_0020 <= 16'b0;
			x8800_0030 <= 16'b0;
			x8800_0032 <= 16'b0;
			x8800_0040 <= 16'b0;
			x8800_0042 <= 16'b0;
			x8800_0050 <= 16'b0;
			x8800_0034 <= 16'b0;
			x8800_0054 <= 16'b0;
			x8800_0056 <= 16'b0;
			x8800_0072 <= 16'b0;
			x8800_0090 <= 16'b0;
			x8800_00A0 <= 16'b0;
			x8800_00B0 <= 16'b0;
			x8800_00C0 <= 16'b0;
			x8800_00D0 <= 16'b0;
			x8800_00E0 <= 16'b0;
			x8800_00F0 <= 16'b0;
		end else begin
			if (HOST_nCS == 1'b0 && HOST_nWE == 1'b0) begin
				case (HOST_ADD[19:0])
					20'h00010: x8800_0010 <= HDI;
					20'h00020: x8800_0020 <= HDI;
					20'h00030: x8800_0030 <= HDI;
					20'h00032: x8800_0032 <= HDI;
					20'h00040: x8800_0040 <= HDI;
					20'h00042: x8800_0042 <= HDI;
					20'h00050: x8800_0050 <= HDI;
					20'h00034: x8800_0034 <= HDI;
					20'h00054: x8800_0054 <= HDI;
					20'h00056: x8800_0056 <= HDI;
					20'h00072: x8800_0072 <= HDI;
					20'h000A0: x8800_00A0 <= HDI;
					20'h000B0: x8800_00B0 <= HDI;
					20'h000C0: x8800_00C0 <= HDI;
					20'h000D0: x8800_00D0 <= HDI;
					20'h000E0: x8800_00E0 <= HDI;
					20'h000F0: x8800_00F0 <= HDI;
				endcase
			end else begin
				if (FPGA_nRST == 1'b0)    x8800_00F0 <= 16'b0;
				else if (reg_sw == 2'b10) x8800_00F0 <= ~x8800_00F0;
			end
		end
	end // input 제어 끝
	
	// output 제어
	always @(posedge clk or negedge nRESET) begin
		if (nRESET == 1'b0) begin
			HDO <= 16'b0;
		end else begin
			if (HOST_nCS == 1'b0 && HOST_nOE == 1'b0) begin
				case (HOST_ADD[19:0])
					20'h00010: HDO <= x8800_0010;
					20'h00020: HDO <= x8800_0020;
					20'h00030: HDO <= x8800_0030;
					20'h00032: HDO <= x8800_0032;
					20'h00040: HDO <= x8800_0040;
					20'h00042: HDO <= x8800_0042;
					20'h00050: HDO <= x8800_0050;
					20'h00034: HDO <= x8800_0034;
					20'h00054: HDO <= x8800_0054;
					20'h00056: HDO <= x8800_0056;
					20'h00058: HDO <= x8800_0058;
					20'h0005A: HDO <= x8800_005A;
					20'h00062: HDO <= x8800_0062;
					20'h00070: HDO <= x8800_0070;
					20'h00072: HDO <= x8800_0072;
					20'h00080: HDO <= x8800_0080;
					20'h00090: HDO <= x8800_0090;
					20'h00092: HDO <= x8800_0092;
					20'h000A0: HDO <= x8800_00A0;
					20'h000B0: HDO <= x8800_00B0;
					20'h000C0: HDO <= x8800_00C0;
					20'h000D0: HDO <= x8800_00D0;
					20'h000E0: HDO <= x8800_00E0;
					20'h000F0: HDO <= x8800_00F0;
				endcase
			end
		end
	end // output 제어 끝
		
	// CLCD_ctrl_Reg(Character LCD Control Register) at 0x8800_0010
	assign CLCD_RS  = x8800_0010[10];
	assign CLCD_RW  = x8800_0010[9];
	assign CLCD_E   = x8800_0010[8];
	assign CLCD_DQ  = x8800_0010[7:0];
	
	assign LED_D = x8800_0020[7:0]; // LED_Ctrl_Reg (active high)
	// 7-Segment Controller
	assign SEG_COM  = ~x8800_0030[5:0]; // SEG_Sel_Reg (active low)
	assign SEG_DATA = x8800_0032[7:0]; // SEG_Data_Reg (active high)
	// 7-Segment Controller 끝

	// Dot Matrix 
	assign DOT_SCAN = x8800_0040[9:0]; // Dot_Scan_Reg (active high)
	assign DOT_DATA = x8800_0042[6:0]; // Dot_Data_Reg (active high)
	

	assign Piezo    = (x8800_0050[0] == 1'b1) ? 1'b1 : 1'b0; // Buzzer_Ctrl_Reg (active high) -- buzzer enable bit
	
	assign x8800_0070 = (nRESET == 1'b1) ? {12'b0, PUSH_RD} : 16'b0;
	assign PUSH_LD = x8800_0072[3:0];
	
	assign x8800_0062 = (nRESET == 1'b1) ? DIP_D : 16'b0;
	assign x8800_0080 = (nRESET == 1'b1) ? {12'b0, ~PUSH_SW} : 16'b0;
	assign x8800_0092 = (nRESET == 1'b1) ? {10'b0, 6'b101010} : 16'b0;
	
	assign host_sel = x8800_00F0[0]; // 0이면 FPGA, 1이면 CPU
	
	/* counter controller */
	assign COUNTER_SET = (x8800_0034[0] == 1'b1) ? 1'b1 : 1'b0;
	assign COUNTER_START = x8800_0034[8];
	assign COUNTER_DATA_INPUT = {x8800_0056, x8800_0054};
	assign x8800_0058 = COUNTER_DATA_OUTPUT[31:16];
	assign x8800_005A = COUNTER_DATA_OUTPUT[15:0];
	
	always @(posedge clk_3k or negedge nRESET) begin
		if (nRESET == 1'b0) begin
			V_SEL <= 1'b1;
			clk_cnt <= 0;
		end else begin
			if (sw == 1'b0) begin
				if (clk_cnt >= 3) clk_cnt <= 3;
				else              clk_cnt <= clk_cnt+1'b1;
				
				if (clk_cnt == 2) V_SEL <= 1'b0;
				else              V_SEL <= 1'b1;
			end else begin
				clk_cnt <= 0;
			end
		end
	end
	
	always @(posedge clk or negedge nRESET) begin
		if (nRESET == 1'b0) begin
			reg_sw <= 2'b00;
		end else begin
			reg_sw <= {reg_sw[0], V_SEL};
		end
	end
	
endmodule

