module PWM(out, duty, clk);

input wire clk;
input wire [17:0] duty;
output reg out;


reg [17:0] counter = 0;


always @ (posedge clk)
begin
counter <= counter + 1;
if(duty > counter)
	begin
		out <= 1'b1;
	end
else
	begin
		out <= 1'b0;
	end

end

endmodule
