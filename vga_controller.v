module vga_controller(scoreOut,
							ioOut,
							rotFlag,
							recRotate,
							scoreFlag,
							stateVGA,
							flagOut,//ioOut,
							slow1,slow2,temp,
							key0_l,key1_r,key2_u,key3_d,iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data);


input [31:0] scoreOut;
input [31:0] ioOut;
output [1:0] rotFlag;
output [1:0] recRotate;
output scoreFlag;
output stateVGA;
output [2:0] flagOut;
//input [31:0] ioOut;	
input slow1,slow2;
input temp;
input iRST_n;
input iVGA_CLK;
input key0_l,key1_r,key2_u,key3_d;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data;                        
///////// ////                     
reg [18:0] ADDR;	//ADDR is the location of x and y coordinate - use assign statements to determine if in specific range 
reg [23:0] bgr_data;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
////
assign rst = ~iRST_n;
video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS));
////
////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cHS==1'b0 && cVS==1'b0)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
end

//////////////////////////
//////INDEX addr.
assign VGA_CLK_n = ~iVGA_CLK;
img_data	img_data_inst (
	.address ( ADDR ),
	.clock ( VGA_CLK_n ),
	.q ( index )
	);
	
/////////////////////////
//////Add switch-input logic here
	
//////Color table output
img_index	img_index_inst (
	.address ( index ),
	.clock ( iVGA_CLK ),
	.q ( bgr_data_raw)
	);	
	

reg [23:0] coloroutput;

reg [9:0] x;
reg [8:0] y;
reg [2:0] flag;
reg [1:0] rotateFlag;
reg [22:0] counter;
reg [5:0] ylen, xlen;
reg [6:0] xstart;
reg [6:0] ystart;

// rotate
reg [1:0] rotateFlagL;
reg [1:0] rotateFlagT;
reg [1:0] rotateFlagZ;
reg changecolor;

// slow down
reg [1:0] slowFlag;

reg [1:0] state;
reg score;

reg[6:0] VGA_score;
integer score_x;
integer score_y;


reg save[32:0][24:0];
reg clear[24:0];
reg[5:0] temp_count[24:0];
 
integer i;
integer j;
integer k;
integer l;

initial begin
x = 10'd100;
y = 9'd0;
VGA_score = -7'b0000001;
rotateFlag = 2'b0;
rotateFlagL = 2'b0;
slowFlag = 2'b0;
changecolor = 0;
for(i=0; i<33; i = i+1)
begin
	for(j=0; j<25; j = j+1)
	begin
		save[i][j] <= 1'b0;
	end
end

for(k=0; k<25; k = k+1)
	begin
		temp_count[k] <= 5'b0;
	end
end

wire ctrl_reset;
assign ctrl_reset = 1'b0; 
wire enable;
assign enable = 1'b1;

reg [9:0] random;
reg storeRotateState;

assign scoreFlag = score;



