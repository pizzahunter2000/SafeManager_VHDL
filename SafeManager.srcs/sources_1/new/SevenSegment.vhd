library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SevenSegment is
  Port (
    clock: in std_logic;
    reset: in std_logic;
	enable: in std_logic_vector(2 downto 0);
    displayed_number: in std_logic_vector(15 downto 0);
    anode_active: out std_logic_vector(3 downto 0);  --4 anodes
    led_out: out std_logic_vector(6 downto 0) ); --7 cathodes
end SevenSegment;

architecture show of SevenSegment is

signal led_bcd: std_logic_vector(3 downto 0);
signal refresh_counter: std_logic_vector(19 downto 0);
signal led_counter: std_logic_vector(1 downto 0);

begin

    show_number: process(led_bcd)
    begin			 
        case led_bcd is
            when "0000" => led_out <= "0000001"; -- "0"     
            when "0001" => led_out <= "1001111"; -- "1" 
            when "0010" => led_out <= "0010010"; -- "2" 
            when "0011" => led_out <= "0000110"; -- "3" 
            when "0100" => led_out <= "1001100"; -- "4" 
            when "0101" => led_out <= "0100100"; -- "5" 
            when "0110" => led_out <= "0100000"; -- "6" 
            when "0111" => led_out <= "0001111"; -- "7" 
            when "1000" => led_out <= "0000000"; -- "8"     
            when "1001" => led_out <= "0000100"; -- "9" 
            when "1010" => led_out <= "0000010"; -- a
            when "1011" => led_out <= "1100000"; -- b
            when "1100" => led_out <= "0110001"; -- C
            when "1101" => led_out <= "1000010"; -- d
            when "1110" => led_out <= "0110000"; -- E
            when "1111" => led_out <= "0111000"; -- F  
			when others => led_out <= "0000001"; -- "0"
       end case;
    end process;
    
    frequency_divider: process(clock, reset)
    
    begin
        if(reset = '1') then
            refresh_counter <= (others => '0');
        else if(clock'event and clock = '1') then
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;
    
    led_counter <= refresh_counter(19 downto 18);
    
    multiplexer: process(led_counter, displayed_number)
    
    begin
        case led_counter is
            when "00" =>
				if(enable > "000") then
	                anode_active <= "0111";
	                led_bcd <= displayed_number(15 downto 12);	   
				else
					anode_active <= "1111";
				end if;
            when "01" => 	 
				if(enable > "001") then
	                anode_active <= "1011";
	                led_bcd <= displayed_number(11 downto 8);
				else   
					anode_active <= "1111";
				end if;
            when "10" => 		
				if(enable > "010") then
	                anode_active <= "1101";
	                led_bcd <= displayed_number(7 downto 4); 
				else
					anode_active <= "1111";
				end if;
            when "11" =>  
				if(enable > "011") then
	                anode_active <= "1110";
	                led_bcd <= displayed_number(3 downto 0);	
				else
					anode_active <= "1111";
				end if;
			when others =>
				anode_active <= "0111";
                led_bcd <= displayed_number(15 downto 12);
        end case;
    end process;

end show;
