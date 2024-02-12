library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity full_test is
--  Port ( );
end full_test;

architecture Behavioral of full_test is

component Full is 
    port(clk: in STD_LOGIC;
        btn_test: in STD_LOGIC;
        rst: in STD_LOGIC;
        input: in STD_LOGIC_VECTOR(15 downto 0);
        an: out STD_LOGIC_VECTOR(3 downto 0);
        cat: out STD_LOGIC_VECTOR(6 downto 0);
        hit: out STD_LOGIC;
        miss: inout STD_LOGIC);
end component;

signal clk, btn_test: STD_LOGIC := '0';
signal rst: STD_LOGIC;
signal input: STD_LOGIC_VECTOR(15 downto 0);
signal an: STD_LOGIC_VECTOR(3 downto 0);
signal cat: STD_LOGIC_VECTOR(6 downto 0);
signal hit, miss: STD_LOGIC;

begin

    clk <= not clk after 5ns;
    rst <= '0';
    -- input(15) = op, input(14 downto 7) = data, 
    -- input(6 downto 2) = virtual page number, input(1 downto 0) = virtual page offset
    input <= B"0_00000000_00011_00",
             B"1_01101100_00001_10" after 1010ns,
             B"0_00001111_00001_00" after 2000ns,
             B"0_00000000_00010_00" after 3000ns,
             B"0_00000000_00100_00" after 4000ns,
             B"0_00000000_00101_00" after 5000ns,
             B"0_00000000_00110_00" after 6000ns,
             B"0_00000000_00111_00" after 7000ns,
             B"0_00000000_01000_00" after 8000ns,
             B"0_00000000_01010_00" after 9000ns,
             B"0_00000000_01001_00" after 10000ns,
             B"0_00000000_01011_00" after 11000ns,
             B"0_00000000_01100_00" after 12000ns,
             B"0_00000000_01101_00" after 13000ns,
             B"0_00000000_01110_00" after 14000ns,
             B"0_00000000_01111_00" after 15000ns,
             B"0_00000000_10000_00" after 16000ns,
             B"0_00000000_10001_00" after 17000ns;
    
    
    TEST: Full port map (clk => clk,
                        btn_test => btn_test,
                        rst => rst,
                        input => input,
                        an => an,
                        cat => cat,
                        hit => hit,
                        miss => miss);

end Behavioral;
