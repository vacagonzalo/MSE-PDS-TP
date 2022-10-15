LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY ape IS
    GENERIC (
        B : INTEGER := 12; -- Data width in bits
        N : INTEGER := 32; -- CFAR window size
        windows_ptr : INTEGER := 4
    );
    PORT (
        -- Common control signals -------------------------
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        ---------------------------------------------------

        -- APE inputs -------------------------------------
        entrant : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        outgoing : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        ---------------------------------------------------

        -- APE output -------------------------------------
        average : OUT STD_LOGIC_VECTOR(B - 1 DOWNTO 0)
        ---------------------------------------------------
    );
END ape;

ARCHITECTURE rtl OF ape IS
    CONSTANT ACC_GROWTH : NATURAL := NATURAL(ceil(log2(real(N))));
    FUNCTION saturated_addition(
        accu : STD_LOGIC_VECTOR(B + ACC_GROWTH DOWNTO 0);
        entr : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        sal : STD_LOGIC_VECTOR(B - 1 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE aux : STD_LOGIC_VECTOR(B + ACC_GROWTH DOWNTO 0);
        VARIABLE rtn : STD_LOGIC_VECTOR(B + ACC_GROWTH DOWNTO 0);
    BEGIN
        aux := STD_LOGIC_VECTOR(unsigned(accu) + unsigned(entr) - unsigned(sal));
        IF aux((B + ACC_GROWTH) - 1) /= '0' THEN
            rtn := (OTHERS => '1');
        ELSE
            rtn := aux;
        END IF;
        RETURN rtn;
    END FUNCTION saturated_addition;

BEGIN
    ape_sequence : PROCESS (clock) IS
        VARIABLE accumulator : STD_LOGIC_VECTOR((B + ACC_GROWTH) DOWNTO 0);
        VARIABLE data_mul : STD_LOGIC_VECTOR((B + ACC_GROWTH) DOWNTO 0);
        VARIABLE accumulator_2 : unsigned((B + ACC_GROWTH) DOWNTO 0);
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '0' THEN
                data_mul := (OTHERS => '0');
                accumulator := (OTHERS => '0');
                accumulator_2 := (OTHERS => '0');
            ELSIF enable = '1' THEN
                accumulator := saturated_addition(accumulator, entrant, outgoing);
                accumulator_2 := shift_right(unsigned(accumulator), windows_ptr);
                data_mul := STD_LOGIC_VECTOR(accumulator_2);
            END IF;
            average <= data_mul(B - 1 DOWNTO 0);
        END IF;
    END PROCESS ape_sequence;

END ARCHITECTURE rtl;