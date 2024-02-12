library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity ManagementUnit is
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
end ManagementUnit;

architecture Behavioral of ManagementUnit is

-- valid bit + 5 biti/pagina virtuala (= tag) + 3 biti/pagina reala
type lookaside_buffer is array(0 to 3) of STD_LOGIC_VECTOR(8 downto 0);
signal TLB: lookaside_buffer := (others => (others => '0'));

-- valid bit + 3 biti/pagina reala + 2 biti/counter + dirty bit
-- page table-ul are dimensiunea egala cu numarul de pagini virtuale de pe sistem
type page_table_type is array(0 to 31) of STD_LOGIC_VECTOR(6 downto 0);
signal page_table: page_table_type := (others => (others => '0'));

-- un pointer care ajuta la determinarea existentei de pozitii libere in page table
-- doar 8 pagini exista in memoria principala 
signal page_table_pointer: integer range 0 to 7 := 0;
signal tlb_pointer: integer range 0 to 3 := 0;
signal virt_page_number : integer range 0 to 31 := 0;

type LRU_states is (START_ALG, END_ALG, TAKE_ENTRY, CHECK_MIN, INC_I, IS_DIRTY, BRING_PAGE);
signal LRU_s : LRU_states := START_ALG;

type PGH_states is (RELOAD, CHECK_TLB, CHECK_PT, SAVE_CURRENT_EXEC_HANDLER, EXEC_LRU, UPDATE_TLB, ACCESS_DATA);
signal PGH_s : PGH_states := CHECK_TLB;

signal TLB_miss: integer := 0;
signal TLB_hit: integer := 0;
signal PT_miss: integer := 0;
signal PT_hit: integer := 0;

signal current_offset: STD_LOGIC_VECTOR(3 downto 0);
signal virtual_change: STD_LOGIC_VECTOR(8 downto 0) := "XXXXXXXXX";
signal op_change: STD_LOGIC := 'X';

