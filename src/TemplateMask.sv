module TemplateMask(
	input wire clock,
	input wire Ein,
	
	output wire Eout,
	
	output reg [15:0] correlation
	
);

wire InBuf[30:0];
wire outEnBuf[30:0];
reg wrEnBuf[30:0] = '{default:1};
wire OutBuf[30:0];
wire [9:0] usedBuf[30:0];

TemplateFIFO maskLine[30:0]
	(
	.clock(clock),
	.data(InBuf),
	.rdreq(outEnBuf),
	.wrreq(wrEnBuf),
	.q(OutBuf),
	.usedw(usedBuf)
	); 

wire InReg[31:0];
wire OutReg[31:0];
wire [31:0] Selected[31:0];
										 
reg [31:0] MaskArray[31:0] = '{32'b00000000000000000000000000000000,
										 32'b00000000000000000000000000000000,
										 32'b00000000000000000000000000000000,
										 32'b00000000000000000000000000000000,
										 32'b00000000000001111110000000000000,
										 32'b00000000001111111111110000000000,
										 32'b00000000011111111111111000000000,
										 32'b00000000111111111111111100000000,
										 32'b00000001111111111111111110000000,
										 32'b00000011111111111111111111000000,
										 32'b00000111111111000011111111100000,
										 32'b00000111111100000000111111100000,
										 32'b00000111111000000000011111100000,
										 32'b00001111111000000000011111110000,
										 32'b00001111110000000000001111110000,
										 32'b00001111110000000000001111110000,
										 32'b00001111110000000000001111110000,
										 32'b00001111110000000000001111110000,
										 32'b00001111111000000000011111110000,
										 32'b00000111111000000000011111100000,
										 32'b00000111111100000000111111100000,
										 32'b00000111111111000011111111100000,
										 32'b00000011111111111111111111000000,
										 32'b00000001111111111111111110000000,
										 32'b00000000111111111111111100000000,
										 32'b00000000011111111111111000000000,
										 32'b00000000001111111111110000000000,
										 32'b00000000000001111110000000000000,
										 32'b00000000000000000000000000000000,
										 32'b00000000000000000000000000000000,
										 32'b00000000000000000000000000000000,
										 32'b00000000000000000000000000000000};																					
wire [5:0] RS[31:0];

SelectorRow RowsAdd[31:0]
	(
	.RowIn(Selected),
	.MaskIn(MaskArray),
	.RowSum(RS)
	);

assign correlation = RS[0]+RS[1]+RS[2]+RS[3]+RS[4]+RS[5]+RS[6]+RS[7]+RS[8]+RS[9]+RS[10]+RS[11]+RS[12]+RS[13]+RS[14]+RS[15]+RS[16]+RS[17]+RS[18]+RS[19]+RS[20]+RS[21]+RS[22]+RS[23]+RS[24]+RS[25]+RS[26]+RS[27]+RS[28]+RS[29]+RS[30]+RS[31];
TemplateSHIFT maskREGS[31:0]
	(
	.clock(clock),
	.shiftin(InReg),
	.q(Selected),
	.shiftout(OutReg)
	);

assign InReg[0] = Ein;	
assign InReg[31:1] = OutBuf[30:0];

assign InBuf[30:0] = OutReg[30:0];
assign Eout = OutReg[31];

parameter buffsize = 766;

assign outEnBuf[0] = (usedBuf[0] > buffsize);
assign outEnBuf[1] = (usedBuf[1] > buffsize);
assign outEnBuf[2] = (usedBuf[2] > buffsize);
assign outEnBuf[3] = (usedBuf[3] > buffsize);
assign outEnBuf[4] = (usedBuf[4] > buffsize);
assign outEnBuf[5] = (usedBuf[5] > buffsize);
assign outEnBuf[6] = (usedBuf[6] > buffsize);
assign outEnBuf[7] = (usedBuf[7] > buffsize);
assign outEnBuf[8] = (usedBuf[8] > buffsize);
assign outEnBuf[9] = (usedBuf[9] > buffsize);
assign outEnBuf[10] = (usedBuf[10] > buffsize);
assign outEnBuf[11] = (usedBuf[11] > buffsize);
assign outEnBuf[12] = (usedBuf[12] > buffsize);
assign outEnBuf[13] = (usedBuf[13] > buffsize);
assign outEnBuf[14] = (usedBuf[14] > buffsize);
assign outEnBuf[15] = (usedBuf[15] > buffsize);
assign outEnBuf[16] = (usedBuf[16] > buffsize);
assign outEnBuf[17] = (usedBuf[17] > buffsize);
assign outEnBuf[18] = (usedBuf[18] > buffsize);
assign outEnBuf[19] = (usedBuf[19] > buffsize);
assign outEnBuf[20] = (usedBuf[20] > buffsize);
assign outEnBuf[21] = (usedBuf[21] > buffsize);
assign outEnBuf[22] = (usedBuf[22] > buffsize);
assign outEnBuf[23] = (usedBuf[23] > buffsize);
assign outEnBuf[24] = (usedBuf[24] > buffsize);
assign outEnBuf[25] = (usedBuf[25] > buffsize);
assign outEnBuf[26] = (usedBuf[26] > buffsize);
assign outEnBuf[27] = (usedBuf[27] > buffsize);
assign outEnBuf[28] = (usedBuf[28] > buffsize);
assign outEnBuf[29] = (usedBuf[29] > buffsize);
assign outEnBuf[30] = (usedBuf[30] > buffsize);


endmodule

module SelectorRow(

	input wire [31:0] RowIn,
	
	input wire [31:0] MaskIn,
	output wire [5:0] RowSum
	
	
	
);
wire [31:0] RA;

assign RA = RowIn & MaskIn;

assign RowSum = RA[0]+RA[1]+RA[2]+RA[3]+RA[4]+RA[5]+RA[6]+RA[7]+RA[8]+RA[9]+RA[10]+RA[11]+RA[12]+RA[13]+RA[14]+RA[15]+RA[16]+RA[17]+RA[18]+RA[19]+RA[20]+RA[21]+RA[22]+RA[23]+RA[24]+RA[25]+RA[26]+RA[27]+RA[28]+RA[29]+RA[30]+RA[31];

endmodule