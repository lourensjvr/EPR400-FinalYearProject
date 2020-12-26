module Kalman
(
	i_Start,
	i_Reset,
	i_Z_X,
	i_Z_Y,
	o_State_X,
	o_State_Y,
	o_State_VX,
	o_State_VY
);

input wire i_Start;
input wire i_Reset;
input wire [15:0] i_Z_X;
input wire [15:0] i_Z_Y;

output wire [15:0] o_State_X; 
output wire [15:0] o_State_Y;
output wire signed [15:0] o_State_VX;
output wire signed [15:0] o_State_VY;

reg [15:0] r_Z_X;
reg [15:0] r_Z_Y;

reg [15:0] x_1 = 0;
reg [15:0] x_2 = 0;
reg signed [15:0] x_3 = 0;
reg signed [15:0] x_4 = 0;

wire [15:0] c_1;
wire [15:0] c_2;
wire signed [23:0] c_3;
wire signed [23:0] c_4;

wire signed [15:0] Xdiff;
wire signed [15:0] Ydiff;
assign Xdiff = r_Z_X - x_1;
assign Ydiff = r_Z_Y - x_2;

assign c_1 = r_Z_X[15:0];
assign c_2 = r_Z_Y[15:0];
assign c_3 = ((204*x_3) + (2816*Xdiff)); 
assign c_4 = ((204*x_4) + (2816*Ydiff));

assign o_State_X = c_1;
assign o_State_Y = c_2;
assign o_State_VX = c_3/256;
assign o_State_VY = c_4/256;

always@(posedge i_Start, posedge i_Reset)
begin
	if (i_Reset == 1'b1)
		begin
			x_1 = 0;
			x_2 = 0;
			x_3 = 0;
			x_4 = 0;
			r_Z_X = i_Z_X;
			r_Z_Y = i_Z_Y;
		end
	else
		begin
			x_1 = c_1;
			x_2 = c_2;
			x_3 = c_3/256;
			x_4 = c_4/256;
			r_Z_X = i_Z_X;
			r_Z_Y = i_Z_Y;
		end
end


endmodule