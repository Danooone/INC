-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Daniil Zverev (xzvere00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK:        in std_logic;
        RST:        in std_logic;
        DIN:        in std_logic;
        DOUT:       out std_logic_vector(7 downto 0);
        DOUT_VLD :  out std_logic := '0'
    );
end entity UART_RX;  

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    constant CNT_INIT  : std_logic_vector(4 downto 0) := "00000";
    constant CNT2_INIT : std_logic_vector(3 downto 0) := "0000";

    signal cnt         : std_logic_vector(4 downto 0) := CNT_INIT;
    signal cnt2        : std_logic_vector(3 downto 0) := CNT2_INIT;
    signal rx_en       : std_logic;
    signal cnt_en      : std_logic;
    signal dout_valid  : std_logic;
begin
  FSM: entity work.UART_RX_FSM(behavioral)
  port map(
    CLK         => clk,
    RST         => rst,
    DIN         => din,
    RX_EN       => rx_en,
    CNT         => cnt,
    CNT2        => cnt2,
    CNT_EN      => cnt_en,
    DOUT_VALID  => dout_valid
  );

  DOUT_VLD <= dout_valid;  
  process (CLK) begin
    if rising_edge (CLK) then
      
      if RST = '1' then
        cnt <= CNT_INIT;
        cnt2 <= CNT2_INIT;
        
       else
        if cnt_en = '1' then
          cnt <= cnt+1;
          
        elsif cnt2(3) = '1' then
          cnt <= CNT_INIT;
          cnt2 <= CNT2_INIT;
        end if;
        
        if rx_en = '1' and cnt(4) = '1' then
          cnt <= CNT_INIT;
          
          for i in 0 to 7 loop
            if cnt2 = std_logic_vector(to_unsigned(i, 4)) then
              DOUT(i) <= DIN;
            end if;
          end loop;
          
          cnt2 <= cnt2 + 1;
          
        elsif rx_en = '0' then
          cnt2 <= CNT2_INIT;
        end if;
      end if;
    end if;  
  end process;
end architecture behavioral;
