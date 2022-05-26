library ieee;
use ieee.std_logic_1164.all;

entity debounce is
	port(
	button: in std_logic;
	clk: in std_logic;			
	reset: in std_logic;
	result: out std_logic
	);			 
end debounce;


architecture flow of debounce is  


component d_flip_flop is
	port(
	d: in std_logic;
	clk: in std_logic;
	reset: in std_logic;  
	enable: in std_logic;
	q: out std_logic
	);	
end component;

component reversible_counter is
  Port (   
  	CLK: in std_logic;
    CU: in std_logic;
    CD: in std_logic;
    R: in std_logic;
    Q: out std_logic_vector(3 downto 0));
end component;	   

signal q1, q2, temp: std_logic := '0';	 
signal counter: std_logic_vector(3 downto 0) := "0000";

begin
	
	DEB_COUNTER: reversible_counter port map (clk, '1', '0', reset, counter);	  
	
	process	(counter)
	begin
		if counter = "1111" then
			temp <= '1';
		else
			temp <= '0';
		end if;
	end process;
	
	FF1: d_flip_flop port map (button, clk, reset, temp, q1);  
	FF2: d_flip_flop port map (q1, clk, reset, '1', q2); 
	
	result <= q1 and not q2;
	
end flow;