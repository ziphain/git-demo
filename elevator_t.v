module stimulus;
	parameter cyc = 10;
	parameter delay = 1;

	reg clk, rst_n, f1, f2, f3, u1, d2, u2, d3;
	wire open;
	wire [1:0] floor, direction;
	ELEVATOR elevator01(
			.CLK(clk),
			.RST_N(rst_n),
			.F1(f1),
			.F2(f2),
			.F3(f3),
			.U1(u1),
			.U2(u2),
			.D2(d2),
			.D3(d3),
			.Open(open),
			.Floor(floor),
			.Direction(direction)
	);

	always #(cyc/2) clk = ~clk;

		initial begin
			$fsdbDumpfile("elevator.fsdb");
			$fsdbDumpvars;

			$monitor($time, " CLK=%b RST_N=%b F1=%b F2=%d F3=%d U1=%d U2=%d D2=%d D3=%d Open=%d Floor=%d Direction=%d", clk, rst_n, f1, f2, f3, u1, u2, d2, d3, open, floor, direction);
		end

		initial begin
			clk = 1;
			rst_n = 1;

			#(cyc);
			#(delay) rst_n = 0;
			#(cyc*4) rst_n = 1;
			#(cyc*2);
			f1 = 0; f2 = 0; f3 = 0;
			u1 = 0; u2 = 0; d2 = 0; d3 = 0;

			// case 1: press all btn at same time
			f1 = 1;
			f2 = 1;
			f3 = 1;
			u1 = 1;
			u2 = 1;
			d2 = 1;
			d3 = 1;
			#(cyc);
			f1 = 0;
			f2 = 0;
			f3 = 0;
			u1 = 0;
			u2 = 0;
			d2 = 0;
			d3 = 0;
			// direct move elevator from 3F to 1F 
			#(cyc*8);
			u1 = 1; #(cyc); u1 = 0;
			// direct move elevator from 1F to 3F
			#(cyc*4);
			d3 = 1; #(cyc); d3 = 0;

			// press button for long time, and press other button at same time
			f3= 1; #(cyc*4); f3 = 0; 
			
			#(cyc*6);
			// case 1: press all btn at same time
			f1 = 1;
			f2 = 1;
			f3 = 1;
			u1 = 1;
			u2 = 1;
			d2 = 1;
			d3 = 1;
			#(cyc);
			f1 = 0;
			f2 = 0;
			f3 = 0;
			u1 = 0;
			u2 = 0;
			d2 = 0;
			d3 = 0;
			//
			#(cyc*6); f3 = 1; #(cyc*8); f3 = 0;

			// case 4: press 3F long time, it will go to 3F and open the door for long time
			#(cyc*8); 
			f2 = 1;
			#(cyc*16); 
			f2 = 0;	


			#(cyc*8);
			$finish;
		end
		
endmodule



