//case(scoreOut%10)
//	//0
//	7'd0:
//	begin
//		for(score_x=21; score_x<=30; score_x = score_x + 1)
//			begin
//				for(score_y=13; score_y<=19; score_y = score_y + 1)
//				begin
//					save[score_x][score_y] <= 1'b0;
//				end
//			end
//		
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][3] <=1'b1;
//			save[score_x][9] <=1'b1;
//		end
//		
//		for(score_y=14; score_y<=18; score_y = score_y + 1)
//		begin
//			save[27][score_y] <= 1'b1;
//			save[30][score_y] <= 1'b1;
//		end
//	end
//	//1
//	7'd1:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][9] <=1'b1;
//		end
//		
//		for(score_y=13; score_y<=18; score_y = score_y + 1)
//		begin
//			save[29][score_y] <= 1'b1;
//		end
//		
//		save[27][15] <= 1'b1;
//		save[28][14] <= 1'b1;	
//	end	
//	
//	//2
//	7'd2:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][3] <=1'b1;
//			save[score_x][6] <=1'b1;
//			save[score_x][9] <=1'b1;
//		end
//		save[30][14] <=1'b1;
//		save[30][15] <=1'b1;
//		save[27][17] <=1'b1;
//		save[27][18] <=1'b1;		
//	end
//	//3
//	7'd3:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//		save[30][14] <=1'b1;
//		save[30][15] <=1'b1;
//		save[30][17] <=1'b1;
//		save[30][18] <=1'b1;		
//	end
//	//4
//	7'd4:
//	begin
//		for(score_y=13; score_y<=19; score_y = score_y + 1)
//		begin
//			save[30][score_y] <= 1'b1;
//		end
//		
//		for(score_y=13; score_y<=16; score_y = score_y + 1)
//		begin
//			save[27][score_y] <= 1'b1;
//		end
//		
//		save[28][16] <= 1'b1;
//		save[29][16] <= 1'b1;
//			
//	end
//	//5
//	7'd5:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//			
//		save[27][14] <= 1'b1;
//		save[27][15] <= 1'b1;
//		save[30][17] <= 1'b1;
//		save[30][18] <= 1'b1;
//	end
//	//6
//	7'd6:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//			
//		save[27][14] <= 1'b1;
//		save[27][15] <= 1'b1;
//		save[27][17] <= 1'b1;
//		save[27][18] <= 1'b1;
//		save[30][17] <= 1'b1;
//		save[30][18] <= 1'b1;
//	end
//	//7
//	7'd7:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//		end
//			
//		for(score_y=14; score_y<=19; score_y = score_y + 1)
//		begin
//			save[30][score_y] <=1'b1;
//		end
//	end
//	
//	//8
//	7'd8:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//		save[27][14] <= 1'b1;
//		save[27][15] <= 1'b1;
//		save[27][17] <= 1'b1;
//		save[27][18] <= 1'b1;
//		
//		save[30][14] <= 1'b1;
//		save[30][15] <= 1'b1;
//		save[30][17] <= 1'b1;
//		save[30][18] <= 1'b1;
//	end
//	
//	//9
//	7'd9:
//	begin
//		for(score_x=27; score_x<=30; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//		save[27][14] <= 1'b1;
//		save[27][15] <= 1'b1;
//		
//		save[30][14] <= 1'b1;
//		save[30][15] <= 1'b1;
//		save[30][17] <= 1'b1;
//		save[30][18] <= 1'b1;
//	end
//	
//	endcase
//	
//	case(scoreOut/10)
//	//0
//	7'd0:
//	begin
//		for(score_x=21; score_x<=24; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//		
//		for(score_y=14; score_y<=18; score_y = score_y + 1)
//		begin
//			save[21][score_y] <= 1'b1;
//			save[24][score_y] <= 1'b1;
//		end
//	end	
//	//1
//	7'd1:
//	begin
//		for(score_x=21; score_x<=24; score_x = score_x + 1)
//		begin
//			save[score_x][19] <=1'b1;
//		end
//		
//		for(score_y=13; score_y<=18; score_y = score_y + 1)
//		begin
//			save[23][score_y] <= 1'b1;
//		end
//		
//		save[21][15] <= 1'b1;
//		save[22][14] <= 1'b1;	
//	end
//	
//	//2
//	7'd2:
//	begin
//		for(score_x=21; score_x<=24; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//		save[24][14] <=1'b1;
//		save[24][15] <=1'b1;
//		save[21][17] <=1'b1;
//		save[21][18] <=1'b1;		
//	end
//	//3
//	7'd3:
//	begin
//		for(score_x=21; score_x<=24; score_x = score_x + 1)
//		begin
//			save[score_x][13] <=1'b1;
//			save[score_x][16] <=1'b1;
//			save[score_x][19] <=1'b1;
//		end
//		save[24][14] <=1'b1;
//		save[24][15] <=1'b1;
//		save[24][17] <=1'b1;
//		save[24][18] <=1'b1;		
//	end
//	endcase