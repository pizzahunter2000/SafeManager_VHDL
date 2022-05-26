library ieee;
use ieee.std_logic_1164.all;

entity d_flip_flop is
	port(
	d: in std_logic;
	clk: in std_logic;
	reset: in std_logic;  
	enable: in std_logic;
	q: out std_logic
	);	
end d_flip_flop;

architecture flow of d_flip_flop is

begin	 
	process (clk, reset)
	
	begin	 
		if reset = '1' then q <= '0';
		elsif clk = '1' and clk'event then	
			if enable = '1' then
				q <= d;		
			end if;
		end if;
	end	process;
end flow;