module DCMotoPPController(
	clk_50,
	Dir1A,
	Dir2A,
	DutA,
	QA,
	QB,
	SetA,
	PosA,
	ZDC,
	Zgo
);

input wire clk_50;
output reg Dir1A = 1;
output reg Dir2A = 0;
output reg [17:0] DutA = 0;
input wire QA;
input wire QB;
input wire [15:0] SetA;

output reg [15:0] PosA = 16'd4000;
input wire ZDC;
input wire Zgo;

reg Zeroed = 0;

reg [15:0] PosOldA = 16'd4000;

reg signed [31:0] ErrA = 0;
reg signed [31:0] ErrSA = 0;
reg signed [31:0] SetSA = 0;
reg signed [31:0] SpeedA = 0;

reg [2:0] quadA_delayed, quadB_delayed;
always @(posedge clk_50) quadA_delayed <= {quadA_delayed[1:0], QA};
always @(posedge clk_50) quadB_delayed <= {quadB_delayed[1:0], QB};

wire count_enable = quadA_delayed[1] ^ quadA_delayed[2] ^ quadB_delayed[1] ^ quadB_delayed[2];
wire count_direction = quadA_delayed[1] ^ quadB_delayed[2];

parameter KP = 2;
parameter KS = 6;

parameter Offset = 8000;
parameter Deadzone = 32;
reg [31:0] Compare;
reg [31:0] SampleClock = 0;
always@(posedge clk_50)
begin
	
	if(Zeroed == 1'b0)
		begin
			if (ZDC == 1'b0)
				begin
					Zeroed = 1'b1;
					DutA = 18'b000000000000000000;
					PosA = 16'd4000;
					PosOldA = 16'd4000;
				end
			else
				begin
					DutA = 18'b010000000000000000;
					Dir1A = 0;
					Dir2A = 1;
				end
		end
	else
		begin
		if (Zgo == 1'b1)
		begin
		
	if(SampleClock == 49999)
		begin
			SampleClock = 0;
			
			SpeedA = 10*(PosOldA - PosA);
			PosOldA = PosA;
			ErrA = SetA - PosA;
			
			if(ErrA > Deadzone)
				begin
					SetSA = ErrA*KP + Offset;
				end
			else if (ErrA < -Deadzone)
				begin
					SetSA = ErrA*KP - Offset;
				end
			else
				begin
					SetSA = 0;
				end
				
			ErrSA = SetSA - SpeedA;
			
			if(ErrSA >= 0)
				begin
					Compare = ErrSA*KS;
					if (Compare > 18'b111111111111111111)
						begin
							DutA = 18'b111111111111111111;
						end
					else
						begin
							DutA = ErrSA*KS;
						end
					Dir1A = 1;
					Dir2A = 0;
				end
			else 
				begin
					Compare = (-ErrSA)*KS;
					if (Compare > 18'b111111111111111111)
						begin
							DutA = 18'b111111111111111111;
						end
					else
						begin
							DutA = (-ErrSA)*KS;
						end
					Dir1A = 0;
					Dir2A = 1;
				end
		end
	else
		begin
			SampleClock = SampleClock + 1;
			if(count_enable)
			  begin
				 if(count_direction) PosA=PosA-1; else PosA=PosA+1;
			  end
		end
	end
	end
end

endmodule