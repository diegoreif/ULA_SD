library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top_ula_fpga is
    port (
        clk_pin          : in  std_logic;                      -- FPGA clock
        btn_reset_pin    : in  std_logic;                      -- reset button
        btn_avanca_pin   : in  std_logic;                      -- state flow button
        chaves_pin       : in  std_logic_vector(3 downto 0);   -- 4 Chaves deslizantes (switches)
        
        leds_saida_pin   : out std_logic_vector(3 downto 0);   -- LEDs to show the final output
        led_negativo_pin : out std_logic;                      -- negative flag LED
        led_zero_pin     : out std_logic;                      -- zero flag LED
        led_cout_pin     : out std_logic;                      -- carry out flag LED
        led_ovf_pin      : out std_logic                       -- overflow carry LED
    );
end top_ula_fpga;

architecture rtl of top_ula_fpga is

    -- debouncer declaration
    component debouncer is
        port (
            clk     : in  std_logic;
            btn     : in  std_logic;
            res_btn : out std_logic
        );
    end component;

    -- ALU declaration
    component ula is
        port(
            clk            : in  std_logic;
            rst            : in  std_logic;
            btn            : in  std_logic;
            sel_geral      : in  std_logic_vector (3 downto 0); 
            saida          : out std_logic_vector (3 downto 0);
            flag_negativo  : out std_logic;
            flag_zero      : out std_logic;
            flag_carry_out : out std_logic;
            flag_overflow  : out std_logic
        );
    end component;

    -- internal signal to link debouncer output to ALU button input
    signal btn_limpo : std_logic;

begin

    -- debouncer instance
    inst_debouncer: debouncer port map (
        clk     => clk_pin,
        btn     => btn_avanca_pin,
        res_btn => btn_limpo        -- debouncer clean button output goes to top internal signal 
    );

    -- ALU instance
    inst_ula: ula port map (
        clk            => clk_pin,
        rst            => btn_reset_pin,
        btn            => btn_limpo,        -- top internal signal gets in ALU
        sel_geral      => chaves_pin,
        saida          => leds_saida_pin,
        flag_negativo  => led_negativo_pin,
        flag_zero      => led_zero_pin,
        flag_carry_out => led_cout_pin,
        flag_overflow  => led_ovf_pin
    );

end rtl;
