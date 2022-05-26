library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;

entity safe_manager is
	port(	  
	clk: in std_logic;
	start: in std_logic;
	add_digit: in std_logic;
	up: in std_logic;
	down: in std_logic;	
	reset: in std_logic;
	started: out std_logic;
	status: inout std_logic_vector(9 downto 1);
	anode_active: out std_logic_vector(3 downto 0);  --4 anodes
    led_out: out std_logic_vector(6 downto 0) --7 cathodes
	);		 
end safe_manager; 


architecture main of safe_manager is   

component state_counter is 
	Port (
    CLK: in std_logic;
	ENABLE: in std_logic;
	R: in std_logic;
    PL: in std_logic;	  
    Q: inout std_logic_vector(2 downto 0));
end component state_counter;  

component address_selector is
  Port ( 
  	CLK: in std_logic;
    CU: in std_logic;
    CD: in std_logic;  
	ENABLE: in std_logic;
    PL: in std_logic;
    Q: out std_logic_vector(3 downto 0));
end component address_selector;

component reversible_counter is 
	Port ( 
	CLK: in std_logic;
    CU: in std_logic;
    CD: in std_logic;
    R: in std_logic;
    Q: out std_logic_vector(3 downto 0));
end component reversible_counter;

component n_bit_reg is 
	generic(
		n: integer range 1 to 9 := 4);
	port(
		enable: in std_logic;
		reset: in std_logic; 
		clock: in std_logic;
		input: in std_logic_vector(n downto 0);
		output: out std_logic_vector(n downto 0));
end component n_bit_reg;	

component SevenSegment is 
	Port (
    clock: in std_logic;
    reset: in std_logic;
	enable: in std_logic_vector(2 downto 0);
    displayed_number: in std_logic_vector(15 downto 0);
    anode_active: out std_logic_vector(3 downto 0);  --4 anodes
    led_out: out std_logic_vector(6 downto 0) ); --7 cathodes
end component SevenSegment;	 

component debounce is
	port(
	button: in std_logic;
	clk: in std_logic;			
	reset: in std_logic;
	result: out std_logic
	);			 
end component;

component d_flip_flop is
    port(
	d: in std_logic;
	clk: in std_logic;
	reset: in std_logic;  
	enable: in std_logic;
	q: out std_logic
	);	
end component;	  

component ram_memory is
  Port ( 
    addr_ram: in std_logic_vector(3 downto 0);
    wr_ram: in std_logic;
    data_ram: in std_logic_vector(11 downto 0);
    clock_ram: in std_logic;
    reset: in std_logic;
    cont_ram: out std_logic_vector(11 downto 0)
  );
end component ram_memory;

signal d_start, d_add_digit, d_up, d_down: std_logic := '0'; 
signal state: std_logic_vector(2 downto 0) := "000";
signal state_enable, addr_enable: std_logic := '0';
signal load_cond, pl_cond, delayed_pl_cond: std_logic := '0';  
signal address: std_logic_vector(3 downto 0) := "0001";
signal digit: std_logic_vector(3 downto 0) := "0000"; 
signal reg_cond: std_logic_vector(4 downto 0) := "00000";  
signal number: std_logic_vector (15 downto 0) := (others => '0');
signal code, ram_data, content: std_logic_vector (11 downto 0) := (others => '0');
signal safe_status: std_logic_vector (0 to 9) := "0000000000"; 
signal write_enable, ram_cond, mux_out: std_logic := '0';
signal prev_state: std_logic_vector(2 downto 0) := "000";

