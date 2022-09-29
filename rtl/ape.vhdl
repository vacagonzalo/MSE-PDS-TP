library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ape is
    generic(
        B : integer := 12; -- Data width in bits
        N : integer := 32; -- CFAR window size
        G : integer := 8   -- CFAR guard size
    );
    port(
        -- Common control signals -------------------------
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        ---------------------------------------------------

        -- APE inputs -------------------------------------
        entrant : in std_logic_vector(B-1 downto 0);
        outgoing : in std_logic_vector(B-1 downto 0);
        ---------------------------------------------------

        -- APE output -------------------------------------
        average : out std_logic_vector(B-1 downto 0)
        ---------------------------------------------------
    );
end ape;

architecture rtl of ape is

    signal accumulator : std_logic_vector((N/2)-1 downto 0);
    signal data_mul : std_logic_vector((N/2)-1 downto 0);
    
    function saturated_addition(
        accu : std_logic_vector((N/2)-1 downto 0);
        entr : std_logic_vector(B-1 downto 0);
        sal : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
        variable aux : std_logic_vector((N/2)-1 downto 0);
        variable rtn : std_logic_vector((N/2)-1 downto 0);
    begin
        aux := std_logic_vector(unsigned(accu) + unsigned(entr) - unsigned(sal));
        if aux((N/2)-1) /= '0' then
            rtn := (others => '1');
        else
            rtn := aux;
        end if;
        return rtn;
    end function saturated_addition;

begin
    sequence : process(clock) is
    begin
        if reset = '0' then
            average <= (others => '0');
            data_mul <= (others => '0');
            accumulator <= (others => '0');
        elsif enable = '1' then
            accumulator <= saturated_addition(accumulator,entrant,outgoing);
            data_mul <= accumulator;
        end if;
        average <= data_mul(B-1 DOWNTO 0);
    end process sequence;

end architecture rtl;