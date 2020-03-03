module skeleton(//key0_l,key1_r,key2_u,key3_d,
	resetn, 
	ps2_clock, ps2_data, 										// ps2 related I/O
	debug_data_in, debug_addr, leds, 						// extra debugging ports
	lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon,// LCD info
	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8,		// seven segements
	VGA_CLK,   														//	VGA Clock
	VGA_HS,															//	VGA H_SYNC
	VGA_VS,															//	VGA V_SYNC
	VGA_BLANK,														//	VGA BLANK
	VGA_SYNC,														//	 SYNC
	VGA_R,   														//	VGA Red[9:0]
	VGA_G,	 														//	VGA Green[9:0]
	VGA_B,															//	VGA Blue[9:0]
	CLOCK_50														// 50 MHz clock
	//data_writeReg,
	//rotateSelect);
	//aluOut);
	//ioOut,
	//rotFlag,
	//q_imem
	//scoreOut,
	//scoreSelect,
	);	
		
	////////////////////////	VGA	////////////////////////////
	//input key0_l,key1_r,key2_u,key3_d;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	input				CLOCK_50;

	////////////////////////	PS2	////////////////////////////
	input 			resetn;
	inout 			ps2_data, ps2_clock;
	
	////////////////////////	LCD and Seven Segment	////////////////////////////
	output 			   lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_data_in;
	output   [11:0]   debug_addr;
	
	//TETRIS
	//output [31:0] data_writeReg;
	//input rotateSelect;
	//output [31:0] aluOut;
	//output [31:0] ioOut;
	//output [31:0] q_imem;
	//output [31:0] scoreOut;
	//input [1:0] rotFlag;
	//wire score;
	//input scoreSelect;

	wire			 clock;
	wire			 lcd_write_en;
	wire 	[31:0] lcd_write_data;
	wire	[7:0]	 ps2_key_data;
	wire			 ps2_key_pressed;
	wire 
	[7:0]	 ps2_out;	
	
	// clock divider (by 5, i.e., 10 MHz)
	pll div(CLOCK_50,inclock);
	assign clock = CLOCK_50;
	
	
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
			
	// keyboard controller
	reg [7:0] test;
	reg down,left,right,up;
	reg temp;
	reg newkey;
	reg state;
	reg slow1, slow2;
	//reg [2:0] flag;
	//reg rotFlag;

		reg tempBit;
		//reg rotateSelect;

	PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	always @(posedge clock)//,state)
	begin
	left <= 1;
	right <= 1;
	up <= 1;
	down <= 1;
	slow1 <=1;
	//rotFlag <=0;
	
	// rotate mux - only send state bit high when y is first entering screen (to reset x and y location to start location)
	//ADDR/640>y-20 && ADDR/640< y
				//if ((ySelect > 9'd0) && (ySelect < 9'd100))
//				if ((ADDR/640 > ySelect  ) && (ADDR/640 < ySelect+ 100))
//				begin
//				state <=1;
//				end
//				else
//				begin
//				state <=0;
//				end
	
		case(ps2_out)
			8'h23: 
			begin
			test = 8'b0110_0100; //D - shape down
			down <= 0;
			end
			8'h24: 
			begin
			test = 8'b0110_0101; //E - rotate
			up <=0;
			//rotFlag <=1;
			state <=1;
			end
			8'h2B: 
			begin
			test = 8'b0110_0110; //F - shape right
			right <=0;
			end
