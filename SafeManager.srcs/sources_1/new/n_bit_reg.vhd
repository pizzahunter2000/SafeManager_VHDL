library ieee;
use ieee.std_logic_1164.all; 

entity n_bit_reg is
	generic(
		n: integer range 1 to 9 := 4);
	port(
		enable: in std_logic;
		reset: in std_logic; 
		clock: in std_logic;
		input: in std_logic_vector(n downto 0);
		output: out std_logic_vector(n downto 0));
end n_bit_reg;

architecture regi of n_bit_reg is

begin	  
	
	process(clock, reset)
	
	begin		
		if(reset = '1') then
			for i in 0 to input'length - 1 loop 
				output(i) <= '0';	
			end loop;
		elsif(enable = '1' and clock = '1' and clock'event)	then
			output <= input;
		end if;	 
	end process;
end regi;