module ELEVATOR (
	input wire CLK,
	input wire RST_N,
	input wire U1, U2, D2, D3, F1, F2, F3,
	output reg Open,
	output reg [1:0] Floor,
	output reg [1:0] Direction
);

reg Open_next;
reg U1_btn, U2_btn, D2_btn, D3_btn, F1_btn, F2_btn, F3_btn;
reg [2:0] state, state_next;
reg [1:0] Floor_next;

parameter [2:0] IDLE_F1 = 3'b001;
parameter [2:0] IDLE_F2 = 3'b010;
parameter [2:0] IDLE_F3 = 3'b011;
parameter [2:0] ARRIVE = 3'b100;
parameter [2:0] MOVE = 3'b101;

always @* begin
	if (!RST_N) begin
		F1_btn = 0;
		F2_btn = 0;
		F3_btn = 0;
		U1_btn = 0;
		U2_btn = 0;
		D2_btn = 0;
		D3_btn = 0;
	end else begin
		if (F1 == 1) begin
			F1_btn = F1;
		end 
		if (F2 == 1) begin
			F2_btn = 1;
		end 
		if (F3 == 1) begin
			F3_btn = 1;
		end 
		if (U1 == 1) begin
			U1_btn = 1;
		end 
		if (U2 == 1) begin
			U2_btn = 1;
		end 
		if (D2 == 1) begin
			D2_btn = 1;
		end 
		if (D3 == 1) begin
			D3_btn = 1;
		end
	end
end

// FSM: State register
// D-FF with clk, so using 'Nonblocking'
always @(posedge CLK or negedge RST_N) begin
	if (RST_N == 0) begin
		state <= IDLE_F1;
		Floor <= 2'b01;
		Open <= 0;
	end else begin
		state <= state_next;
		Floor <= Floor_next;
		Open <= Open_next;
	end
end

