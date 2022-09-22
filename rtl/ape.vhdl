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
        average : out std_logic_vector(B-1 downto 0);
        ---------------------------------------------------
    );
end ape;

architecture rtl of ape is

    variable accumulator : std_logic_vector((N/2)-1 downto 0);

    function saturated_addition(
        accu : std_logic_vector((N/2)-1 downto 0);
        entr : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
        variable aux : std_logic_vector(N/2 downto 0);
        variable rtn : std_logic_vector((N/2)-1 downto 0);
    begin
        aux := std_logic_vector(unsigned(accu) + unsigned(entr));
        if aux'right /= '0' then
            rtn := (others => '1');
        else
            rtn := aux((N/2)-1 downto 0); -- ignore the MSB (carry)
        end if;
        return rtn;
    end function saturated_addition;

    function saturated_subtraction(
        accu : std_logic_vector((N/2)-1 downto 0);
        outg : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
        variable rtn : std_logic_vector((N/2)-1 downto 0);
    begin
        if accu < outg then
            rtn := (others => '0');
        else
            rtn := std_logic_vector(unsigned(accu) - unsigned(outg));
        end if;
        return rtn;
    end function saturated_subtraction;

begin
    sequence : process(clock) is
    begin
        if reset = '0' then
            average <= (others => '0');
        elsif enable = '1' then

        end if;
    end process sequence;

end architecture rtl;