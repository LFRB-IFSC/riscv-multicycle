-------------------------------------------------------
--! @file
--! @brief RISCV Simple GPIO module
--         RAM mapped general purpose I/O

--! @Todo: Module should mask bytes (Word, half word and byte access)
--         Daddress shoud be unsgined
--        
-------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gpio_deb is
    generic (
        --! Chip selec
        MY_CHIPSELECT : std_logic_vector(1 downto 0) := "10";
        MY_WORD_ADDRESS : unsigned(15 downto 0) := x"0120"
    );
 
    port(
        clk : in std_logic;
        rst : in std_logic;

        -- Core data bus signals
        -- ToDo: daddress shoud be unsgined
        daddress  : in  unsigned(31 downto 0);
        ddata_w	  : in 	std_logic_vector(31 downto 0);
        ddata_r   : out	std_logic_vector(31 downto 0);
        d_we      : in std_logic;
        d_rd	  : in std_logic;
        dcsel	  : in std_logic_vector(1 downto 0);	--! Chip select 
        -- ToDo: Module should mask bytes (Word, half word and byte access)
        dmask     : in std_logic_vector(3 downto 0);	--! Byte enable mask 

        -- hardware input/output signals
        input  : in std_logic_vector(31 downto 0);
        output : out std_logic_vector(31 downto 0)
    );
end entity gpio_deb;

architecture RTL of gpio_deb is
    signal result : std_logic_vector(31 downto 0);

begin
    -- Input register
    process(clk, rst)
    begin
        if rst = '1' then
            ddata_r <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_rd = '1') and (dcsel = MY_CHIPSELECT) then
                    if daddress(15 downto 0) =(MY_WORD_ADDRESS) then -- GPIO_ADDRESS
                    ddata_r <= result;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Output register
    process(clk, rst)
    begin
        if rst = '1' then
            output <= (others => '0');
        else
            if rising_edge(clk) then
                if (d_we = '1') and (dcsel = MY_CHIPSELECT)then
                    --if daddress(15 downto 0) =(TIMER_BASE_ADDRESS + x"0000") then -- TIMER_ADDRESS
                    if daddress(15 downto 0) =(MY_WORD_ADDRESS+x"01") then -- GPIO_ADDRESS				
                        -- ToDo: Simplify comparators
                        -- ToDo: Maybe use byte addressing?  
                        --       x"01" (word addressing) is x"04" (byte addressing)
                        -- Address comparator when more than one word is mapped here
                        --if to_unsigned(daddress, 32)(8 downto 0) = MY_WORD_ADDRESS then
                        --end if;
                        output <= ddata_w;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    deb2: entity work.debouncer
        generic map(
            SYS_FREQ => 1,
            COUNTT    => 5
        )
        port map(
            clk    => clk,
            rst    => rst,
            input  => input(0),
            output => result(0)
        );
    
    
    

--    debouncer: for i in 0 to 31 generate
--        regs: entity work.debouncer
--            generic map(
--                SYS_FREQ => 1,
--                COUNT    => 5
--            )
--            port map(
--                clk    => clk,
--                rst    => rst,
--                input  => input(i),
--                output => result(i)
--                --input  => input
--                --output => result
--            );
--    end generate;
    --debouncer2: 

end architecture RTL;
