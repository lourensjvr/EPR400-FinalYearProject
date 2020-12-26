module VGADriver(
	input wire clock,
	input wire [7:0] Pdisp,	
	input wire Edge,
	input wire corrThresh,
	input wire BPP,
	input wire tfpDE,
	input wire tfpVS,
	input wire tfpHS,
	
	output reg [14:0] vgaOut,
	output wire vgaHSYNC,
	output wire vgaVSYNC,
	output wire [31:0] h,
	output wire [31:0] v
);

parameter TOP = 85;
parameter BOT = 422;
parameter LEFT = 137;
parameter RIGHT = 577;

assign vgaHSYNC = tfpHS;
assign vgaVSYNC = tfpVS;

reg [31:0] hCount = 0;
reg [31:0] vCount = 0;

assign h = hCount;
assign v = vCount;

reg VScatch = 0;
reg HScatch = 0;

wire FrameStart = (VScatch && tfpDE);
wire RowStart = (HScatch && tfpDE && (~FrameStart));
wire Capture = ((~FrameStart)&&(~RowStart));

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

always@(negedge clock)
begin
	if (~tfpVS)
		begin
			VScatch <= 1;
		end
	if (~tfpHS)
		begin
			HScatch <= 1;
		end
	
		
		
		if (FrameStart)
			begin		
				vgaOut[14:10] <= 5'b11111;//pGray[9:5];//tfpR[7:3];
				vgaOut[9:5] <= 5'b00000;//pGray[9:5];//tfpG[7:3];
				vgaOut[4:0] <= 5'b00000;//pGray[9:5];//tfpB[7:3];
				hCount <= 0;
				vCount <= 0;
				VScatch <= 0;
				HScatch <= 0;
			end
		if (RowStart)
			begin		
				vgaOut[14:10] <= 5'b11111;//pGray[9:5];//tfpR[7:3];
				vgaOut[9:5] <= 5'b00000;//pGray[9:5];//tfpG[7:3];
				vgaOut[4:0] <= 5'b00000;//pGray[9:5];//tfpB[7:3];
				hCount <= 0;
				vCount <= vCount + 1;
				HScatch <= 0;
			end
		if (Capture)
			begin
				hCount <= hCount + 1;
				if(tfpDE)
					begin
						//(MaskArray[hCount][vCount] == 1)&&(hCount>246)&&(hCount<280)&&(vCount>255)&&(vCount<290)
						if((vCount == TOP)||(vCount == BOT)||(hCount == LEFT)||(hCount == RIGHT))
							begin
								vgaOut[14:10] <= 5'b10000;//pGray[9:5];//tfpR[7:3];
								vgaOut[9:5] <= 5'b00000;//pGray[9:5];//tfpG[7:3];
								vgaOut[4:0] <= 5'b00000;//pGray[9:5];//tfpB[7:3];
							end
						else if((vCount == 255)||(vCount == 511)||(hCount == 255)||(hCount == 511))
							begin
								vgaOut[14:10] <= 5'b00000;//pGray[9:5];//tfpR[7:3];
								vgaOut[9:5] <= 5'b00000;//pGray[9:5];//tfpG[7:3];
								vgaOut[4:0] <= 5'b10000;//pGray[9:5];//tfpB[7:3];
							end
						else if(corrThresh == 1)
							begin
								vgaOut[14:10] <= 5'b00000;//pGray[9:5];//tfpR[7:3];
								vgaOut[9:5] <= 5'b11111;//pGray[9:5];//tfpG[7:3];
								vgaOut[4:0] <= 5'b00000;//pGray[9:5];//tfpB[7:3];
							end
						else if(Edge == 1)
							begin
								vgaOut[14:10] <= 5'b11000;//pGray[9:5];//tfpR[7:3];
								vgaOut[9:5] <= 5'b00000;//pGray[9:5];//tfpG[7:3];
								vgaOut[4:0] <= 5'b11000;//pGray[9:5];//tfpB[7:3];
							end
						else
							begin
								vgaOut[14:10] <= Pdisp[7:3];
								vgaOut[9:5] <= Pdisp[7:3];
								vgaOut[4:0] <= Pdisp[7:3];
							end
						
					end
				else
					begin
						vgaOut[14:0] <= 15'b000000000000000;
					end
			end
			
			
			
	
end	

endmodule