--
-- Rafael C.
-- ref:
--   - https://www.intel.com/content/www/us/en/programmable/quartushelp/13.0/mergedProjects/hdl/vhdl/vhdl_pro_state_machines.htm
--   - https://www.allaboutcircuits.com/technical-articles/implementing-a-finite-state-machine-in-vhdl/
--   - https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4096117

library IEEE;
use IEEE.std_logic_1164.all;

entity stepmotor is
    port (
        -- Gloabals
        clk   : in  std_logic;

        -- controls
        en      : in std_logic;                     -- 1 on/ 0 of
        dir     : in std_logic;                     -- 1 clock wise
        vel     : in std_logic_vector(1 downto 0);  -- 00: low / 11: fast
		  btn_rotation : in std_logic;

        -- I/Os
        phases  : out std_logic_vector(3 downto 0)
  );
end entity stepmotor;

architecture rtl of stepmotor is

   TYPE STATE_TYPE IS (s0, s1, s2, s3);
   SIGNAL state  : STATE_TYPE := s0;
   signal enable : std_logic  := '0';
	signal rotation : std_logic := '0';
   signal topCounter : integer range 0 to 50000000;
	
  
begin		
  process(clk)
  begin
    if (rising_edge(clk)) then
      CASE state IS
			WHEN s0=>
			  if (enable = '1') then
				 state <= s1;
			  end if;
			WHEN s1=>
			  if (enable = '1') then
				 state <= s2;
			  end if;
			WHEN s2=>
			  if (enable = '1') then
				 state <= s3;
			  end if;
			WHEN s3=>
			  if (enable = '1') then
				 state <= s0;
        end if;
      when others=>
        state <= s0;
      END CASE;
    end if;
  end process;

  PROCESS (state)
   BEGIN
		if(dir='0') then 
			CASE state IS
			  WHEN s0 =>
				 phases <= "0001";
			  WHEN s1 =>
				 phases <= "0010";
			  WHEN s2 =>
				 phases <= "0100";
			  when s3 =>
				 phases <= "1000";
			  when others =>
				 phases <= "0000";
			END CASE;
		else
			CASE state IS
			  WHEN s0 =>
				 phases <= "1000";
			  WHEN s1 =>
				 phases <= "0100";
			  WHEN s2 =>
				 phases <= "0010";
			  when s3 =>
				 phases <= "0001";
			  when others =>
				 phases <= "0000";
			END CASE;
		end if;
   END PROCESS;


  topCounter <= 50000000 when vel = "00" 
  else 300000 when vel = "01" 
  else 200000 when vel="10" 
  else 100000;
		

  process(clk)
    variable counter : integer range 0 to 50000000 := 0;
	 variable noventa_graus : integer := 2038;
	variable passos : integer := 0;
  begin
    if (rising_edge(clk)) then
		if(btn_rotation = '1') then 
			rotation <= '1';
		end if;
      if (counter < topCounter) then
        counter := counter + 1;
        enable  <= '0';
      else
        counter := 0;
			if (rotation='1') then
				enable <= '1';
				passos := passos + 1;
			elsif (passos=noventa_graus) then
				passos := 0;
				rotation <= '0';
				enable <= '0';
			end if;
			if (en='1') then
				enable <='1';
			else
				enable <= '0';
			end if;
      end if;
    end if;
  end process;

end rtl;
