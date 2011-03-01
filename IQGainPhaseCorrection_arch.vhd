architecture IQGainPhaseCorrection_beh of IQGainPhaseCorrection is

	--signal declarations

	--phase error estimate accumulator
	signal reg_1:signed(width downto 0) := (others => '0');

	--gain error estimate accumulator
	signal reg_2:signed(width downto 0) := (0 => '1', others => '0');
	
	--Phase Offset Adjustment Applied to y1
	signal y2:signed(width downto 0) := (others => '0');

	--Gain and Phase Adjustment Applied	to y1
	signal y3:signed(2*width+1 downto 0) := (others => '0');	
	
	signal x1y2:signed(2*width+1 downto 0):= (others => '0');
	signal mu_1:signed(width downto 0):= (others => '0');
	signal x1x1y3y3:signed(width downto 0):= (others => '0');
	signal mu_2:signed(width downto 0):= (others => '0');
	
	signal reg_1x1:signed(2*width+1 downto 0):= (others => '0');
	signal y3y3: signed(4*width+3 downto 0):= (others => '0');
	signal x1x1: signed(2*width+1 downto 0):= (others => '0');
	
begin

    correction : process (clk) is	
		begin
		
   		if clk'event and clk = '1' then
		
		--phase error estimate, step size set to 0.000244
		--which is achieved with a shift right by 12.
		reg_1x1 <= reg_1 * x1; --clock 0
		y2 <= y1 - reg_1x1(2*width+1 downto width+1); --clock 1
		x1y2 <= x1 * y2; --clock 2
		mu_1 <= shift_right(x1y2(2*width+1 downto width+1),12); --step size applied.	  --clock 3
		reg_1 <= reg_1 + mu_1; 	 --clock 4
		phase_error <= reg_1;  --update phase error estimate.	 --clock 5
		
		--gain error estimate, step size set to 0.000122
		--which is achieved with a shift right by 13.
		y3 <= y2 * reg_2;	   --clock 0	   --63 downto 0 n*32 - 1, n = 2
		x1x1 <= x1 * x1;	 --clock 0	   --63 downto 0
		y3y3 <= y3 * y3;  --clock 1		   --127 downto 0  n*32 -1, n = 4 to n = 3
		x1x1y3y3 <= (abs(x1x1(2*width+1 downto width+1))) - (abs(y3y3(4*width+3 downto 3*width+3)));   --clock 2
		mu_2 <= shift_right(x1x1y3y3, 13);	 --clock 3
		reg_2 <= reg_2 + mu_2; 	 --clock 4
		gain_error <= reg_2;   --update gain error estimate.  --clock 5
		
		end if;
		
	end process;	

end IQGainPhaseCorrection_beh;


