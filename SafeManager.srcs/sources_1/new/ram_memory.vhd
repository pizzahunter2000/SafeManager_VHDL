library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ram_memory is
  Port ( 
    addr_ram: in std_logic_vector(3 downto 0);
    wr_ram: in std_logic;
    data_ram: in std_logic_vector(11 downto 0);
    clock_ram: in std_logic;
    reset: in std_logic;
    cont_ram: out std_logic_vector(11 downto 0)
  );
end ram_memory;

architecture memorize of ram_memory is

type memory is array (1 to 9) of std_logic_vector(11 downto 0);
signal memo: memory := (others => x"000");

begin
    process(clock_ram, reset)
    
    begin
        if(reset = '1') then
			memo <= (others => x"000");
        elsif(clock_ram = '1' and clock_ram'event) then
            if(wr_ram = '1') then
                 memo(to_integer(unsigned(addr_ram))) <= data_ram;
            end if;
        end if;
    end process;
    
    cont_ram <= memo(to_integer(unsigned(addr_ram)));
end memorize;