// FSM: Next State Logic
// combinational so using 'blocking'
always @* begin
//always @(posedge CLK or negedge RST_N) begin
	case (state)
		IDLE_F1: begin
			Open_next = 0;
			Floor_next = 2'b01; // current floor
			if (U1_btn || F1_btn) begin
				Direction = 2'b00; // hold
				state_next = ARRIVE;
			end else if (U2_btn || D2_btn || F2_btn || D3_btn || F3_btn) begin
				Direction = 2'b10; //up
				state_next = MOVE;
			end else begin
				Open_next = 0;
				Direction = 2'b00; //hold
				state_next = IDLE_F1;
			end
		end

		IDLE_F2: begin
			Open_next = 0;
			Floor_next = 2'b10; // current floor
			if (U2_btn || F2_btn || D2_btn) begin
				//Open_next = 1;
				if (D3_btn || F3_btn) begin
					Direction = 2'b10;
					state_next = MOVE;
				end else if (U1_btn || F1_btn) begin
					Direction = 2'b01;
					state_next = MOVE;
				end else begin
					Direction = 2'b00; // hold
					state_next = ARRIVE;
				end
			end else if (U1_btn || F1_btn) begin
				Direction = 2'b01; //down
				state_next = MOVE;
			end else if (D3_btn || F3_btn) begin
				Direction = 2'b10; //up
				state_next = MOVE;
			end else begin
				Direction = 2'b00;
				state_next = IDLE_F2;
			end
		end

		IDLE_F3: begin
			Open_next = 0;
			Floor_next = 2'b11; // current floor
			if (D3_btn || F3_btn) begin
				//Open_next = 1;
				Direction = 2'b00; // hold
				state_next = ARRIVE;
			end else if (U2_btn || D2_btn || F2_btn || F1_btn || U1_btn) begin
				Direction = 2'b01; //down
				state_next = MOVE;
			end else begin
				Direction = 2'b00;
				state_next = IDLE_F3;
			end
		end

		ARRIVE: begin
			//Open = 0;
			if (Floor == 2'b01 && (U1_btn || F1_btn)) begin
				Open_next = 1;
				if (F1) begin
					F1_btn = 1;
					state_next = ARRIVE;
				end else if (U1) begin
					U1_btn = 1;
					state_next = ARRIVE;
				end else begin
					F1_btn = 0; U1_btn = 0;
					state_next = IDLE_F1;
				end
			end else if (Floor == 2'b10 && (U2_btn || D2_btn || F2_btn)) begin
				Open_next = 1;
				if (Direction == 2'b01) begin
					if (F2) begin
						F2_btn = 1;
						state_next = ARRIVE;
					end else if (D2) begin
						D2_btn = 1;
						state_next = ARRIVE;
					end else begin
						F2_btn = 0; D2_btn = 0;
						state_next = IDLE_F2;
					end
				end else if (Direction == 2'b10) begin
					if (F2) begin
						F2_btn = 1;
						state_next = ARRIVE;
					end else if (U2) begin
						U2_btn = 1;
						state_next = ARRIVE;
					end else begin
						F2_btn = 0; U2_btn = 0;
						state_next = IDLE_F2;
					end
				end else begin
					F2_btn = 0; D2_btn = 0; U2_btn = 0;
					state_next = IDLE_F2;
				end
			end else if (Floor == 2'b11 && (D3_btn || F3_btn)) begin
				Open_next = 1;
				if (F3) begin
					F3_btn = 1;
					state_next = ARRIVE;
				end else if (D3) begin
					D3_btn = 1;
					state_next = ARRIVE;
				end else begin
					F3_btn = 0; D3_btn = 0;
					state_next = IDLE_F3;
				end

			end else begin
				if (Floor == 2'b01) begin
					state_next = IDLE_F1;
				end else if (Floor == 2'b10) begin
					state_next = IDLE_F2;
				end else if (Floor == 2'b11) begin
					state_next = IDLE_F3;
				end else begin
					state_next = ARRIVE;
				end
			end
		end

		MOVE: begin
			// if from 1F to 2F, 3F
			if (Floor == 2'b01 && (U2_btn || F2_btn || D2_btn)) begin
				// 1F to 2F, Direction must be up
				Floor_next = 2'b10; // move elevator from 1F to 2F
				//Open_next = 1;
				state_next = ARRIVE;
				// solve: F1_btn, D2_btn, F3_btn press at same time
				if (D2_btn && !F2_btn && !U2_btn && Direction == 2'b10) begin
					// Not yet to destination
					state_next = MOVE;
				end
			end else if (Floor == 2'b01 && (D3_btn || F3_btn)) begin
				// 1F to 3F
				// Not yet to destination
				Floor_next = 2'b10; // move elevator from 1F to 2F
				state_next = MOVE; // still not ARRIVE to 3F
			// if from 2F to 1F, 3F
			end else if (Floor == 2'b10 && Direction == 2'b01) begin
				Floor_next = 2'b01; // move elevator from 2F to 1F
				//Open_next = 1; // and then open the door on 1F
				state_next = ARRIVE;
			end else if (Floor == 2'b10 && Direction == 2'b10) begin
				Floor_next = 2'b11; // move elevator from 2F to 3F
				//Open_next = 1; // and then open the door on 3F
				state_next = ARRIVE;
			// if from 3F to 2F, 1F, Direction must be down
			end else if (Floor == 2'b11 && (U2_btn || F2_btn || D2_btn)) begin
				Floor_next = 2'b10; // move elevator from 3F to 2F
				//Open_next = 1; // and then open the door on 2F
				state_next = ARRIVE;
				// solve: F1_btn, D2_btn, F3_btn press at same time
				if (U2_btn && !F2_btn && !D2_btn && Direction == 2'b01) begin
					// Not yet to destination
					state_next = MOVE;
				end
			end else if (Floor == 2'b11 && (F1_btn || U1_btn)) begin
				// 3F to 1F
				// Not yet to destination
				Floor_next = 2'b10; // move elevator from 3F to 2F
				state_next = MOVE; // still not ARRIVE to 1F
				//state_next = IDLE_F2;
			end else begin
				state_next = IDLE_F1;
			end
		end

		default: begin
			state_next = IDLE_F1;
		end

	endcase
end
endmodule

