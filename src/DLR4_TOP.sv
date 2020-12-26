module DLR4_TOP
(

	clk_50,
	tfpPCLK,
	tfpHS,
	tfpDE,
	tfpVS,
	tfpR,
	tfpG,
	tfpB,
	tfpActive,
	vgaHSYNC,
	vgaVSYNC,
	vgaDAC,
	Dir1A,
	Dir2A,
	Dir1B,
	Dir2B,
	PwmA,
	PwmB,
	RX,
	TX,
	QaA,
	QbA,
	QaB,
	QbB,
	SQA,
	SQB,
	JB,
	JR,
	JL,
	StepA,
	StepDirA,
	StepB,
	StepDirB,
	Debug1,
	ZeroADC,
	ZeroAStep,
	ZeroBDC,
	ZeroBStep,
	ScoreA,
	ScoreB
);

//tfp401 connections
input wire tfpVS;
input wire tfpHS;
input wire tfpDE;
input wire tfpPCLK;
input wire tfpActive;
input wire [7:0] tfpR;
input wire [7:0] tfpG;
input wire [7:0] tfpB;
//VGA connections
output wire vgaHSYNC;
output wire vgaVSYNC;
output wire [14:0] vgaDAC;
//UART
input wire RX;
output wire TX;
//DCMotoA
output wire Dir1A;
output wire Dir2A;
output wire PwmA;
input wire QaA;
input wire QbA;
//StepMotoA
output wire StepA;
output wire StepDirA;
input wire SQA;
input wire SQB;
//DCMotoB
output wire Dir1B;
output wire Dir2B;
output wire PwmB;
input wire QaB;
input wire QbB;
//StepMotoB
output wire StepB;
output wire StepDirB;
//Joystick connections
input wire JB;
input wire JR;
input wire JL;
//FPGA clock connections
input wire clk_50;
output wire Debug1;
//Zeroing switches
input wire ZeroADC;
input wire ZeroAStep;
input wire ZeroBDC;
input wire ZeroBStep;
//Scoring display
output reg [6:0] ScoreA = 7'b1111111;
output reg [6:0] ScoreB = 7'b1111111;




always @ (posedge clk_50)
begin
	case (w_P1_Score)
		8'd0 :
				begin
					ScoreA <= 7'b0111111;
				end
		8'd1 :
				begin
					ScoreA <= 7'b0000011;
				end
		8'd2 :
				begin
					ScoreA <= 7'b1110110;
				end
		8'd3 :
				begin
					ScoreA <= 7'b1100111;
				end
		8'd4 :
				begin
					ScoreA <= 7'b1001011;
				end
		8'd5 :
				begin
					ScoreA <= 7'b1101101;
				end
		8'd6 :
				begin
					ScoreA <= 7'b1111001;
				end
		8'd7 :
				begin
					ScoreA <= 7'b0000111;
				end
		8'd8 :
				begin
					ScoreA <= 7'b1111111;
				end
		8'd9 :
				begin
					ScoreA <= 7'b1001111;
				end
		default :
				begin
					ScoreA <= 7'b1001111;
				end
	endcase
	case (w_P2_Score)
		8'd0 :
				begin
					ScoreB <= 7'b0111111;
				end
		8'd1 :
				begin
					ScoreB <= 7'b0000011;
				end
		8'd2 :
				begin
					ScoreB <= 7'b1110110;
				end
		8'd3 :
				begin
					ScoreB <= 7'b1100111;
				end
		8'd4 :
				begin
					ScoreB <= 7'b1001011;
				end
		8'd5 :
				begin
					ScoreB <= 7'b1101101;
				end
		8'd6 :
				begin
					ScoreB <= 7'b1111001;
				end
		8'd7 :
				begin
					ScoreB <= 7'b0000111;
				end
		8'd8 :
				begin
					ScoreB <= 7'b1111111;
				end
		8'd9 :
				begin
					ScoreB <= 7'b1001111;
				end
		default :
				begin
					ScoreB <= 7'b1001111;
				end
	endcase
end





wire camCLK;
assign camCLK = ~tfpPCLK;

