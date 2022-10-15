LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pds_fifo IS
    GENERIC (
        B : INTEGER := 12; -- Data width in bits
        N : INTEGER := 32; -- CFAR window size
        G : INTEGER := 8 -- CFAR guard size
    );
    PORT (
        -- Common control signals -------------------------------
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        ---------------------------------------------------------

        -- Input ------------------------------------------------
        entrant : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        ---------------------------------------------------------

        -- Outputs ----------------------------------------------
        left_half_entering : OUT STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        left_half_outgoing : OUT STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        evaluated : OUT STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        right_half_entering : OUT STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        right_half_outgoing : OUT STD_LOGIC_VECTOR(B - 1 DOWNTO 0)
        ---------------------------------------------------------
    );
END pds_fifo;

ARCHITECTURE rtl OF pds_fifo IS

    TYPE memory_t IS ARRAY (N + (2 * G) DOWNTO 0) OF STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    SIGNAL memory : memory_t;

BEGIN

    fifo_sequence : PROCESS (clock) IS
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '0' THEN
                FOR i IN (memory'left) DOWNTO (memory'right) LOOP
                    memory(i) <= (OTHERS => '0');
                END LOOP;
            ELSIF enable = '1' THEN
                FOR i IN (memory'left) DOWNTO (memory'right + 1) LOOP
                    memory(i - 1) <= memory(i);
                END LOOP;
                memory(memory'left) <= entrant;
            END IF;
        END IF;
    END PROCESS fifo_sequence;

    left_half_entering <= memory(memory'left);
    left_half_outgoing <= memory(memory'left - (N/2));

    evaluated <= memory((memory'left + memory'right) / 2);

    right_half_entering <= memory(memory'right + (N/2));
    right_half_outgoing <= memory(memory'right);

END ARCHITECTURE rtl;