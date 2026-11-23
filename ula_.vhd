library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula is

port(

    clk: in std_logic; -- system clock
    rst: in std_logic; -- reset the system
    btn: in std_logic; -- it allows state transitions
    sel_geral: in std_logic_vector (3 downto 0); -- general input bus
    saida: out std_logic_vector (3 downto 0); -- output

--flags

    flag_negativo: out std_logic; -- 1 only if the output is a negative number
    flag_zero: out std_logic; -- 1 only if the output is the zero vector
    flag_carry_out: out std_logic; -- 1 only if the output contains carry out
    flag_overflow: out std_logic -- 1 only if the output is outside of the 4 bits range values

    );

end ula;

architecture Behavioral of ula is

type state is (load_sel, load_a, load_b, load_exe); --state machine of the ALU

signal st_atual: state := load_sel; -- current state of FSM
signal sel: std_logic_vector(2 downto 0) := (others => '0'); -- selector vector
signal a: std_logic_vector(3 downto 0) := (others => '0'); -- a binary number
signal b: std_logic_vector(3 downto 0) := (others => '0'); -- b binary number

begin

process(clk, rst)
    variable res_interno : std_logic_vector(4 downto 0); -- adds an extra bit to storage carry out
    variable res_4bit    : std_logic_vector(3 downto 0); -- user's output
    variable carry_temp  : std_logic; -- storages temporary carry out
    variable ovf_temp    : std_logic; -- storages temporary overflow
begin
    if rst = '1' then
        st_atual       <= load_sel; 
        a              <= (others => '0');
        b              <= (others => '0');
        sel            <= (others => '0');
        saida          <= (others => '0');
        flag_negativo  <= '0';
        flag_zero      <= '0';
        flag_carry_out <= '0';
        flag_overflow  <= '0';

    elsif rising_edge(clk) then

	res_interno := (others => '0');
        res_4bit    := (others => '0');
        carry_temp  := '0';
        ovf_temp    := '0';

        case st_atual is

            when load_sel => -- time to select the operation of ALU
                if btn = '1' then
                    sel      <= sel_geral(2 downto 0);
                    st_atual <= load_a;
                end if;

            when load_a => -- time to input A
                if btn = '1' then
                    a        <= sel_geral;
                    st_atual <= load_b;
                end if;
	
            when load_b => -- time to input B
                if btn = '1' then
                    b        <= sel_geral;
                    st_atual <= load_exe;
                end if;

            when load_exe => -- execution of the operation
                -- standard values
                res_4bit    := (others => '0');
                res_interno := (others => '0');
                carry_temp  := '0';
                ovf_temp    := '0';

                case sel is

                    when "000" => -- sum
                        res_interno := std_logic_vector(unsigned('0' & a) + unsigned('0' & b));
                        res_4bit    := res_interno(3 downto 0);
                        carry_temp  := res_interno(4);
                        ovf_temp    := (a(3) xnor b(3)) and (a(3) xor res_4bit(3));

                    when "001" => -- subtraction
                        res_interno := std_logic_vector(unsigned('0' & a) - unsigned('0' & b));
                        res_4bit    := res_interno(3 downto 0);
                        carry_temp  := res_interno(4); -- borrow
                        ovf_temp    := (a(3) xor b(3)) and (a(3) xor res_4bit(3));

                    when "010" => -- a + 1
                        res_interno := std_logic_vector(unsigned('0' & a) + to_unsigned(1, 5));
                        res_4bit    := res_interno(3 downto 0);
                        carry_temp  := res_interno(4);
                        ovf_temp    := (not a(3)) and res_4bit(3);

                    when "011" => -- -a
                        res_4bit := std_logic_vector(-signed(a));
                        if a = "1000" then
                            ovf_temp := '1';
                        end if;

                    when "100" => -- and
                        res_4bit := a and b;

                    when "101" => -- or
                        res_4bit := a or b;

                    when "110" => -- xor
                        res_4bit := a xor b;

                    when "111" => -- xnor
                        res_4bit := a xnor b;

                    when others =>
                        res_4bit := (others => '0');

                end case;

                saida          <= res_4bit;
                flag_negativo  <= res_4bit(3);
                flag_carry_out <= carry_temp;
                flag_overflow  <= ovf_temp;
		if res_4bit = "0000" then
                	flag_zero      <= '1';
		else 
			flag_zero <= '0';
		end if;
                if btn = '1' then
                    st_atual <= load_sel;
                end if;

            when others =>
                st_atual <= load_sel;

        end case;
    end if;
end process;
end Behavioral;