assign Debug1 = tCalc;
	
wire unsigned [9:0] pGray;
assign pGray = (tfpR[7:0] + (2*tfpG[7:0]) + tfpB[7:0]);

reg [15:0] SetA = 16'd14000;
reg [15:0] SetB = 16'd4000;

wire signed [7:0] RX_byte;
wire DataReceived;

uart_rx RXpwm(
   .i_Clock(clk_50),
   .i_Rx_Serial(RX),
   .o_Rx_DV(DataReceived),
   .o_Rx_Byte(RX_byte)
	);
reg [7:0] scoretest = 8'd0;
reg XYTxMode = 0;
always @ (posedge DataReceived)
begin
	//XYTxMode<= RX_byte[0];
	//HitVelocity<= RX_byte;
	//XTrigger <= 2*RX_byte;
	//SetB <= {1'd0,RX_byte,7'd0};
	scoretest <= RX_byte;
end	

wire TxDone;
wire TxActive;
reg TxStart = 1'b0;
reg [31:0] TxByte;

uart_tx TXpwm
    (.i_Clock(clk_50),
     .i_Tx_DV(TxStart),
     .i_Tx_Byte(TxByte),
     .o_Tx_Active(TxActive),
     .o_Tx_Serial(TX),
     .o_Tx_Done(TxDone)
     );

wire [7:0] Pout;
wire Edge;
wire AfterEdge;

SobelMask(
	.clock(camCLK),
	.Pin(pGray[9:2]),
	.Pout(Pout),
	.Edge(Edge)
);

parameter TOP = 86;
parameter BOT = 422;
parameter LEFT = 137;
parameter RIGHT = 577;

wire [31:0] hP;
wire [31:0] vP;
wire [15:0] correlation;
wire BPP;
wire corrThresh;
assign corrThresh = (correlation > 128)&&(vP > TOP)&&(vP < BOT)&&(hP > LEFT)&&(hP < RIGHT);

reg [15:0] TopCorr = 0;
reg [31:0] TopX = 0;
reg [31:0] TopY = 0;
reg [15:0] NewPos = 16'd4000;

wire signed [31:0] w;
wire signed [31:0] x;
wire signed [31:0] y;

wire [31:0] Y;
wire [31:0] X;

parameter H11 = -2209180; parameter H12 = 24976; parameter H13 =  104958805;
parameter H21 = 30758; parameter H22 = 2264049; parameter H23 =  -994471039;
parameter H31 = 47; parameter H32 = 27; parameter H33 =  -997170;

assign x = (TopX[9:0]*H11 + TopY[8:0]*H12 + H13);
assign y = (TopX[9:0]*H21 + TopY[8:0]*H22 + H23);
assign w = (TopX[9:0]*H31 + TopY[8:0]*H32 + H33);

wire signed [31:0] remainX;
wire signed [31:0] remainY;
hDiv homogDivY(
	.denom(w),
	.numer(y),
	.quotient(Y),
	.remain(remainY)
	);

hDiv homogDivX(
	.denom(w),
	.numer(x),
	.quotient(X),
	.remain(remainX)
	);
	
reg RedMode = 1'b0;

reg [31:0] CalcX = 0;
reg [31:0] CalcY = 0;
reg signed [31:0] VelX = 0;
reg signed [31:0] VelY = 0;
reg tCalc = 1'b0;
reg [15:0] oldY = 0;
reg signed [15:0] instVelY = 0;

wire [15:0] DebugX;
wire [15:0] DebugY;

