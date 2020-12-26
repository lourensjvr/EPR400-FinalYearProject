module StepMotoController
(
	i_clk_50,
	i_Start,
	i_HitVelocity,
	o_Dir,
	o_Step,
	i_QA,
	i_QB,
	o_StepPos,
	o_tx,
	i_ZDC,
	i_ZStep,
	o_Zdone
);

input wire i_clk_50;
input wire i_Start;
input wire [7:0] i_HitVelocity;
output reg o_Dir = 1'b0;
output wire o_Step;
input wire i_QA;
input wire i_QB;
output reg [15:0] o_StepPos = 16'd10000;
output wire signed [39:0] o_tx;
input wire  i_ZDC;
input wire  i_ZStep;
output reg o_Zdone = 1'b0;

wire [31:0] t1;
wire [31:0] t2;
wire [31:0] t3;

parameter Steps = 180;
parameter HitSteps = 100;
reg [7:0] VelocityMax = 0;
parameter Acceleration = 3;
assign t1 = (IntReset*VelocityMax)/Acceleration;
assign t2 = (IntReset*Steps)/VelocityMax;
assign t3 = (t1 + t2);

assign o_tx = ((500000*HitSteps)/i_HitVelocity)+((250000/Acceleration)*i_HitVelocity);

reg [31:0] IntTime = 0;
reg [31:0] IntCount = 0;
reg [31:0] IntRate = 0;
parameter IntReset = 499999;
assign o_Step = (IntCount > (IntReset/2));

parameter s_Idle = 2'b00;
parameter s_Hit = 2'b01;
parameter s_Return = 2'b10;
reg zeroed = 1'b0;

reg [1:0] StepperState = s_Idle;

reg [2:0] quadA_delayed, quadB_delayed;
always @(posedge i_clk_50) quadA_delayed <= {quadA_delayed[1:0], i_QA};
always @(posedge i_clk_50) quadB_delayed <= {quadB_delayed[1:0], i_QB};

wire count_enable = quadA_delayed[1] ^ quadA_delayed[2] ^ quadB_delayed[1] ^ quadB_delayed[2];
wire count_direction = quadA_delayed[1] ^ quadB_delayed[2];

always@(posedge i_clk_50)
begin
	if (zeroed == 1'b0)
		begin
			if (i_ZDC == 1'b0)
				begin
					o_Dir = 1'b1;
					if (IntCount < IntReset)
						begin
							IntCount = IntCount + 1;
						end
					else
						begin
							IntCount = 0;
						end
				end
			if (i_ZStep == 1'b0)
				begin
					zeroed = 1'b1;
					o_Zdone = 1'b1;
				end
		end
	else
		begin
		
	case (StepperState)		
		s_Idle :
			begin
				IntCount = 0;
				IntTime = 0;
				if (i_Start == 1'b0)
					begin
						StepperState = s_Hit;
					end
				else
					begin
						StepperState = s_Idle;
					end
			end
	
		s_Hit :
			begin
				o_Dir = 1'b0;
				VelocityMax = i_HitVelocity;
				IntTime = IntTime + 1;
				if (IntCount < IntReset)
					begin
						IntCount = IntCount + IntRate;
					end
				else
					begin
						IntCount = 0;
					end
				
				if (IntTime < t1)
					begin
						IntRate = (Acceleration*IntTime)/IntReset;
						StepperState = s_Hit;
					end
				else if (IntTime < t2)
					begin
						IntRate = VelocityMax;
						StepperState = s_Hit;
					end
				else if (IntTime < t3)
					begin
						IntRate = VelocityMax-((Acceleration*(IntTime-t2))/IntReset);
						StepperState = s_Hit;
					end
				else
					begin
						IntRate = 0;
						StepperState = s_Return;
						IntTime = 0;
						IntCount = 0;
					end
			end
			
		s_Return :
			begin
				o_Dir = 1'b1;
				VelocityMax = 2;
				IntTime = IntTime + 1;
				if (IntCount < IntReset)
					begin
						IntCount = IntCount + IntRate;
					end
				else
					begin
						IntCount = 0;
					end
				
				if (IntTime < t1)
					begin
						IntRate = (Acceleration*IntTime)/IntReset;
						StepperState = s_Return;
					end
				else if (IntTime < t2)
					begin
						IntRate = VelocityMax;
						StepperState = s_Return;
					end
				else if (IntTime < t3)
					begin
						IntRate = VelocityMax-((Acceleration*(IntTime-t2))/IntReset);
						StepperState = s_Return;
					end
				else
					begin
						IntRate = 0;
						StepperState = s_Idle;
						IntTime = 0;
						IntCount = 0;
					end
			end
		
		default :
          StepperState = s_Idle;
         
   endcase
	end
end

endmodule