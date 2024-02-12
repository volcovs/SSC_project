library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Full is 
    port(clk: in STD_LOGIC;
        btn_test: in STD_LOGIC;
        rst: in STD_LOGIC;
        input: in STD_LOGIC_VECTOR(15 downto 0);
        an: out STD_LOGIC_VECTOR(3 downto 0);
        cat: out STD_LOGIC_VECTOR(6 downto 0);
        hit: out STD_LOGIC;
        miss: inout STD_LOGIC);
end entity;


architecture complete of Full is

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

component RAM is 
    port (clk: in STD_LOGIC;
        enable: in STD_LOGIC;
        write: in STD_LOGIC;
        -- adresa contine numarul paginii fizice si offset-ul la care se gaseste cuvantul de citit
        -- 8 biti => numarul paginii, 12 biti => offset-ul (daca octeti individuali)
        -- varianta scaled down => 3 biti/pagina, 4 biti/offset
        read_address: in STD_LOGIC_VECTOR(6 downto 0);
        write_address: in STD_LOGIC_VECTOR(6 downto 0);
        -- magistrala de date este pe 16 biti, de aceea blocul de scriere/citire e tot de 16 biti
        WriteData: in STD_LOGIC_VECTOR(15 downto 0);
        ReadData: out STD_LOGIC_VECTOR(15 downto 0));
end component;

component HardDisk is
    port (clk: in STD_LOGIC;
        enable: in STD_LOGIC;
        write: in STD_LOGIC;
        -- adresa contine numarul paginii fizice si offset-ul la care se gaseste cuvantul de citit
        -- 18 biti => numarul paginii, 12 biti => offset-ul (daca octeti individuali)
        -- scaled down => 5 biti/pagina, 4 biti/offset
        read_address: in STD_LOGIC_VECTOR(8 downto 0);
        write_address: in STD_LOGIC_VECTOR(8 downto 0);
        -- magistrala de date este pe 16 biti, de aceea blocul de scriere/citire e tot de 16 biti
        WriteData: in STD_LOGIC_VECTOR(15 downto 0);
        ReadData: out STD_LOGIC_VECTOR(15 downto 0));
end component;

component displ_7seg is
	port ( clk, rst : in std_logic;
		    data : in std_logic_vector (15 downto 0);
		    sseg : out std_logic_vector (6 downto 0);
		    an : out std_logic_vector (3 downto 0));
end component;

component mpg is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;

-- a lot of signals
signal clk_aux, reset: STD_LOGIC;
signal write_from_disk, write_RAM, write_disk, UM_enable_RAM, UM_enable_disk, rollback, save_PC: STD_LOGIC;

signal data_from_disk, data_from_RAM: STD_LOGIC_VECTOR(15 downto 0);
signal data_from_instruction: STD_LOGIC_VECTOR(15 downto 0);
signal data_to_write: STD_LOGIC_VECTOR(15 downto 0);

signal virtual_address: STD_LOGIC_VECTOR(8 downto 0);
signal real_r_address: STD_LOGIC_VECTOR(6 downto 0);
signal disk_r_address: STD_LOGIC_VECTOR(8 downto 0);
signal real_w_address: STD_LOGIC_VECTOR(6 downto 0);
signal disk_w_address: STD_LOGIC_VECTOR(8 downto 0);

signal display_data: STD_LOGIC_VECTOR(15 downto 0);

begin
     --BUTTON: mpg port map (clk => clk, btn => rst, enable => reset);
     -- pentru Basys 3
     BUTTON2: mpg port map (clk => clk, btn => btn_test, enable => clk_aux);
    
    -- pentru simulare:
    --clk_aux <= clk;
    
    data_to_write <= data_from_disk when write_from_disk = '1' else data_from_instruction;
    -- input(15) = op, input(14 downto 7) = data, input(6 downto 2) = virtual page number, input(1 downto 0) = virtual page offset
    data_from_instruction <= "00000000" & input(14 downto 7);
    virtual_address <= input(6 downto 2) & "00" & input(1 downto 0);
    
    MAIN_MEMORY: RAM port map (-- clk => clk,
                            clk => clk_aux, 
                            enable => UM_enable_RAM, 
                            write => write_RAM, 
                            read_address => real_r_address, 
                            write_address => real_w_address,
                            WriteData => data_to_write, 
                            ReadData => data_from_RAM);
                                                
    SEC_MEMORY: HardDisk port map(-- clk => clk,
                                clk => clk_aux,  
                                enable => UM_enable_disk, 
                                write => write_disk, 
                                read_address => disk_r_address, 
                                write_address => disk_w_address,
                                WriteData => data_from_RAM, 
                                ReadData => data_from_disk);
                                
    CONTROL: ManagementUnit port map(-- clk => clk,
                                clk => clk_aux, 
                                rst => reset,
                                virtual_address => virtual_address, 
                                op => input(15), 
                                real_r_address => real_r_address,
                                real_w_address => real_w_address,
                                disk_r_address => disk_r_address,
                                disk_w_address => disk_w_address,
                                enable_RAM => UM_enable_RAM,
                                enable_disk => UM_enable_disk,
                                write_RAM => write_RAM,
                                write_disk => write_disk,
                                hit => hit,
                                miss => miss,
                                save_PC_to_EPC => save_PC,
                                rollback_PC => rollback,
                                write_from_disk => write_from_disk);
    
    display_data <= data_from_RAM;
    DISPLAY: displ_7seg port map(clk => clk, 
                            rst => reset, 
                            data => data_from_RAM, 
                            sseg => cat, 
                            an => an);

end architecture;