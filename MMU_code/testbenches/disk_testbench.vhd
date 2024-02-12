library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity disk_testbench is
--  Port ( );
end disk_testbench;

architecture Behavioral of disk_testbench is

component HardDisk is
    port (clk: in STD_LOGIC;
        enable: in STD_LOGIC;
        write: in STD_LOGIC;
        read_address: in STD_LOGIC_VECTOR(8 downto 0);
        write_address: in STD_LOGIC_VECTOR(8 downto 0);
        WriteData: in STD_LOGIC_VECTOR(15 downto 0);
        ReadData: out STD_LOGIC_VECTOR(15 downto 0));
end component;

signal clk: STD_LOGIC := '0';
signal enable: STD_LOGIC;
signal write: STD_LOGIC;
signal address: STD_LOGIC_VECTOR(8 downto 0);
signal WriteData: STD_LOGIC_VECTOR(15 downto 0);
signal ReadData: STD_LOGIC_VECTOR(15 downto 0);

begin

    clk <= not clk after 5ns;
    enable <= '1';
    write <= '0', '1' after 15ns, '0' after 30ns;
    WriteData <= x"000F";
    address <= B"00000_0000", 
            B"00011_0000" after 5ns, 
            B"00001_0100" after 10ns, 
            B"00001_0110" after 15ns;
    
    
    TEST: HardDisk port map(clk => clk, 
                        enable => enable, 
                        write => write, 
                        read_address => address, 
                        write_address => address,
                        WriteData => WriteData, 
                        ReadData => ReadData);

end Behavioral;