reg [31:0] TXcounter = 0;
always@(posedge clk_50)
begin
	if (TXcounter == 4999999)
		begin
			TxByte = {24'd0,HitVelocity};// {CalcY[23:8],State_Y};//w_ScoreDebug;////{r_BallState,AssignedDelay[27:20],DelayCounter[27:20],TrueDelay[27:20]};//{DebugX,DebugY};//{X[15:0],Y[15:0]};
			TxStart = 1'b1;
			TXcounter = 0;
		end
	else
		begin
			TXcounter = TXcounter + 1;
			TxStart = 1'b0;
		end
end
//reg Count = 0;
//reg ResetCount = 0;
//reg [31:0] TXcounter = 0;
//
//always@(posedge clk_50)
//begin
//	if (ResetCount)
//		begin
//			TXcounter = 0;
//		end
//	else if (Count)
//		begin
//			TXcounter = TXcounter + 1;
//		end
//end


always@(posedge camCLK)
begin
	if ((vP == 0)&&(hP == 0))
		begin
			
				if(JRactive == 1'b0)
					begin
						NewPos = MotoPosA + 4000;
					end
				else if (JLactive == 1'b0)
					begin
						NewPos = MotoPosA - 4000;
					end
				else
					begin
						NewPos = MotoPosA;
					end
				
				if (NewPos > 26200)
					begin
						SetA = 26200;
					end
				else if(NewPos < 6000)
					begin
						SetA = 6000;
					end
				else
					begin
						SetA = NewPos;
					end
			
			VelX = State_VX;
			VelY = State_VY;
			CalcX = State_X*256;
			CalcY = State_Y*256;
			
			instVelY = State_Y - oldY;
			oldY = State_Y;
			
			if (State_VX < 0)
				begin
					tCalc = 1'b1;
//					ResetCount = 1'b1;
//					Count = 1'b1;
					
				end
			else
				begin
					SetB = 14000;
				end
			
			
			TopCorr = 128;
			if ((Y < 900)&&(X<1200))
				begin
					iterateKalman = 1;
				end
			//TxByte = {Y[15:0],MotoPosA[15:0]};
			//TxByte = {State_VY,instVelY};
			//TxByte = {State_VX,State_X};
			//TxStart = 1'b1;
		end
	else
		begin
//			ResetCount = 1'b0;
			iterateKalman = 0;
//			TxStart = 1'b0;
			if ((correlation > TopCorr)&&(vP > TOP)&&(vP < BOT)&&(hP > LEFT)&&(hP < RIGHT))
				begin
					TopX = hP;
					TopY = vP;
					TopCorr = correlation;
				end
			if (tCalc == 1'b1)
				begin
					if (((CalcY+VelY) < (815*256))&&((CalcY+VelY) > (55*256)))
						begin
							CalcX = CalcX + VelX;
							CalcY = CalcY + VelY;
						end
					else
						begin
							CalcX = CalcX + VelX;
							CalcY = CalcY - VelY;
							VelY = -1*(VelY/2);
						end
					if (CalcX < (180*256))
						begin
							NewPos = (((CalcY/64)*9)-0);
							if (NewPos > 26200)
								begin
									SetB = 26200;
								end
							else if(NewPos < 6000)
								begin
									SetB = 6000;
								end
							else
								begin
									SetB = NewPos;
								end
							tCalc = 1'b0;
							
							
//							TxByte = TXcounter;
//							TxStart = 1'b1;
						
//							Count = 1'b0;
						end
				end
			else
				begin
//					TxStart = 1'b0;
					
				end
		end
end

reg [15:0] debJB = 16'b1111111111111111;
wire JBactive;
assign JBactive = &debJB[15:0];
reg [15:0] debJR = 16'b1111111111111111;
wire JRactive;
assign JRactive = &debJR[15:0];
reg [15:0] debJL = 16'b1111111111111111;
wire JLactive;
assign JLactive = &debJL[15:0];

reg [31:0] debZADC = 32'b11111111111111111111111111111111;
wire ZADCactive;
assign ZADCactive = |debZADC[31:0];
reg [31:0] debZBDC = 32'b11111111111111111111111111111111;
wire ZBDCactive;
assign ZBDCactive = |debZBDC[31:0];
reg [31:0] debZAStep = 32'b11111111111111111111111111111111;
wire ZAStepactive;
assign ZAStepactive = |debZAStep[31:0];
reg [31:0] debZBStep = 32'b11111111111111111111111111111111;
wire ZBStepactive;
assign ZBStepactive = |debZBStep[31:0];


always@(posedge clk_50)
begin
	debJB[14:0] = debJB[15:1];
	debJB[15] = JB;
	debJL[14:0] = debJL[15:1];
	debJL[15] = JL;
	debJR[14:0] = debJR[15:1];
	debJR[15] = JR;
	debZADC[30:0] = debZADC[31:1];
	debZADC[31] = ZeroADC;
	debZAStep[30:0] = debZAStep[31:1];
	debZAStep[31] = ZeroAStep;
	debZBDC[30:0] = debZBDC[31:1];
	debZBDC[31] = ZeroBDC;
	debZBStep[30:0] = debZBStep[31:1];
	debZBStep[31] = ZeroBStep;
end

TemplateMask(
	.clock(camCLK),
	.Ein(Edge),
	.Eout(AfterEdge),
	.correlation(correlation)
);



VGADriver(
	.clock(~camCLK),
	.Pdisp(Pout),	
	.Edge(Edge),
	.corrThresh(corrThresh),
	.BPP(BPP),
	.tfpDE(tfpDE),
	.tfpVS(tfpVS),
	.tfpHS(tfpHS),
	.vgaOut(vgaDAC),
	.vgaHSYNC(vgaHSYNC),
	.vgaVSYNC(vgaVSYNC),
	.h(hP),
	.v(vP)
);

wire Adone;
wire Bdone;

wire [17:0] DutA;
wire [15:0] MotoPosA;
DCMotoPPController MotA(
	.clk_50(clk_50),
	.Dir1A(Dir1A),
	.Dir2A(Dir2A),
	.DutA(DutA),
	.QA(QaA),
	.QB(QbA),
	.SetA(SetA),
	.PosA(MotoPosA),
	.ZDC(ZADCactive),
	.Zgo(Adone)
);

wire [17:0] DutB;
wire [15:0] MotoPosB;


DCMotoPPController MotB(
	.clk_50(clk_50),
	.Dir1A(Dir1B),
	.Dir2A(Dir2B),
	.DutA(DutB),
	.QA(QaB),
	.QB(QbB),
	.SetA(SetB),
	.PosA(MotoPosB),
	.ZDC(ZBDCactive),
	.Zgo(Bdone)
);

PWM motoAPWM(
	.clk(clk_50),
	.duty(DutA),
	.out(PwmA)
);

PWM motoBPWM(
	.clk(clk_50),
	.duty(DutB),
	.out(PwmB)
);

reg [7:0] HitVelocity = 10;
wire [15:0] StepPosA;
wire signed [39:0] PaddleDelay;

StepMotoController StepContInst(
	.i_clk_50(clk_50),
	.i_Start(KT),
	.i_HitVelocity(HitVelocity),
	.o_Dir(StepDirA),
	.o_Step(StepA),
	//.i_QA(QaA),
	//.i_QB(QbA),
	.o_StepPos(StepPosA),
	.o_tx(PaddleDelay),
	.i_ZDC(ZBDCactive),
	.i_ZStep(ZBStepactive),
	.o_Zdone(Bdone)
);

StepMotoUser StepUserInst(
	.i_clk_50(clk_50),
	.i_Start(JBactive),
	.i_HitVelocity(HitVelocity),
	.o_Dir(StepDirB),
	.o_Step(StepB),
	.i_ZDC(ZADCactive),
	.i_ZStep(ZAStepactive),
	.o_Zdone(Adone)
);

wire [15:0] State_X; 
wire [15:0] State_Y;
wire signed [15:0] State_VX;
wire signed [15:0] State_VY;
reg iterateKalman = 0;
reg resetKalman = 0;
Kalman SimpleKalmanInst(
	.i_Start(iterateKalman),
	.i_Reset(resetKalman),
	.i_Z_X(X[15:0]),
	.i_Z_Y(Y[15:0]),
	.o_State_X(State_X),
	.o_State_Y(State_Y),
	.o_State_VX(State_VX),
	.o_State_VY(State_VY)
);

parameter XTrigger = 300;
parameter XHit = 130;
wire signed [39:0] deltaX;
wire signed [39:0] BallDelay;
wire signed [32:0] TotalDelay;
wire [31:0] TrueDelay;

assign deltaX =(50000000*(XHit - XTrigger));

wire signed [31:0] simplePaddleDelay;
assign simplePaddleDelay = 1000*(20-HitVelocity);

balltimeDiv balltimeDiv(
	.denom(State_VX),
	.numer(deltaX),
	.quotient(BallDelay)
	);
	
assign TotalDelay = BallDelay - PaddleDelay - 2500000;
assign TrueDelay = (BallDelay > (PaddleDelay+2500000)) ? (TotalDelay) : 1000;

wire [31:0] PosBallDelay;
assign PosBallDelay = (BallDelay > 0) ? BallDelay : -BallDelay;

reg r_reset_Score = 1'b0;
wire [7:0] w_P1_Score;
wire [7:0] w_P2_Score;
wire w_Goal;
wire [31:0] w_ScoreDebug;
Scoring
#(.DelayCoeff(4),
  .NegTrigX(16'd230),
  .PosTrigX(16'd1175))
  ScoreInstance
(
	.i_clk(clk_50),
	.i_reset(r_reset_Score),
	.i_X(State_X),
	.i_VX(State_VX),
	.i_BallDelay(PosBallDelay),
	.o_score_P1(w_P1_Score),
	.o_score_P2(w_P2_Score),
	.o_goal(w_Goal),
	.o_debug(w_ScoreDebug)
);

reg KT = 1;
reg [31:0] DelayCounter = 0;
reg [31:0] AssignedDelay = 0;


assign DebugX = (BallDelay > 0) ? (BallDelay/1024) : (-BallDelay/1024);
assign DebugY = (PaddleDelay > 0) ? (PaddleDelay/1024) : (-PaddleDelay/1024);


parameter s_Idle  = 8'b00000001;
parameter s_Delay = 8'b00000010;
parameter s_Hit 	= 8'b00000100;
parameter s_Wait  = 8'b00001000;

reg [7:0] r_BallState = 8'b00000001;

always@(posedge clk_50)
begin
	case (r_BallState)
		
	s_Idle:
		begin
			KT = 1;
			if ((State_VX < 0)&&(State_X < XTrigger))
				begin
					if (TrueDelay < 49999999)
						begin
							AssignedDelay = TrueDelay;
						end
					else
						begin
							AssignedDelay = 49999999;
						end
					DelayCounter = 0;
					r_BallState = s_Delay;
				end
			else
				begin
					r_BallState = s_Idle;
				end
		end
		
	s_Delay:
		begin
			KT = 1;
			if (DelayCounter >= AssignedDelay)
				begin
					r_BallState = s_Hit;
					DelayCounter = 0;
				end
			else
				begin
					DelayCounter = DelayCounter + 1;
					r_BallState = s_Delay;
				end
		end
	
	s_Hit:
		begin
			KT = 0;
			if (DelayCounter < 7)
				begin
					DelayCounter = DelayCounter + 1;
					r_BallState = s_Hit;
				end
			else
				begin
					DelayCounter = 0;
					r_BallState = s_Wait;
				end
		end
	
	s_Wait:
		begin
			KT = 1;
			if (DelayCounter < 49999999)
				begin
					DelayCounter = DelayCounter + 1;
					r_BallState = s_Wait;
				end
			else
				begin
					DelayCounter = 0;
					r_BallState = s_Idle;
				end
		end
	
	
	default:
		begin
			r_BallState = s_Idle;
			KT = 1;
		end
   endcase
	
end

reg [31:0] SCRcounter = 0;
always@(posedge clk_50)
begin
	if (w_Goal == 1'b1)
		begin
			HitVelocity <= 10;
			SCRcounter = 0;
		end
	else
		begin
			if (SCRcounter == 299999999)
				begin
					SCRcounter = 0;
					if (HitVelocity < 18)
						begin
							HitVelocity <= HitVelocity + 1;
					   end
					else
						begin
							HitVelocity <= 18;
						end
				end
			else
				begin
					SCRcounter = SCRcounter + 1;
				end
		end	
end




endmodule