begin
	debounce_start: debounce port map(start, clk, reset, d_start);
	debounce_add_button: debounce port map(add_digit, clk, reset, d_add_digit);
	debounce_up: debounce port map(up, clk, reset, d_up);
	debounce_down: debounce port map(down, clk, reset, d_down);	
	
	get_load_cond: process(d_start, state, d_add_digit)
	begin
		if (d_start = '0' and state = "000") or (d_add_digit = '0' and state /= "000") then
			load_cond <= '1';
		else	
			load_cond <= '0'; 
		end if;
	end process;
	
	get_pl_cond: process(clk)
	begin	
		if clk = '1' and clk'event then
			pl_cond <= reset or d_start or d_add_digit;	
		end if;
	end process;
	
	DFF1: d_flip_flop port map (pl_cond, clk, reset, '1', delayed_pl_cond);	 
	
	addr_enable_proc: process (clk)
	begin  	   
		if clk = '1' and clk'event then
			if state = "001" then
				addr_enable <= '1';
			else
				addr_enable <= '0';
			end if;	  
		end if;
	end process;
	
	main_state_counter: state_counter port map(clk, '1', reset, load_cond, state);	  
	safe_nr_selector: address_selector port map(clk, d_up, d_down, addr_enable, delayed_pl_cond, address);
	number_selector: reversible_counter port map(clk, d_up, d_down, delayed_pl_cond, digit);   
	
	
	
	register_conditions: process(clk)
	begin  
		if clk = '1' and clk'event then
			case state is  
				when "000" => reg_cond <= "00000";
				when "001" => reg_cond <= "00001";
				when "010" => reg_cond <= "00010";
				when "011" => reg_cond <= "00100";
				when "100" => reg_cond <= "01000";	 
				when "101" => reg_cond <= "10000";
				when others => reg_cond <= "00000";
			end case;	
		end if;
	end process;
	
	addr_reg: n_bit_reg generic map (3) port map (reg_cond(0), reset, clk, address, number(15 downto 12));
	code_reg_1:	n_bit_reg generic map (3) port map (reg_cond(1), reset, clk, digit, number(11 downto 8));
	code_reg_2:	 n_bit_reg generic map (3) port map (reg_cond(2), reset, clk, digit, number(7 downto 4));
	code_reg_3:	 n_bit_reg generic map (3) port map (reg_cond(3), reset, clk, digit, number(3 downto 0)); 
	code <= number(11 downto 0);
	
	seven_segment: SevenSegment port map (clk, reset, state, number, anode_active, led_out); 
	
	change_status: process (write_enable, reset) 
	
	variable index: integer range 0 to 9 := to_integer(unsigned(number(15 downto 12)));
	
	begin		  
		index := to_integer(unsigned(number(15 downto 12)));
		if reset = '1' then safe_status <= "0000000000";
		elsif write_enable = '1' and write_enable'event then 
			if safe_status(index) = '1' then
				safe_status(index) <= '0';
			else safe_status(index) <= '1';
			end if;
		end if;
	end process;
	
	--status_register: n_bit_reg generic map (9) port map (reg_cond(4), reset, clk, safe_status, safe_status); 
	
	delay_state: process (clk, reset)
	begin
	   if reset = '1' then prev_state <= "000";
	   elsif clk = '1' and clk'event then
	       prev_state <= state;
	   end if;
	end process;
	
	compare: process (state, reset)
	begin	  		 
		if reset = '1' then ram_cond <= '0';
		elsif state = "101" and prev_state /= state then
			if (code = content) then ram_cond <= '1';
			else ram_cond <= '0';
			end if;
		elsif state = "000" then ram_cond <= '0';
		end if;
	end process; 
	
	select_data: process (clk)
	begin 
		if clk = '1' and clk'event then
			if ram_cond = '1' then
				ram_data <= x"000";
			else ram_data <= code;
			end if;		
		end if;
	end process;  
	
	
	status_multiplexer: process (clk)
	
	variable addr: integer range 0 to 9 := to_integer(unsigned(number(15 downto 12)));
	
	begin			  
		if clk = '1' and clk'event then
			if state = "100" and prev_state /= state then
				addr := to_integer(unsigned(number(15 downto 12)));
				mux_out <= safe_status(addr);
			elsif state = "000" then mux_out <= '0';  
			end if;
		end if;
	end process;
	
	write_enable_proc: process (clk)
	begin 		  
	   
		if clk = '1' and clk'event then
			if state = "101" then
				write_enable <= not mux_out or ram_cond;
			else
				write_enable <= '0';
			end if;	
		end if;
	end process;
	
	big_brain_ram: ram_memory port map (number(15 downto 12), write_enable, ram_data, clk, reset, content);
	
	status <= safe_status(1 to 9); 
	
	get_started: process (clk, reset)
	begin							
		if reset = '1' then started <= '0';
		elsif clk = '1' and clk'event then
			if state = "000" then
				started <= '0';
			else   
				started <= '1';
			end if;
		end if;
	end process;
	
end main;