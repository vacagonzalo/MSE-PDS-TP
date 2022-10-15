LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ctpe IS
    GENERIC (
        B : INTEGER := 12; -- Data width in bits
        N : INTEGER := 32; -- CFAR window size
        G : INTEGER := 8 -- CFAR guard size
    );
    PORT (
        -- Common control signals -------------------------
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        ---------------------------------------------------

        -- Filter control signals -------------------------
        cfar_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        scale_factor : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        ---------------------------------------------------

        -- Filter inputs ----------------------------------
        ape_left : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        ape_right : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        filter_input : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        ---------------------------------------------------

        -- Filter output ----------------------------------
        filter_output : OUT STD_LOGIC
        ---------------------------------------------------
    );
END ctpe;

ARCHITECTURE rtl OF ctpe IS

    TYPE algorithm_t IS (maximum, minimum, average);
    SIGNAL algorithm : algorithm_t;

    SIGNAL threshold : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    SIGNAL scaled_threshold : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);

    FUNCTION algorithm_selector(
        selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0))
        RETURN algorithm_t IS
        VARIABLE algo : algorithm_t;
    BEGIN
        IF selector = "00" THEN
            algo := maximum;
        ELSIF selector = "01" THEN
            algo := minimum;
        ELSE
            algo := average;
        END IF;
        RETURN algo;
    END FUNCTION algorithm_selector;

    FUNCTION get_maximum(
        alpha : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        bravo : STD_LOGIC_VECTOR(B - 1 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE charlie : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    BEGIN
        IF alpha > bravo THEN
            charlie := alpha;
        ELSE
            charlie := bravo;
        END IF;
        RETURN charlie;
    END FUNCTION get_maximum;

    FUNCTION get_minimum(
        alpha : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        bravo : STD_LOGIC_VECTOR(B - 1 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE charlie : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    BEGIN
        IF alpha < bravo THEN
            charlie := alpha;
        ELSE
            charlie := bravo;
        END IF;
        RETURN charlie;
    END FUNCTION get_minimum;

    FUNCTION get_average(
        alpha : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        bravo : STD_LOGIC_VECTOR(B - 1 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE charlie : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    BEGIN
        charlie := STD_LOGIC_VECTOR((unsigned(alpha)/2) + (unsigned(bravo)/2));
        RETURN charlie;
    END FUNCTION get_average;

    FUNCTION multiplication(
        alpha : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        bravo : STD_LOGIC_VECTOR(B - 1 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE charlie : STD_LOGIC_VECTOR((B * 2) - 1 DOWNTO 0);
        VARIABLE big_half : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        VARIABLE small_half : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        CONSTANT zero : STD_LOGIC_VECTOR(B - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        charlie := STD_LOGIC_VECTOR(unsigned(alpha) * unsigned(bravo));
        big_half := charlie((B * 2) - 1 DOWNTO B);
        small_half := charlie(B - 1 DOWNTO 0);
        IF big_half /= zero THEN
            small_half := (OTHERS => '1');
        END IF;
        RETURN small_half;
    END FUNCTION multiplication;

BEGIN
    state_machine : PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '0' THEN
                filter_output <= '0';
            ELSIF enable = '1' THEN

                algorithm <= algorithm_selector(cfar_selector);

                CASE algorithm IS
                    WHEN maximum => threshold <= get_maximum(ape_left, ape_right);
                    WHEN minimum => threshold <= get_minimum(ape_left, ape_right);
                    WHEN average => threshold <= get_average(ape_left, ape_right);
                END CASE;

                scaled_threshold <= multiplication(threshold, scale_factor);

                IF filter_input > scaled_threshold THEN
                    filter_output <= '1';
                ELSE
                    filter_output <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS state_machine;
END ARCHITECTURE rtl;