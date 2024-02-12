library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity displ_7seg is
	port ( clk, rst : in std_logic;
		    data : in std_logic_vector (15 downto 0);
		    sseg : out std_logic_vector (6 downto 0);
		    an : out std_logic_vector (3 downto 0));
end displ_7seg;

architecture Behavioral of displ_7seg is
	
	component bcd_7_seg is
        Port (nb: in STD_LOGIC_VECTOR(3 downto 0);
            cat: out STD_LOGIC_VECTOR(6 downto 0));
    end component;
	
	signal ledsel : std_logic_vector (1 downto 0);
	signal cntdiv : std_logic_vector (10 downto 0) := (others => '0');
	signal segdata : std_logic_vector (3 downto 0);
	
begin
	process (clk, rst)
	begin
		if rst = '1' then
			cntdiv <= (others => '0');
		elsif (clk'event and clk = '1') then
			cntdiv <= cntdiv + 1;
		end if;
	end process;
	
	ledsel <= cntdiv(10 downto 9);
	
	an <= "1110" when ledsel = "00" else
		   "1101" when ledsel = "01" else
		   "1011" when ledsel = "10" else
		   "0111" when ledsel = "11";
			
	segdata <= data (3 downto 0)   when ledsel = "00" else
		        data (7 downto 4)   when ledsel = "01" else
		        data (11 downto 8)  when ledsel = "10" else
		        data (15 downto 12) when ledsel = "11";
				  
	hex2sseg_u: bcd_7_seg
		port map (nb => segdata, cat => sseg);
		
end Behavioral;
