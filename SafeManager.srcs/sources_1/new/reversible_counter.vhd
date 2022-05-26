library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.ALL; 

entity reversible_counter is
  Port (   
  	CLK: in std_logic;
    CU: in std_logic;
    CD: in std_logic;
    R: in std_logic;
    Q: out std_logic_vector(3 downto 0));
end reversible_counter;

architecture select_digit of reversible_counter is	 

signal count : std_logic_vector(3 downto 0);

begin
    process (CLK, R)
    begin
        if(R = '1') then count <= "0000";
		elsif(CLK = '1' and CLK'EVENT) then	   
			if(CU = '1') then 
	            if(count = "1111") then count <= "0000";
	            else count <= count + 1;
	            end if;
	        end if;
	        if(CD = '1') then
	            if(count = "0000") then count <= "1111";
	            else count <= count - 1;
	            end if;
	        end if;
        end if;	  
		Q <= count;
        
    end process;

end select_digit;