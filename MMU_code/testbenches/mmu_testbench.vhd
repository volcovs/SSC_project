library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mmu_testbench is
--  Port ( );
end mmu_testbench;

architecture Behavioral of mmu_testbench is


component ManagementUnit is
    Port (clk: in STD_LOGIC;
        rst: in STD_LOGIC;
        virtual_address: in STD_LOGIC_VECTOR(8 downto 0);
        op: in STD_LOGIC;
        real_r_address: inout STD_LOGIC_VECTOR(6 downto 0);
        real_w_address: out STD_LOGIC_VECTOR(6 downto 0);
        disk_r_address: out STD_LOGIC_VECTOR(8 downto 0);
        disk_w_address: out STD_LOGIC_VECTOR(8 downto 0);
        enable_RAM: out STD_LOGIC;
        enable_disk:out STD_LOGIC;
        write_RAM: out STD_LOGIC;
        write_disk: out STD_LOGIC;
        hit: out STD_LOGIC;
        -- teoretic, miss = not hit
        miss: inout STD_LOGIC;
        save_PC_to_EPC: out STD_LOGIC;
        rollback_PC: out STD_LOGIC;
        write_from_disk: out STD_LOGIC);
end component;

signal clk: STD_LOGIC := '0';
signal virtual_address: STD_LOGIC_VECTOR(8 downto 0);
signal op: STD_LOGIC := '0';

signal real_r_address: STD_LOGIC_VECTOR(6 downto 0);
signal disk_r_address: STD_LOGIC_VECTOR(8 downto 0);
signal real_w_address: STD_LOGIC_VECTOR(6 downto 0);
signal disk_w_address: STD_LOGIC_VECTOR(8 downto 0);
signal enable_RAM: STD_LOGIC;
signal enable_disk: STD_LOGIC;
signal write_RAM: STD_LOGIC;
signal write_disk: STD_LOGIC;
signal hit: STD_LOGIC;
signal miss: STD_LOGIC;
signal rollback_PC: STD_LOGIC;
signal write_from_disk: STD_LOGIC;
signal r, save_PC: STD_LOGIC;

begin
    
    clk <= not clk after 5ns;
    virtual_address <= B"00000_0000", B"00011_0010" after 860ns, B"00010_0011" after 1720ns;
    op <= '0', '1' after 1800ns;
    r <= '1', '0' after 5ns;
    
    TEST: ManagementUnit port map (clk => clk, 
                                rst => r,
                                virtual_address => virtual_address,
                                op => op,
                                real_r_address => real_r_address,
                                real_w_address => real_w_address,
                                disk_r_address => disk_r_address,
                                disk_w_address => disk_w_address,
                                enable_RAM => enable_RAM,
                                enable_disk => enable_disk,
                                write_RAM => write_RAM,
                                write_disk => write_disk,
                                hit => hit,
                                miss => miss,
                                save_PC_to_EPC => save_PC,
                                rollback_PC => rollback_PC,
                                write_from_disk => write_from_disk);

end Behavioral;