// update block based on button press
always@(posedge iVGA_CLK)//iVGA_CLK, posedge clock_15)  /25MHz  500k
begin
counter <= counter +1;
if (counter == 23'd5000000)
begin
	if (y < 480)
		begin
		y<=y+20;
		end
		
		for(k=24; k>=1; k=k-1)
	begin
		temp_count[k] <= 6'b0;	
	end
	
	for(j=24; j>=1; j=j-1)
	begin
	if(temp_count[j] == 0 )
		begin
			//clear the score first
			for(score_x=21; score_x<=30; score_x = score_x + 1)
			begin
				for(score_y=3; score_y<=9; score_y = score_y + 1)
				begin
					save[score_x][score_y] <= 1'b0;
				end
			end
			
			VGA_score <= VGA_score + 1'b1;
			score <= 1;
			
			for(l=0; l<20; l =l+1)
			begin
				save[l][j] <= 1'b0;
			end
			
			
			for(k=j-1; k>=1; k=k-1)
			begin
				for(i=0; i<20; i=i+1)
				begin
					save[i][k+1] <= save[i][k];
					score <= 1;
				end
			end
		end
	end
		
end


else begin
//x should go from 0 to 31
//y should go from 1 to 24

case(scoreOut%10)
	//0
	7'd0:
	begin
		for(score_x=21; score_x<=30; score_x = score_x + 1)
			begin
				for(score_y=13; score_y<=19; score_y = score_y + 1)
				begin
					save[score_x][score_y] <= 1'b0;
				end
			end
		
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		
		for(score_y=14; score_y<=18; score_y = score_y + 1)
		begin
			save[27][score_y] <= 1'b1;
			save[30][score_y] <= 1'b1;
		end
	end
	//1
	7'd1:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][19] <=1'b1;
		end
		
		for(score_y=13; score_y<=18; score_y = score_y + 1)
		begin
			save[29][score_y] <= 1'b1;
		end
		
		save[27][15] <= 1'b1;
		save[28][14] <= 1'b1;	
	end	
	
	//2
	7'd2:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		save[30][14] <=1'b1;
		save[30][15] <=1'b1;
		save[27][17] <=1'b1;
		save[27][18] <=1'b1;		
	end
	//3
	7'd3:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		save[30][14] <=1'b1;
		save[30][15] <=1'b1;
		save[30][17] <=1'b1;
		save[30][18] <=1'b1;		
	end
	//4
	7'd4:
	begin
		for(score_y=13; score_y<=19; score_y = score_y + 1)
		begin
			save[30][score_y] <= 1'b1;
		end
		
		for(score_y=13; score_y<=16; score_y = score_y + 1)
		begin
			save[27][score_y] <= 1'b1;
		end
		
		save[28][16] <= 1'b1;
		save[29][16] <= 1'b1;
			
	end
	//5
	7'd5:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
			
		save[27][14] <= 1'b1;
		save[27][15] <= 1'b1;
		save[30][17] <= 1'b1;
		save[30][18] <= 1'b1;
	end
	//6
	7'd6:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
			
		save[27][14] <= 1'b1;
		save[27][15] <= 1'b1;
		save[27][17] <= 1'b1;
		save[27][18] <= 1'b1;
		save[30][17] <= 1'b1;
		save[30][18] <= 1'b1;
	end
	//7
	7'd7:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
		end
			
		for(score_y=14; score_y<=19; score_y = score_y + 1)
		begin
			save[30][score_y] <=1'b1;
		end
	end
	
	//8
	7'd8:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		save[27][14] <= 1'b1;
		save[27][15] <= 1'b1;
		save[27][17] <= 1'b1;
		save[27][18] <= 1'b1;
		
		save[30][14] <= 1'b1;
		save[30][15] <= 1'b1;
		save[30][17] <= 1'b1;
		save[30][18] <= 1'b1;
	end
	
	//9
	7'd9:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		save[27][14] <= 1'b1;
		save[27][15] <= 1'b1;
		
		save[30][14] <= 1'b1;
		save[30][15] <= 1'b1;
		save[30][17] <= 1'b1;
		save[30][18] <= 1'b1;
	end
	
	endcase
	
	case(scoreOut/10)
	//0
	7'd0:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		
		for(score_y=14; score_y<=18; score_y = score_y + 1)
		begin
			save[21][score_y] <= 1'b1;
			save[24][score_y] <= 1'b1;
		end
	end	
	//1
	7'd1:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][19] <=1'b1;
		end
		
		for(score_y=13; score_y<=18; score_y = score_y + 1)
		begin
			save[23][score_y] <= 1'b1;
		end
		
		save[21][15] <= 1'b1;
		save[22][14] <= 1'b1;	
	end
	
	//2
	7'd2:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		save[24][14] <=1'b1;
		save[24][15] <=1'b1;
		save[21][17] <=1'b1;
		save[21][18] <=1'b1;		
	end
	//3
	7'd3:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][13] <=1'b1;
			save[score_x][16] <=1'b1;
			save[score_x][19] <=1'b1;
		end
		save[24][14] <=1'b1;
		save[24][15] <=1'b1;
		save[24][17] <=1'b1;
		save[24][18] <=1'b1;		
	end
	endcase

case(VGA_score%10)
	//0
	7'd0:
	begin
		for(score_x=21; score_x<=30; score_x = score_x + 1)
			begin
				for(score_y=3; score_y<=9; score_y = score_y + 1)
				begin
					save[score_x][score_y] <= 1'b0;
				end
			end
		
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		
		for(score_y=4; score_y<=8; score_y = score_y + 1)
		begin
			save[27][score_y] <= 1'b1;
			save[30][score_y] <= 1'b1;
		end
	end
	//1
	7'd1:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][9] <=1'b1;
		end
		
		for(score_y=3; score_y<=8; score_y = score_y + 1)
		begin
			save[29][score_y] <= 1'b1;
		end
		
		save[27][5] <= 1'b1;
		save[28][4] <= 1'b1;	
	end	
	
	//2
	7'd2:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		save[30][4] <=1'b1;
		save[30][5] <=1'b1;
		save[27][7] <=1'b1;
		save[27][8] <=1'b1;		
	end
	//3
	7'd3:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		save[30][4] <=1'b1;
		save[30][5] <=1'b1;
		save[30][7] <=1'b1;
		save[30][8] <=1'b1;		
	end
	//4
	7'd4:
	begin
		for(score_y=3; score_y<=9; score_y = score_y + 1)
		begin
			save[30][score_y] <= 1'b1;
		end
		
		for(score_y=3; score_y<=6; score_y = score_y + 1)
		begin
			save[27][score_y] <= 1'b1;
		end
		
		save[28][6] <= 1'b1;
		save[29][6] <= 1'b1;
			
	end
	//5
	7'd5:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
			
		save[27][4] <= 1'b1;
		save[27][5] <= 1'b1;
		save[30][7] <= 1'b1;
		save[30][8] <= 1'b1;
	end
	//6
	7'd6:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
			
		save[27][4] <= 1'b1;
		save[27][5] <= 1'b1;
		save[27][7] <= 1'b1;
		save[27][8] <= 1'b1;
		save[30][7] <= 1'b1;
		save[30][8] <= 1'b1;
	end
	//7
	7'd7:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
		end
			
		for(score_y=4; score_y<=9; score_y = score_y + 1)
		begin
			save[30][score_y] <=1'b1;
		end
	end
	
	//8
	7'd8:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		save[27][4] <= 1'b1;
		save[27][5] <= 1'b1;
		save[27][7] <= 1'b1;
		save[27][8] <= 1'b1;
		
		save[30][4] <= 1'b1;
		save[30][5] <= 1'b1;
		save[30][7] <= 1'b1;
		save[30][8] <= 1'b1;
	end
	
	//9
	7'd9:
	begin
		for(score_x=27; score_x<=30; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		save[27][4] <= 1'b1;
		save[27][5] <= 1'b1;
		
		save[30][4] <= 1'b1;
		save[30][5] <= 1'b1;
		save[30][7] <= 1'b1;
		save[30][8] <= 1'b1;
	end
	
	endcase
	
	case(VGA_score/10)
	//0
	7'd0:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		
		for(score_y=4; score_y<=8; score_y = score_y + 1)
		begin
			save[21][score_y] <= 1'b1;
			save[24][score_y] <= 1'b1;
		end
	end	
	//1
	7'd1:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][9] <=1'b1;
		end
		
		for(score_y=3; score_y<=8; score_y = score_y + 1)
		begin
			save[23][score_y] <= 1'b1;
		end
		
		save[21][5] <= 1'b1;
		save[22][4] <= 1'b1;	
	end
	
	//2
	7'd2:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		save[24][4] <=1'b1;
		save[24][5] <=1'b1;
		save[21][7] <=1'b1;
		save[21][8] <=1'b1;		
	end
	//3
	7'd3:
	begin
		for(score_x=21; score_x<=24; score_x = score_x + 1)
		begin
			save[score_x][3] <=1'b1;
			save[score_x][6] <=1'b1;
			save[score_x][9] <=1'b1;
		end
		save[24][4] <=1'b1;
		save[24][5] <=1'b1;
		save[24][7] <=1'b1;
		save[24][8] <=1'b1;		
	end
	endcase

for(j=24; j>=1; j=j-1)
begin
		
	for(i=0; i<20; i=i+1)
	begin
		if( ~save[i][j] )
		begin
			temp_count[j] <= temp_count[j] + 1'b1; 
		end		
	end
	
end
case(flag)
		3'b000:
		begin
		if (y == 480 || save[x/20][y/20+1] == 1 || save[x/20+1][y/20+1] == 1)
			begin
				save[x/20][y/20] <= 1'b1;
				save[x/20+1][y/20] <= 1'b1;
				save[x/20][y/20-1] <= 1'b1;
				save[x/20+1][y/20-1] <= 1'b1;
				//x <= 10'd300;
				x <= ((x*6)%300)+20;
				y <= 9'd0;
				flag <= flag + 1'b1;
			end
		end
		
		3'b001:
		begin
		case(rotateFlag)
			2'b00:
			begin
			if (y == 480 || save[x/20][y/20+1] ==1 || save[x/20+1][y/20+1] ==1 || save[x/20+2][y/20+1] ==1 || save[x/20+3][y/20+1] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20+1][y/20] <= 1'b1;
					save[x/20+2][y/20] <= 1'b1;
					save[x/20+3][y/20] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlag <= 0;
				end
			end

		
			2'b01:
			begin
			if (y == 420 || save[x/20][y/20+4] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20][y/20+1] <= 1'b1;
					save[x/20][y/20+2] <= 1'b1;
					save[x/20][y/20+3] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlag <= 0;
				end
			end
			
			2'b10:
			begin
			if (y == 480 || save[x/20-3][y/20+1] ==1 || save[x/20-2][y/20+1] ==1 || save[x/20-1][y/20+1] ==1 || save[x/20][y/20+1] ==1)
				begin
					save[x/20-3][y/20] <= 1'b1;
					save[x/20-2][y/20] <= 1'b1;
					save[x/20-1][y/20] <= 1'b1;
					save[x/20][y/20] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlag <= 0;
				end
			end
			
			2'b11:
			begin
			if (y == 480 || save[x/20][y/20+1] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20][y/20-1] <= 1'b1;
					save[x/20][y/20-2] <= 1'b1;
					save[x/20][y/20-3] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlag <= 0;
				end
			end
		
		endcase
		end
		
		3'b010:
		begin
		case(rotateFlagL)
		2'b00:
		begin
			if (y == 480 || save[x/20][y/20+1] ==1 || save[x/20+1][y/20+1] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20+1][y/20] <= 1'b1;
					save[x/20][y/20-1] <= 1'b1;
					save[x/20][y/20-2] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlagL <= 0;
				end
		end
		
		2'b01:
		begin
			if (y == 460 || save[x/20][y/20+2] ==1 || save[x/20+1][y/20] ==1 || save[x/20+2][y/20] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20][y/20+1] <= 1'b1;
					save[x/20+1][y/20] <= 1'b1;
					save[x/20+2][y/20] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlagL <= 0;
				end
		end
		
		2'b10:
		begin
			if (y == 440 || save[x/20-1][y/20+1] ==1 || save[x/20][y/20+3] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20-1][y/20] <= 1'b1;
					save[x/20][y/20+1] <= 1'b1;
					save[x/20][y/20+2] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlagL <= 0;
				end
		end
		
		2'b11:
		begin
			if (y == 480 || save[x/20-2][y/20+1] ==1 || save[x/20-1][y/20+1] ==1 || save[x/20][y/20+1] ==1)
				begin
					save[x/20-2][y/20] <= 1'b1;
					save[x/20-1][y/20] <= 1'b1;
					save[x/20][y/20] <= 1'b1;
					save[x/20][y/20-1] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlagL <= 0;
				end
		end
		
		endcase
		end
		
		3'b011:
		begin
		case(rotateFlagZ)
		2'b00:
		begin
			if(y==480 || save[x/20][y/20+1] ==1 || save[x/20+1][y/20+1] ==1 || save[x/20+2][y/20] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20+1][y/20] <= 1'b1;
					save[x/20+1][y/20-1] <= 1'b1;
					save[x/20+2][y/20-1] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlagZ <= 0;
				end
		end	
		
		2'b01:
		begin
			if(y==440 || save[x/20][y/20+2] ==1 || save[x/20+1][y/20+3] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20][y/20+1] <= 1'b1;
					save[x/20+1][y/20+1] <= 1'b1;
					save[x/20+1][y/20+2] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= flag + 1'b1;
					rotateFlagZ <= 0;
				end
		end	
		
		2'b10:
			begin
				if(y==440 || save[x/20-2][y/20+3] ==1 || save[x/20-1][y/20+3] ==1 || save[x/20][y/20+2] ==1)
					begin
						save[x/20-2][y/20+2] <= 1'b1;
						save[x/20-1][y/20+1] <= 1'b1;
						save[x/20-1][y/20+2] <= 1'b1;
						save[x/20][y/20+1] <= 1'b1;
						//x <= 10'd300;
						x <= ((x*6)%300)+20;
						y <= 9'd0;
						flag <= flag + 1'b1;
						rotateFlagZ <= 0;
					end
			end
			
		2'b11:
			begin
				if(y==460 || save[x/20-2][y/20+1] ==1 || save[x/20-1][y/20+2] ==1)
					begin
						save[x/20-2][y/20-1] <= 1'b1;
						save[x/20-2][y/20] <= 1'b1;
						save[x/20-1][y/20] <= 1'b1;
						save[x/20-1][y/20+1] <= 1'b1;
						//x <= 10'd300;
						x <= ((x*6)%300)+20;
						y <= 9'd0;
						flag <= flag + 1'b1;
						rotateFlagZ <= 0;
					end
			end
		
		endcase
		end
		
		3'b100:
		begin
		case(rotateFlagT)
		2'b00:
		begin
			if(y==480 || save[x/20][y/20+1] ==1 || save[x/20+1][y/20+1] ==1 || save[x/20+2][y/20+1] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20+1][y/20] <= 1'b1;
					save[x/20+1][y/20-1] <= 1'b1;
					save[x/20+2][y/20] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= 3'b000;
					rotateFlagT <= 0;
				end
		end
	
		2'b01:
		begin
			if(y==480 || save[x/20][y/20+1] ==1 || save[x/20+1][y/20] ==1)
				begin
					save[x/20][y/20] <= 1'b1;
					save[x/20][y/20-1] <= 1'b1;
					save[x/20][y/20-2] <= 1'b1;
					save[x/20+1][y/20-1] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= 3'b000;
					rotateFlagT <= 0;
				end
		end
		
		2'b10:
		begin
			if(y==440 || save[x/20-3][y/20+2] ==1 || save[x/20-2][y/20+3] ==1 || save[x/20-1][y/20+2] ==1)
				begin
					save[x/20-3][y/20+1] <= 1'b1;
					save[x/20-2][y/20+1] <= 1'b1;
					save[x/20-2][y/20+2] <= 1'b1;
					save[x/20-1][y/20+1] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= 3'b000;
					rotateFlagT <= 0;
				end
		end
		
		2'b11:
		begin
			if(y==480 || save[x/20-2][y/20] ==1 || save[x/20-1][y/20+1] ==1)
				begin
					save[x/20-2][y/20-1] <= 1'b1;
					save[x/20-1][y/20-2] <= 1'b1;
					save[x/20-1][y/20-1] <= 1'b1;
					save[x/20-1][y/20] <= 1'b1;
					//x <= 10'd300;
					x <= ((x*6)%300)+20;
					y <= 9'd0;
					flag <= 3'b000;
					rotateFlagT <= 0;
				end
		end
		
		endcase
		end
endcase
//begin

if(key0_l == 0)
	begin
	// square
	if (flag == 0)
		if(x>0)
			begin
			if(save[x/20-1][y/20]==0&&save[x/20-1][y/20-1]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
	// rect
	if (flag == 1)
	begin
	if (rotateFlag == 2'b00)
		begin
		if (x>0)
			begin
			if(save[x/20-1][y/20]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
		
	if (rotateFlag == 2'b01)
		begin
		if (x>0)
			begin
			if(save[x/20-1][y/20]==0 && save[x/20-1][y/20+1]==0 && save[x/20-1][y/20+2]==0 && save[x/20-1][y/20+3]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
		
	if (rotateFlag == 2'b10)
		begin
		if (x>60)
			begin
			if(save[x/20-4][y/20]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=60;
		end
	
	if (rotateFlag == 2'b11)
		begin
		if (x>0)
			begin
			if(save[x/20-1][y/20]==0 && save[x/20-1][y/20-1]==0 && save[x/20-1][y/20-2]==0 && save[x/20-1][y/20-3]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
	
	end
	// L
	if (flag == 2)
	begin
	if (rotateFlagL == 2'b00)
		begin
		if (x>0)
			begin
			if(save[x/20-1][y/20]==0&&save[x/20-1][y/20-1]==0&&save[x/20-1][y/20-2]==0)
				begin
					x<=x-20;
				end
			end
		else 
			x<=0;
		end
	
	if (rotateFlagL == 2'b01)
		begin
		if (x>0)
			begin
			if(save[x/20-1][y/20]==0&&save[x/20-1][y/20+1]==0)
				begin
					x<=x-20;
				end
			end
		else 
			x<=0;
		end
	
	
	if (rotateFlagL == 2'b10)
		begin
		if (x>20)
			begin
			if(save[x/20-2][y/20]==0&&save[x/20-1][y/20+1]==0&&save[x/20-1][y/20+2]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=20;
		end
		
	if (rotateFlagL == 2'b11)
		begin
		if (x>40)
			begin
			if(save[x/20-3][y/20]==0&&save[x/20-1][y/20-1]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=40;
		end
	end
	// Z
	if (flag ==3)
	begin
	if(rotateFlagZ == 2'b0)
		begin
		if(x>0)
			begin
			if(save[x/20-1][y/20]==0 && save[x/20][y/20-1]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
	
	if(rotateFlagZ == 2'b01)
		begin
		if(x>0)
			begin
			if(save[x/20-1][y/20]==0 && save[x/20-1][y/20+1]==0 && save[x/20][y/20+2]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
		
	if(rotateFlagZ == 2'b10)
		begin
		if (x>40)
			begin
			if(save[x/20-2][y/20+1]==0 && save[x/20-3][y/20+2]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=40;
		end
	end
	
	if(rotateFlagZ == 2'b11)
		begin
		if(x>40)
			begin
			if(save[x/20-3][y/20-1]==0 && save[x/20-3][y/20]==0 && save[x/20-2][y/20+1]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=40;
		end
	// T
	if (flag ==4)
	begin
	if(rotateFlagT == 2'b0)
		begin
		if(x>0)
			begin
			if(save[x/20-1][y/20]==0 && save[x/20][y/20-1]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
		
	if(rotateFlagT == 2'b01)
		begin
		if(x>0)
			begin
			if(save[x/20-1][y/20]==0 && save[x/20-1][y/20-1]==0 && save[x/20-1][y/20-2]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=0;
		end
		
	if(rotateFlagT == 2'b10)
		begin
		if(x>60)
			begin
			if(save[x/20-4][y/20+1]==0 && save[x/20-3][y/20+2]==0)
				begin
					x<=x-20;
				end
			end
		else
			x<=60;
		end
		
	if(rotateFlagT == 2'b11)
		begin
		if(x>40)
			begin
			if(save[x/20-2][y/20-2]==0 && save[x/20-3][y/20-1]==0 && save[x/20-2][y/20]==0)
				begin
					x<=x-20;
				end
			end
		else 
			x<=40;
		end
	end
	
	end	//final end

else if(key1_r == 0)
	begin
	
	if(flag == 0)
	begin 
		if (x<360)
			 begin
			 if(x<360 && save[x/20+2][y/20]==0 && save[x/20+2][y/20-1]==0)
			 x <= x+ 20;
			 end
		else
			x<=360;
	end
	// rect
	if (flag == 1)
	begin
	
	if (rotateFlag == 2'b0)
		begin
		if (x<320)
			begin
			if(x<320 && save[x/20+4][y/20]==0)
			x<=x+20;
			end
		else 
			x<=320;
		end
		
	if (rotateFlag == 2'b01)
		begin
		if (x<380)
			begin
			if(x<380 && save[x/20+1][y/20]==0 && save[x/20+1][y/20+1]==0 && save[x/20+1][y/20+2]==0 && save[x/20+1][y/20+3]==0)
				x<=x+20;
			end
		else
			x<=380;
		end		
	//end
	
	if (rotateFlag == 2'b10)
		begin
		if (x<380)
			begin
			if(x<380 && save[x/20+1][y/20]==0)
				x<=x+20;
			end
		else 
			x<=380;
		end
	
	if (rotateFlag == 2'b11)
		begin
		if (x<380)
			begin
			if(x<380 && save[x/20+1][y/20]==0 && save[x/20+1][y/20-1]==0 && save[x/20+1][y/20-2]==0 && save[x/20+1][y/20-3]==0)
				x<=x+20;
			end
		else
			x<=380;
		end		
	end
	
	// L
	if (flag == 2)
	begin
	if (rotateFlagL == 2'b0)
		begin
		if (x<360)
			begin
			if(x<360 && save[x/20+2][y/20]==0 && save[x/20+1][y/20-1]==0 && save[x/20+1][y/20-2]==0)
				x<=x+20;
			end
		else
			x<=360;
		end
		
	if (rotateFlagL == 2'b01)
		begin
		if (x<340)
			begin
			if(x<340 && save[x/20+3][y/20]==0 && save[x/20+1][y/20+1]==0)
				x<=x+20;
			end
		else
			x<=340;
		end
		
	if (rotateFlagL == 2'b10)
		begin
		if (x<380)
			begin
			if(x<380 && save[x/20+1][y/20]==0 && save[x/20+1][y/20+1]==0 && save[x/20+1][y/20+2]==0)
				x<=x+20;
			end
		else
			x<=380;
		end
	
	if (rotateFlagL == 2'b11)
		begin
		if (x<380)
			begin
			if(x<380 && save[x/20+1][y/20]==0 && save[x/20+1][y/20-1]==0)
				x<=x+20;
			end
		else
			x<=380;
		end
		
	end
	
	// Z
	if (flag == 3)
	begin
	
	if (rotateFlagZ == 2'b00)
		begin
		if(x<340)
			begin
			if(x<340 && save[x/20+2][y/20]==0 && save[x/20+3][y/20-1]==0)
				x<=x+20;
			end
		else
			x<=340;
		end
	
	if (rotateFlagZ == 2'b01)
		begin
		if (x<360)
			begin
			if(x<360 && save[x/20+1][y/20]==0 && save[x/20+2][y/20+1]==0 && save[x/20+2][y/20+2]==0)
				x<=x+20;
			end
		else
			x<=360;
		end
		
	if (rotateFlagZ == 2'b10)
		begin
		if(x<380)
			begin
			if(x<380 && save[x/20+1][y/20+1]==0 && save[x/20][y/20+2]==0)
				x<=x+20;
			end
		else
			x<=380;
		end
		
	if(rotateFlagZ == 2'b11)
		begin
		if (x<400)
			begin
			if(x<400 && save[x/20-1][y/20-1]==0 && save[x/20][y/20]==0 && save[x/20][y/20+1]==0)
				x<=x+20;
			end
		else
			x<=400;
		end

	end
	// T
	if (flag == 4)
	begin
	if(rotateFlagT == 2'b00)
		begin
		if(x<340)
			begin
			if(x<340 && save[x/20+3][y/20]==0 && save[x/20+2][y/20-1]==0)
				x<=x+20;
			end
		else
			x<=340;
		end
		
	if(rotateFlagT == 2'b01)
		begin
		if(x<360)
			begin
			if(x<360 && save[x/20+1][y/20-2]==0 && save[x/20+2][y/20-1]==0 && save[x/20+1][y/20]==0)
				x<=x+20;
			end
		else
			x<=360;
		end
		
	if(rotateFlagT == 2'b10)
		begin
		if(x<400)
			begin
			if(x<400 && save[x/20][y/20+1]==0 && save[x/20-1][y/20+2]==0)
				x<=x+20;
			end
		else
			x<=400;
		end
		
	if(rotateFlagT == 2'b11)
		begin
		if(x<400)
			begin
			if(x<400 && save[x/20][y/20]==0 && save[x/20][y/20-1]==0 && save[x/20][y/20-2]==0)
				x<=x+20;
			end
		else
			x<=400;
		end
		
	end
	
	end		// final end	
else if(key2_u == 0)  // key used to rotate
begin
		// rect
		if (rotateFlag<4)
			begin
				if (((x<60) && (rotateFlag == 2'b01)) || ((x>320) && (rotateFlag == 2'b11)))
					rotateFlag <= rotateFlag;
				else
					rotateFlag <= rotateFlag + 1'b1;	
						state <=1;
			end
		else
			rotateFlag <= 2'b0;
			
		// L	
		if (rotateFlagL<4)
			begin
			if (((x < 20) && (rotateFlagL == 2'b01)) || ((x < 40) && (rotateFlagL == 2'b10)) || ((x>340) && (rotateFlagL == 2'b0)) || ((x>360) && (rotateFlagL == 2'b11)))
			rotateFlagL <= rotateFlagL;
			else
			rotateFlagL <= rotateFlagL + 1'b1;
			state <=1;
			end
		else
			rotateFlagL <= 2'b0;
			
		// T
		if (rotateFlagT<4)		
			begin
			if (((x<60)&&(rotateFlagT == 2'b01)) || ((x>340) && (rotateFlagT == 2'b11)))
				rotateFlagT <= rotateFlagT;
			else
				rotateFlagT <= rotateFlagT + 1'b1;
				state <=1;
			end
		else
			rotateFlagT <= 2'b0;
		
		// Z
		if (rotateFlagZ<4)
			begin
			if(((x > 340) && (rotateFlagZ == 2'b11))|| ((x<40) && (rotateFlagZ == 2'b01)))
				rotateFlagZ <= rotateFlagZ;
			else
				rotateFlagZ <= rotateFlagZ + 1'b1;
				state<=1;
			end
		else
			rotateFlagZ <= 2'b0;
end

else if(key3_d == 0)
	begin
	if (y < 480)
		begin
		y<=y+20;
		end
	end
end
end
//end

assign flagOut = flag;
//assign yLoc = y;
//assign address = ADDR;
assign stateVGA = state;
assign scoreFlag = score;
//assign rotFlag = rotateFlag || rotateFlagZ || rotateFlagT || rotateFlagL;
assign recRotate = rotateFlag;
assign rotFlag[1:0] = state[1:0];


always@(posedge iVGA_CLK,negedge iRST_n)
if(~iRST_n)
coloroutput<=0;
else
begin


case (flag)
	3'b000: //square 
	//if(storeRotateState == 1)
	begin
		if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-40 && ADDR/640< y - 20))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-40 && ADDR/640< y - 20)) && (y <= 480))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	
	3'b001: // long rectangle
	begin
	if(rotateFlag ==2'b00)
	//if (ioOut[31:0] == 32'b00)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+40 && ADDR%640< x+60) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+60 && ADDR%640< x+80) && (ADDR/640>y-20 && ADDR/640< y)) && (y <= 480))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlag == 2'b01 && ioOut[31:0] == 32'b01)
	//if (ioOut[31:0] == 32'b01)
	begin
		if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y+20 && ADDR/640< y+40))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y+40 && ADDR/640< y+60)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlag == 2'b10)
	//if (ioOut[31:0] == 32'b10)
	begin
		if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x-60 && ADDR%640< x-40) && (ADDR/640>y-20 && ADDR/640< y)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if(rotateFlag == 2'b11)
	//if (ioOut[31:0] == 32'b11)
	begin
		if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-40 && ADDR/640< y-20))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-60 && ADDR/640< y-40))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-80 && ADDR/640< y-60)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	end
		
	3'b010: // L
	begin
	if (rotateFlagL == 2'b00)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-40 && ADDR/640< y-20))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-60 && ADDR/640< y-40)) && (y <= 480))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagL == 2'b01 && ioOut[31:0] == 32'b01)
	//if (ioOut[31:0] == 32'b01)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+40 && ADDR%640< x+60) && (ADDR/640>y-20 && ADDR/640< y)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagL == 2'b10)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y+20 && ADDR/640< y+40)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagL == 2'b11)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-40 && ADDR/640< y-20))
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y-20 && ADDR/640< y)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	end
	
	3'b011: // z
	begin
	if (rotateFlagZ == 2'b00)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-40 && ADDR/640< y-20))
		|| ((ADDR%640 > x+40 && ADDR%640< x+60) && (ADDR/640>y-40 && ADDR/640< y-20)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagZ == 2'b01 && ioOut[31:0] == 32'b01)
	//if (ioOut[31:0] == 32'b01)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y+20 && ADDR/640< y+40)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagZ == 2'b10)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y && ADDR/640< y+20)) 
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y+20 && ADDR/640< y+40))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y+20 && ADDR/640< y+40)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagZ == 2'b11)
	begin
	if(((ADDR%640 > x-20&& ADDR%640< x) && (ADDR/640>y && ADDR/640< y+20)) 
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y-40 && ADDR/640< y-20)))
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	end
	
	3'b100: // T
	begin
	if (rotateFlagT == 2'b00)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+40 && ADDR%640< x+60) && (ADDR/640>y-20 && ADDR/640< y))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-40 && ADDR/640< y - 20))
		)
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagT == 2'b01 && ioOut[31:0] == 32'b01)
	//if (ioOut[31:0] == 32'b01)
	begin
	if(((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-40 && ADDR/640< y-20))
		|| ((ADDR%640 > x && ADDR%640< x+20) && (ADDR/640>y-60 && ADDR/640< y-40))
		|| ((ADDR%640 > x+20 && ADDR%640< x+40) && (ADDR/640>y-40 && ADDR/640< y-20)) // hump
		)
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagT == 2'b10)
	begin
	if(((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y && ADDR/640< y+20)) 
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x-60 && ADDR%640< x-40) && (ADDR/640>y && ADDR/640< y+20))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y+20 && ADDR/640< y+40))
		)
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	if (rotateFlagT == 2'b11)
	begin
	if(((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-20 && ADDR/640< y)) 
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-40 && ADDR/640< y-20))
		|| ((ADDR%640 > x-20 && ADDR%640< x) && (ADDR/640>y-60 && ADDR/640< y-40))
		|| ((ADDR%640 > x-40 && ADDR%640< x-20) && (ADDR/640>y-40 && ADDR/640< y-20))
		)
		begin
		coloroutput[23:0] <=24'b0;
		end
	else
		begin
		coloroutput[23:0] <= (save[ADDR%640/20][ADDR/640/20+1]==1) ? 24'b0: background_color;
		end
	end
	end
endcase

end
// Background color
reg[23:0] background_color;

always@(posedge iVGA_CLK)
begin
   if(ADDR%640 >= 0 && ADDR%640 < 400 && ADDR/640 >= 0 && ADDR/640 <=480)
      begin
      background_color[23:0] <= 24'hffa500;
      end
      else
      begin
      background_color[23:0] <=  bgr_data_raw;
      end
end

//////
//////latch valid data at falling edge;
always@(posedge VGA_CLK_n) bgr_data <= coloroutput;
assign b_data = bgr_data[23:16];
assign g_data = bgr_data[15:8];
assign r_data = bgr_data[7:0]; 
///////////////////
//////Delay the iHD, iVD,iDEN  one clock cycle;
always@(negedge iVGA_CLK)
begin
  oHS<=cHS;
  oVS<=cVS;
  oBLANK_n<=cBLANK_n;
end

endmodule

 	













