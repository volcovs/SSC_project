library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RAM_testbench is
--  Port ( );
end RAM_testbench;

architecture Behavioral of RAM_testbench is

component RAM is 
    port (clk: in STD_LOGIC;
        enable: in STD_LOGIC;
        write: in STD_LOGIC;
        read_address: in STD_LOGIC_VECTOR(6 downto 0);
        write_address: in STD_LOGIC_VECTOR(6 downto 0);
        WriteData: in STD_LOGIC_VECTOR(15 downto 0);
        ReadData: out STD_LOGIC_VECTOR(15 downto 0));
end component;

signal clk: STD_LOGIC := '0';
signal enable: STD_LOGIC;
signal write: STD_LOGIC;
signal address: STD_LOGIC_VECTOR(6 downto 0);
signal WriteData: STD_LOGIC_VECTOR(15 downto 0);
signal ReadData: STD_LOGIC_VECTOR(15 downto 0);

begin

    clk <= not clk after 5ns;
    enable <= '1';
    write <= '0', '1' after 15ns, '0' after 30ns;
    WriteData <= x"0050";
    address <= B"000_0000", 
            B"001_00000" after 5ns,
            B"001_0001" after 10ns, 
            B"000_0101" after 15ns;
    
    
    TEST: RAM port map(clk => clk,
                     enable => enable, 
                     write => write, 
                     read_address => address, 
                     write_address => address,
                     WriteData => WriteData, 
                     ReadData => ReadData);


end Behavioral;
