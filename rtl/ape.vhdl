library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity ape is
    generic(
        B : integer := 12; -- Data width in bits
        N : integer := 32; -- CFAR window size
        windows_ptr : integer := 4
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
    constant ACC_GROWTH  : natural := natural(ceil(log2(real(N))));
    function saturated_addition(
        accu : std_logic_vector(B+ACC_GROWTH downto 0);
        entr : std_logic_vector(B-1 downto 0);
        sal : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
        variable aux : std_logic_vector(B+ACC_GROWTH downto 0);
        variable rtn : std_logic_vector(B+ACC_GROWTH downto 0);
    begin
        aux := std_logic_vector(unsigned(accu) + unsigned(entr) - unsigned(sal));
        if aux((B+ACC_GROWTH)-1) /= '0' then
            rtn := (others => '1');
        else
            rtn := aux;
        end if;
        return rtn;
    end function saturated_addition;

begin
    sequence : process(clock) is
        variable accumulator : std_logic_vector((B+ACC_GROWTH) downto 0);
        variable data_mul : std_logic_vector((B+ACC_GROWTH) downto 0);
        variable accumulator_2 : unsigned((B+ACC_GROWTH) downto 0);
        begin
        if rising_edge(clock) then
            if reset = '0' then
                data_mul := (others => '0');
                accumulator := (others => '0');
                accumulator_2 := (others => '0');
            elsif enable = '1' then
                accumulator := saturated_addition(accumulator,entrant,outgoing);
                accumulator_2 := shift_right(unsigned(accumulator), windows_ptr);
                data_mul := std_logic_vector(accumulator_2); 
            end if;
            average <= data_mul(B-1 DOWNTO 0); 
        end if;       
    end process sequence;
    
end architecture rtl;