begin
    virt_page_number <= conv_integer(virtual_address(8 downto 4));
    
     
    CHECK_PAGE_FAULT_AND_REPLACE_IF_MISS:
    process(rst, page_table, TLB, PGH_s, LRU_s, clk, virtual_address)
    
    -- iterators
    variable i : integer range 0 to 31 := 0;
    variable j : integer range 0 to 7 := 0;
    variable k : integer := 0;
    -- variables for finding page to replace
    variable min_count: STD_LOGIC_VECTOR(1 downto 0) := "11";
    variable min_entry: integer;
    variable min_real_page: STD_LOGIC_VECTOR(2 downto 0) := "000";
    variable entry_count: STD_LOGIC_VECTOR(1 downto 0);
    
    variable ram_r, ram_w: STD_LOGIC_VECTOR(6 downto 0);
    variable disk_r, disk_w: STD_LOGIC_VECTOR(8 downto 0);
    variable miss_var: STD_LOGIC;
    
    variable hit_var: STD_LOGIC := '0';
   
    begin
        if rst = '1' then
            LRU_s <= START_ALG;
            PGH_s <= CHECK_TLB;
        else
        if (clk'event and clk = '1') then
            TLB_miss <= 0;
            TLB_hit <= 0;
            PT_miss <= 0;
            PT_hit <= 0;
        
        case PGH_s is
             when CHECK_TLB =>
                hit_var := '0';
                miss_var := '0';
                -- check the valid bit for the needed entry
                for e in 0 to 3 loop
                    if ((TLB(e)(7 downto 3) = virtual_address(8 downto 4)) and (TLB(e)(8) = '1')) then
                        TLB_hit <= 1;
                        TLB_miss <= 0;
                        hit_var := '1';
                        PGH_s <= ACCESS_DATA;
                    end if;
                end loop;
                
                if hit_var = '0' then
                    TLB_miss <= 1;
                    TLB_hit <= 0;
                    -- soft miss => next state = check entry from page table
                    PGH_s <= CHECK_PT;
                end if;
                
                ram_r := real_r_address;
                enable_RAM <= '0';
                enable_disk <= '0';
                write_RAM <= '0';
                write_disk <= '0';
                write_from_disk <= '0';
                rollback_PC <= '0';
                save_PC_to_EPC <= '0';
                
             when CHECK_PT =>
                -- check the valid bit
                 if (page_table(virt_page_number)(6) = '0') then
                    miss_var := '1';
                    PT_miss <= 1;
                    PT_hit <= 0;
                    hit_var := '0';
                    -- hard miss => next state = begin page fault handling
                    PGH_s <= SAVE_CURRENT_EXEC_HANDLER;
                else 
                    miss_var := '0';
                    PT_hit <= 1;
                    PT_miss <= 0;
                    hit_var := '1';
                    -- data found => add entry in TLB 
                    PGH_s <= UPDATE_TLB;
                end if;
                
                ram_r := real_r_address;
                enable_RAM <= '0';
                enable_disk <= '0';
                write_RAM <= '0';
                write_disk <= '0';
                write_from_disk <= '0';
                rollback_PC <= '0';
                save_PC_to_EPC <= '0';
                
             when ACCESS_DATA =>
                -- operations on data => '0' -> read from memory page, '1' -> write to memory page
                -- increment page counter
                
                -- !! only if the address or operation has changed => otherwise, the system stays in the same state and
                -- the counter shouldn't be incremented
                if virtual_change /= virtual_address then
                    page_table(virt_page_number)(2 downto 1) <= page_table(virt_page_number)(2 downto 1) + 1;
                    -- decrement counter for all other pages in main memory
                    for i in 0 to 31 loop
                        if i /= virt_page_number then
                            if page_table(i)(2 downto 1) /= "00" then
                                page_table(i)(2 downto 1) <= page_table(i)(2 downto 1) - 1;
                            end if;
                        end if;                    
                    end loop;
                    virtual_change <= virtual_address;
                elsif op_change /= op then
                    page_table(virt_page_number)(2 downto 1) <= page_table(virt_page_number)(2 downto 1) + 1;
                    -- decrement counter for all other pages in main memory
                     for i in 0 to 31 loop
                        if i /= virt_page_number then
                            if page_table(i)(2 downto 1) /= "00" then
                                page_table(i)(2 downto 1) <= page_table(i)(2 downto 1) - 1;
                            end if;
                        end if;                    
                    end loop;
                    op_change <= op;
                end if;
                 
                ram_r := page_table(virt_page_number)(5 downto 3) & virtual_address(3 downto 0);
                if op = '0' then
                    enable_RAM <= '0';       
                else 
                    enable_RAM <= '1';
                    write_RAM <= '1';
                    ram_w := page_table(virt_page_number)(5 downto 3) & virtual_address(3 downto 0);
                    -- modify dirty bit in case of write
                    page_table(virt_page_number)(0) <= '1';
                end if;
                
                PGH_s <= CHECK_TLB;
                enable_disk <= '0';
                write_disk <= '0';
                write_from_disk <= '0';
                rollback_PC <= '0';
                save_PC_to_EPC <= '0';
             
             when SAVE_CURRENT_EXEC_HANDLER =>
                -- save current state of the processor
                -- save PC to EPC
                -- save cause to Exception Cause Register
                ram_r := real_r_address;
                PGH_s <= EXEC_LRU;
                LRU_s <= START_ALG;        
                enable_RAM <= '0';
                enable_disk <= '0';
                write_RAM <= '0';
                write_disk <= '0';
                write_from_disk <= '0';
                rollback_PC <= '0';
                save_PC_to_EPC <= '1';
                
             when EXEC_LRU =>
                -- begin the LRU algorithm in order to find the page to replace
                case LRU_s is
                    when START_ALG =>
                        i := 0;
                        min_count := "11";
                        min_real_page := "000";
                        min_entry := 0;
                        LRU_s <= TAKE_ENTRY;
                   
                        ram_r := real_r_address;
                        enable_RAM <= '0';
                        enable_disk <= '0';
                        write_RAM <= '0';
                        write_disk <= '0';
                        write_from_disk <= '0';
                        rollback_PC <= '0';
                        save_PC_to_EPC <= '0';
                        PGH_s <= EXEC_LRU;
                    
                    when TAKE_ENTRY =>
                        if page_table(i)(6) = '1' then
                            entry_count := page_table(i)(2 downto 1);
                            if entry_count < min_count then
                                LRU_s <= CHECK_MIN;
                            else 
                                LRU_s <= INC_I;
                            end if;
                        else 
                            LRU_s <= INC_I;
                        end if;     
                        
                        ram_r := real_r_address;    
                        enable_RAM <= '0';
                        enable_disk <= '0';
                        write_RAM <= '0';
                        write_disk <= '0';
                        write_from_disk <= '0';
                        rollback_PC <= '0';
                        save_PC_to_EPC <= '0';
                        PGH_s <= EXEC_LRU;
                        
                    when CHECK_MIN => 
                        min_count := entry_count;
                        min_real_page := page_table(i)(5 downto 3);
                        min_entry := i;
                        LRU_s <= INC_I;    
                        
                        ram_r := real_r_address;
                        enable_RAM <= '0';
                        enable_disk <= '0';
                        write_RAM <= '0';
                        write_disk <= '0';
                        write_from_disk <= '0';
                        rollback_PC <= '0';  
                        save_PC_to_EPC <= '0';   
                        PGH_s <= EXEC_LRU;           
                    
                    when INC_I =>
                        i := i + 1;
                        --if i = 32 then
                        if i = 8 then     
                            if page_table(min_entry)(0) = '1' then
                                LRU_s <= IS_DIRTY;
                            else 
                                LRU_s <= BRING_PAGE;
                                k := 0;
                            end if;
                            j := 0;
                            current_offset <= virtual_address(3 downto 0);
                        else 
                            LRU_s <= TAKE_ENTRY;
                        end if;
                        
                        ram_r := real_r_address;
                        enable_RAM <= '0';
                        enable_disk <= '0';
                        write_RAM <= '0';
                        write_disk <= '0';
                        write_from_disk <= '0';
                        rollback_PC <= '0';
                        save_PC_to_EPC <= '0';
                        PGH_s <= EXEC_LRU;
                        
                    when IS_DIRTY =>
                        enable_RAM <= '1';
                        write_RAM <= '0';
                        write_disk <= '1';
                        enable_disk <= '1';
                       
                        write_from_disk <= '0';
                        rollback_PC <= '0';
                        save_PC_to_EPC <= '0';
                        PGH_s <= EXEC_LRU;
                    
                        if j > 7 then
                            LRU_s <= BRING_PAGE;
                            k := 0;
                            current_offset <= virtual_address(3 downto 0);
                            ram_r := real_r_address;
                        else
                            current_offset <= current_offset + 2;
                            disk_w := conv_std_logic_vector(min_entry, 5) & current_offset;
                            ram_r := min_real_page & current_offset;
                            
                            j := j + 1;
                            LRU_s <= IS_DIRTY;
                        end if;    
                    
                    when BRING_PAGE =>
                        enable_RAM <= '1';
                        write_RAM <= '1';
                        enable_disk <= '1';
                        write_from_disk <= '1';
                        write_disk <= '0';

                        rollback_PC <= '0';
                        save_PC_to_EPC <= '0';
                        PGH_s <= EXEC_LRU;
                        
                        ram_r := real_r_address;
                        disk_r := virtual_address(8 downto 4) & current_offset;
                        
                        -- still some free positions => add page on free position
                        if page_table_pointer < 8 then
                            ram_w := conv_std_logic_vector(page_table_pointer, 3) & current_offset;
                        else 
                            -- no more free positions => replace one of the pages
                            ram_w := min_real_page & current_offset;
                        end if;
                        
                        current_offset <= current_offset + "0010";
                        k := k + 1;
                        if k > 7 then
                            LRU_s <= END_ALG;
                            PGH_s <= EXEC_LRU;
                            -- update page table position
                            -- valid & replaced_page_number & counter & dirty
                            if page_table_pointer < 8 then
                                page_table_pointer <= page_table_pointer + 1;
                                page_table(virt_page_number) <= '1' & conv_std_logic_vector(page_table_pointer, 3) & "00" & '0';
                            else
                                page_table(virt_page_number) <= '1' & min_real_page & "00" & '0';
                                page_table(min_entry)(6) <= '0';
                            end if;
                        else
                            LRU_s <= BRING_PAGE;
                            PGH_s <= EXEC_LRU;
                        end if;    
                        
                    when END_ALG =>
                        miss_var := '0';
                        ram_r := real_r_address;
                           
                        PGH_s <= RELOAD;   
                        enable_RAM <= '0';
                        enable_disk <= '0';
                        write_RAM <= '0';
                        write_disk <= '0';
                        write_from_disk <= '0';
                        rollback_PC <= '0';
                        save_PC_to_EPC <= '0';   
                end case;
             
             when UPDATE_TLB => 
                -- update TLB with missing entry
                -- valid & virtual page number & real page number
                TLB(tlb_pointer) <= '1' & virtual_address(8 downto 4) & page_table(virt_page_number)(5 downto 3);                
                if tlb_pointer < 3 then
                    tlb_pointer <= tlb_pointer + 1;
                else
                    tlb_pointer <= 0;
                end if;
                PGH_s <= CHECK_TLB;  
                
                ram_r := real_r_address;
                enable_RAM <= '0';
                enable_disk <= '0';
                write_RAM <= '0';
                write_disk <= '0';
                write_from_disk <= '0';
                rollback_PC <= '0';
                save_PC_to_EPC <= '0';
                 
             when RELOAD =>          
                rollback_PC <= '1';
                PGH_s <= CHECK_TLB;
                
                ram_r := real_r_address;
                enable_RAM <= '0';
                enable_disk <= '0';
                write_RAM <= '0';
                write_disk <= '0';
                write_from_disk <= '0';
                save_PC_to_EPC <= '0';

        end case;
        end if;
        end if;
        
        hit <= hit_var;
        real_r_address <= ram_r;
        real_w_address <= ram_w;
        disk_r_address <= disk_r;
        disk_w_address <= disk_w;
        miss <= miss_var;
        
    end process;
    
end Behavioral;
