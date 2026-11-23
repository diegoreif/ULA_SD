library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debouncer is
	port (
		clk, btn: in std_logic; -- system clock and button input
		res_btn: out std_logic := '0' -- debounced button output
		);
end debouncer;

architecture Debouncer_Behavioral of debouncer is

constant max: integer := 1000000; -- limit for debounce delay
signal count: integer range 0 to max := 0; -- debouncer time counter
signal prev_btn: std_logic := '0'; -- storages previous button state 

signal btn_estavel: std_logic := '0'; -- stable button state
signal prev_btn_estavel: std_logic := '0'; -- storages previous stable state

begin
process(clk)
	begin
	if rising_edge(clk) then

		-- detects button state change an starts counter
		if btn /= prev_btn and count = 0 then 
            count <= 1; 
		end if;
		
		-- counter logic to filter bouncing
		if count > 0 then
			if count < max then 
                count <= count + 1;
			else 
				count <= 0; -- resets counter after delay
				btn_estavel <= btn; -- updates stable state
			end if;
		end if;
		
	    prev_btn <= btn; -- updates previous button state

        prev_btn_estavel <= btn_estavel; -- updates previous stable state
        
		-- finally the button signal got filtered
        if btn_estavel = '1' and prev_btn_estavel = '0' then
            res_btn <= '1'; 
        else
            res_btn <= '0'; 
        end if;

	end if;
end process;

end Debouncer_Behavioral;
