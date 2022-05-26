library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.ALL;

entity address_selector is
  Port (	  
  	CLK: in std_logic;
    CU: in std_logic;
    CD: in std_logic; 
	ENABLE: in std_logic;
    PL: in std_logic;
    Q: out std_logic_vector(3 downto 0));
end address_selector;

architecture select_addr of address_selector is	  

signal count: std_logic_vector(3 downto 0);

begin
    process (CLK, PL)
    begin 
		if(ENABLE = '1') then
	        if(PL = '1') then count <= "0001";
			elsif (CLK = '1' and CLK'EVENT)	then
				if(CU = '1') then 
			         if(count = "1001") then count <= "0001";
			         else count <= count + 1;
			         end if;
			    end if;
			    if(CD = '1') then
			        if(count = "0001") then count <= "1001";
			        else count <= count - 1;
			        end if;
			   end if;
			end if;	        
	        Q <= count;
        end if;
        
    end process;

end select_addr;
