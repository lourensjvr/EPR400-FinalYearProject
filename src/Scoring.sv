module Scoring
#(parameter DelayCoeff = 1,
  parameter NegTrigX = 16'd230,
  parameter PosTrigX = 16'd1175)
(
	i_clk,
	i_reset,
	i_X,
	i_VX,
	i_BallDelay,
	o_score_P1,
	o_score_P2,
	o_goal,
	o_debug
);

input wire i_clk;
input wire i_reset;
input wire [15:0] i_X;
input wire signed [15:0] i_VX;
input wire [31:0] i_BallDelay;
output reg [7:0] o_score_P1;
output reg [7:0] o_score_P2;
output wire o_goal;
output wire [31:0] o_debug;
parameter s_Idle = 3'b000;
parameter s_MovPos = 3'b001;
parameter s_MovNeg = 3'b010;
parameter s_TrigPos = 3'b011;
parameter s_TrigNeg = 3'b100;
parameter s_Goal = 3'b101;
reg [2:0] r_state_Game = s_Idle;

reg [31:0] r_AssignedDelay = 32'd0;
reg [31:0] r_counter_delay = 32'd0;

assign o_goal = (r_state_Game == s_Goal) ? 1'b1:1'b0;

wire PosSpeed;
assign PosSpeed = (i_VX > 16'sd50) ? 1'b1:1'b0;
wire NegSpeed;
assign NegSpeed = (i_VX < -16'sd50) ? 1'b1:1'b0;

assign o_debug = {o_score_P2,o_score_P1,13'd0,r_state_Game};

always@(posedge i_clk)
begin
	if (i_reset == 1'b1)
		begin
			o_score_P1 <= 8'd0;
			o_score_P2 <= 8'd0;
			r_state_Game <= s_Idle;
		end
	else
		begin
			case (r_state_Game)
				s_Idle :
					begin
						if (PosSpeed && (i_X < PosTrigX))
							begin
								r_state_Game <= s_MovPos;
							end
						else if (NegSpeed && (i_X > NegTrigX))
							begin
								r_state_Game <= s_MovNeg;
							end
						else
							begin
								r_state_Game <= s_Idle;
							end
					end
			
				s_MovPos :
					begin
						if (PosSpeed)
							begin
								if (i_X > PosTrigX)
									begin
										r_state_Game <= s_TrigPos;
										r_counter_delay <= 32'd0;
										r_AssignedDelay <= 29999999*2;
									end
								else
									begin
										r_state_Game <= s_MovPos;
									end
							end
						else
							begin
								r_state_Game <= s_Idle;
							end
					end
					
				s_MovNeg :
					begin
						if (NegSpeed)
							begin
								if (i_X < NegTrigX)
									begin
										r_state_Game <= s_TrigNeg;
										r_counter_delay <= 32'd0;
										r_AssignedDelay <= 29999999*2;
									end
								else
									begin
										r_state_Game <= s_MovNeg;
									end
							end
						else
							begin
								r_state_Game <= s_Idle;
							end
							
					end
					
				s_TrigPos :
					begin
						if (i_VX < 0)
							begin
								r_state_Game <= s_MovNeg;
							end
						else if (r_counter_delay > r_AssignedDelay)
							begin
								r_state_Game <= s_Goal;
								o_score_P1 <= o_score_P1 + 8'd1;
							end
						else
							begin
								r_counter_delay <= r_counter_delay + 32'd1;
							end
					end
					
				s_TrigNeg :
					begin
						if (i_VX > 0)
							begin
								r_state_Game <= s_MovPos;
							end
						else if (r_counter_delay > r_AssignedDelay)
							begin
								r_state_Game <= s_Goal;
								o_score_P2 <= o_score_P2 + 8'd1;
							end
						else
							begin
								r_counter_delay <= r_counter_delay + 32'd1;
							end
					end
				
				s_Goal :
					begin
					 r_state_Game = s_Idle;
					end
					
				default :
					 r_state_Game = s_Idle;
					
			endcase
		end
end

endmodule