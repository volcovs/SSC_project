library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity RAM is 
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
end entity;


architecture mainMemory of RAM is 

-- o pagina are 4KB de date => 4096 de bytes
-- un cuvant odata => type page is array (0 to 2**11-1) of STD_LOGIC_VECTOR(15 downto 0);
-- octeti adresabili individual
-- sacled down => 128 de biti/pagina
type page is array (0 to 2**4-1) of STD_LOGIC_VECTOR(7 downto 0);
-- intreaga memorie are 256 de pagini
-- scaled down => 8 pagini
type mem is array (0 to 7) of page;


signal pageNumRead: STD_LOGIC_VECTOR(2 downto 0);
signal pageOffsetRead: STD_LOGIC_VECTOR(3 downto 0);
signal pageNumWrite: STD_LOGIC_VECTOR(2 downto 0);
signal pageOffsetWrite: STD_LOGIC_VECTOR(3 downto 0);

signal memory: mem := (others => (others => (others => '1')));
                    
begin

    pageNumRead <= read_address(6 downto 4);
    pageOffsetRead <= read_address(3 downto 0);
    pageNumWrite <= write_address(6 downto 4);
    pageOffsetWrite <= write_address(3 downto 0);
        
    -- scriere sincrona in memorie
    WRITE_PROC: process(clk, write, enable, WriteData) 
    begin
        if (clk'event and clk = '1') then
            if (write = '1' and enable = '1') then
                memory(to_integer(unsigned(pageNumWrite)))(to_integer(unsigned(pageOffsetWrite))) <= WriteData(7 downto 0);
                memory(to_integer(unsigned(pageNumWrite)))(to_integer(unsigned(pageOffsetWrite))+1) <= WriteData(15 downto 8);
            end if;
        end if;    
    end process;
    
     -- citire asincrona din memorie
    ReadData(7 downto 0) <= memory(conv_integer(pageNumRead))(conv_integer(pageOffsetRead));
    ReadData(15 downto 8) <= memory(conv_integer(pageNumRead))(conv_integer(pageOffsetRead)+1);


end architecture;