//			8'h4D: test = 8'b0111_0001; P
			8'h1B: 
			begin
			test = 8'b0111_0011; //S - left
			left <=0;
			end	
			8'h3A:
			begin
			test = 8'b0110_1101; //M - used for slow down
			slow1 <=0;
			end
			8'h44:
			begin
			test = 8'b0110_1111; //O - used for slow down
			slow2 <=0;
			end
		endcase
	end
	
	
	// lcd controller
	lcd mylcd(clock, ~resetn, 1'b1, test, lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(test[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(test[7:4], seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	Hexadecimal_To_Seven_Segment hex6(4'b0, seg6);
	Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// some LEDs that you could use for debugging if you wanted
	assign leds = 8'b00101011;
	wire rotate;
	//assign rotate = rotFlag;
	assign rotFlag = recRotate;
	
	
		
	// VGA
	Reset_Delay			r0	(.iCLK(CLOCK_50),.oRESET(DLY_RST)	);
	VGA_Audio_PLL 		p1	(.areset(~DLY_RST),.inclk0(CLOCK_50),.c0(VGA_CTRL_CLK),.c1(AUD_CTRL_CLK),.c2(VGA_CLK)	);
	vga_controller vga_ins(	//.address(ADDR),
									//.yLoc(ySelect),
									.scoreOut(scoreOut),
									.ioOut(ioOut),
									.rotFlag(rotate),
									.recRotate(recRotate),
									.scoreFlag(score),
									.stateVGA(stateVGA),
									.flagOut(flag),//.flag(flagRotate),
									//.ioOut(ioOut),
									.slow1(slow1),
									.slow2(slow2),
									.temp(temp),
									.key0_l(left),
									.key1_r(right),
									.key2_u(up),
									.key3_d(down),
									.iRST_n(DLY_RST),
								 .iVGA_CLK(VGA_CLK),
								 //.iVGA_CLK(CLOCK_50),
								 .oBLANK_n(VGA_BLANK),
								 .oHS(VGA_HS),
								 .oVS(VGA_VS),
								 .b_data(VGA_B),
								 .g_data(VGA_G),
								 .r_data(VGA_R));
								 
	//wire state;
	//wire stateReg;
	//assign stateReg = state;
								 
	// Leighanne Processor Additions
	
		wire q_50,clock_25,clock_12;
		//wire processorClock;
	//assign processorClock = CLOCK_50;
	clockdivider myclocks (clock,reset,q_50,clock_25,clock_12);
	 
	assign imem_clock = clock;
	assign dmem_clock = ~clock_25;//~clock;
	assign processor_clock = processorclock; //12.5 MHz
	assign regfile_clock = clock_12;
	
	// IMEM
	    wire [11:0] address_imem;
    wire [31:0] q_imem;
    imem my_imem(
        .address    (address_imem),            // address of data
        .clock      (imem_clock),                  // you may need to invert the clock
        .q          (q_imem)                   // the raw instruction
    );
	 
	 // DMEM
	 
	     wire [11:0] address_dmem;
    wire [31:0] data;
    wire wren;
    wire [31:0] q_dmem;
    dmem my_dmem(
        .address    (address_dmem),       // address of data
        .clock      (dmem_clock),                  // may need to invert the clock
        .data	    (data),    // data you want to write
        .wren	    (wren),      // write enable
        .q          (q_dmem)    // data from dmem
    );
	
	    /** REGFILE **/
    // Instantiate your regfile
    wire ctrl_writeEnable;
    wire [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	 //wire [4:0] ctrl_readRegA/* ctrl_readRegB*/;
    wire [31:0] data_writeReg;
    wire [31:0] data_readRegA, data_readRegB;
	 wire [31:0] ioOut;
	 wire [31:0] scoreOut;
	 wire [31:0] reg1;
	 
    regfile my_regfile(
        regfile_clock,
        ctrl_writeEnable,
        reset,
        ctrl_writeReg,
        ctrl_readRegA,
        ctrl_readRegB,
        data_writeReg,
        data_readRegA,
        data_readRegB,//
		  ioOut,
		  rotate,
		  scoreOut
//		  ioOut,
//		  flag,
//		  rotFlag,
//		  //score,
//		  scoreFlag,  // temp while testing with waveform
//		  scoreOut,
//		  reg1
    );
	    /** PROCESSOR **/
    processor my_processor(
        // Control signals
        ps2_clock,                          // I: The master clock
        resetn,                          // I: A reset signal

        // Imem
        address_imem,                   // O: The address of the data to get from imem
        q_imem,                         // I: The data from imem

        // Dmem
        address_dmem,                   // O: The address of the data to get or put from/to dmem
        data,                           // O: The data to write to dmem
        wren,                           // O: Write enable for dmem
        q_dmem,                         // I: The data from dmem

        // Regfile
        ctrl_writeEnable,               // O: Write enable for regfile
        ctrl_writeReg,                  // O: Register to write to in regfile
        ctrl_readRegA,                  // O: Register to read from port A of regfile
        ctrl_readRegB,                  // O: Register to read from port B of regfile
        data_writeReg,                  // O: Data to write to for regfile
        data_readRegA,                  // I: Data from port A of regfile
        data_readRegB,                   // I: Data from port B of regfile
		  processorclock,
		  //scoreSelect
		  score
		  //rotateSelect,
		  //aluOut
    );
								 

	
	
endmodule