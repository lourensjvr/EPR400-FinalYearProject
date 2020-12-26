module SobelMask(
	input wire clock,
	input wire [7:0] Pin,
	
	output reg [7:0] Pout,
	
	output wire Edge
	
);

wire empty1;
wire full1;
wire empty2;
wire full2;
wire empty3;
wire full3;
wire empty4;
wire full4;

wire [7:0] Out1;
wire enOut1;
wire [7:0] Out2;
wire enOut2;
wire [7:0] Out3;
wire enOut3;
wire [7:0] Out4;
wire enOut4;

wire [9:0] used1;
wire [9:0] used2;
wire [9:0] used3;
wire [9:0] used4;

reg wrBuf1 = 1;
reg wrBuf2 = 1;
reg wrBuf3 = 1;
reg wrBuf4 = 1;

reg [7:0] ONE_1; 
reg [7:0] ONE_2;
reg [7:0] ONE_3;
reg [7:0] ONE_4;
reg [7:0] ONE_5;

reg [7:0] TWO_1;
reg [7:0] TWO_2;
reg [7:0] TWO_3;
reg [7:0] TWO_4;
reg [7:0] TWO_5;

reg [7:0] THREE_1;
reg [7:0] THREE_2;
reg [7:0] THREE_3;
reg [7:0] THREE_4;
reg [7:0] THREE_5;

reg [7:0] FOUR_1;
reg [7:0] FOUR_2;
reg [7:0] FOUR_3;
reg [7:0] FOUR_4;
reg [7:0] FOUR_5;

reg [7:0] FIVE_1;
reg [7:0] FIVE_2;
reg [7:0] FIVE_3;
reg [7:0] FIVE_4;
reg [7:0] FIVE_5;

reg signed [15:0] Gx;
reg signed [15:0] Gy;

SobelFIFO buf1(
	.clock(clock),
	.data(ONE_5),
	.rdreq(enOut1),
	.wrreq(wrBuf1),
	.empty(empty1),
	.full(full1),
	.q(Out1),
	.usedw(used1));
	
SobelFIFO buf2(
	.clock(clock),
	.data(TWO_5),
	.rdreq(enOut2),
	.wrreq(wrBuf2),
	.empty(empty2),
	.full(full2),
	.q(Out2),
	.usedw(used2));
	
SobelFIFO buf3(
	.clock(clock),
	.data(THREE_5),
	.rdreq(enOut3),
	.wrreq(wrBuf3),
	.empty(empty3),
	.full(full3),
	.q(Out3),
	.usedw(used3));
	
SobelFIFO buf4(
	.clock(clock),
	.data(FOUR_5),
	.rdreq(enOut4),
	.wrreq(wrBuf4),
	.empty(empty4),
	.full(full4),
	.q(Out4),
	.usedw(used4));
	
	
assign enOut1 = (used1 > (793));
assign enOut2 = (used2 > (793));
assign enOut3 = (used3 > (793));
assign enOut4 = (used4 > (793));

assign Edge = ((Gx > 16'sd3000)||(Gx < -16'sd3000)||(Gy > 16'sd3000)||(Gy < -16'sd3000));

always@(posedge clock)
	begin
		ONE_5 = ONE_4;
		ONE_4 = ONE_3;
		ONE_3 = ONE_2;
		ONE_2 = ONE_1;
		ONE_1 = Pin;
	end

always@(posedge clock)
	begin
		TWO_5 = TWO_4;
		TWO_4 = TWO_3;
		TWO_3 = TWO_2;
		TWO_2 = TWO_1;
		TWO_1 = Out1;
	end
	
always@(posedge clock)
	begin
		THREE_5 = THREE_4;
		THREE_4 = THREE_3;
		THREE_3 = THREE_2;
		THREE_2 = THREE_1;
		THREE_1 = Out2;
	end

always@(posedge clock)
	begin
		FOUR_5 = FOUR_4;
		FOUR_4 = FOUR_3;
		FOUR_3 = FOUR_2;
		FOUR_2 = FOUR_1;
		FOUR_1 = Out3;
	end
	
always@(posedge clock)
	begin
		FIVE_5 = FIVE_4;
		FIVE_4 = FIVE_3;
		FIVE_3 = FIVE_2;
		FIVE_2 = FIVE_1;
		FIVE_1 = Out4;
	end
	
always@(posedge clock)
	begin
		Gx <= (4*ONE_4+5*ONE_5+10*TWO_4+8*TWO_5+20*THREE_4+10*THREE_5+10*FOUR_4+8*FOUR_5+4*FIVE_4+5*FIVE_5) - (4*ONE_2+5*ONE_1+10*TWO_2+8*TWO_1+20*THREE_2+10*THREE_1+10*FOUR_2+8*FOUR_1+4*FIVE_2+5*FIVE_1);
		Gy <= (5*ONE_1+8*ONE_2+10*ONE_3+8*ONE_4+5*ONE_5+4*TWO_1+10*TWO_2+20*TWO_3+10*TWO_4+4*TWO_5)-(5*FIVE_1+8*FIVE_2+10*FIVE_3+8*FIVE_4+5*FIVE_5+4*FOUR_1+10*FOUR_2+20*FOUR_3+10*FOUR_4+4*FOUR_5);
		//Gx <= (TWO_4+2*THREE_4+FOUR_4)-(TWO_2+2*THREE_2+FOUR_2);
		//Gy <= (TWO_2+2*TWO_3+TWO_4)-(FOUR_2+2*FOUR_3+FOUR_4);
		Pout <= THREE_3;
	end




	
endmodule