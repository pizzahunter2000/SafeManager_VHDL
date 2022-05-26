library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity state_counter is
  Port (
  	CLK: in std_logic; 
  	ENABLE: in std_logic;
	R: in std_logic;
    PL: in std_logic;	  
    Q: inout std_logic_vector(2 downto 0));
end state_counter;

architecture counter of state_counter is 

signal count : std_logic_vector(2 downto 0) := "000";

begin
    process (CLK, R)
    
    begin
        if(R = '1') then 
			count <= "000";
		else				 
			if(CLK = '1' and CLK'EVENT and ENABLE = '1') then   
				if(PL = '1') then count <= Q; 
				else	
					if (count /= "101") then
						count <= count + 1;	 
					else   
						count <= "000";
					end if;
		        end if;
	        end if;
        end if;
		Q <= count;
        
    end process;

end counter;
