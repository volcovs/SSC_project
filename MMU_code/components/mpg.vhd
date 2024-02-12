library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mpg is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           enable : out STD_LOGIC);
end mpg;

architecture Behavioral of mpg is
signal curent: std_logic_vector(15 downto 0);
signal Q1, Q2, Q3: std_logic;

begin

enable <= Q2 and not Q3;

process (clk)
-- numaratorul
begin
   if clk='1' and clk'event then
       curent <= curent + 1;
   end if;
end process;

process(clk)
-- primul bistabil D
begin
    if clk'event and clk='1' then
        if curent = x"FFFF" then
        -- simularea portii 'si' pe cei 16 biti ai numaratorului
            Q1 <= btn;
        end if;
    end if;
end process;

process(clk)
-- simularea intarzierii produse de celelalte 2 bistabile
begin
    if clk'event and clk='1' then
        Q2 <= Q1;
        Q3 <= Q2;
     end if;
end process;


end Behavioral;
