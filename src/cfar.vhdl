LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY cfar IS
    GENERIC (
        B : INTEGER := 12; -- Data width in bits
        N : INTEGER := 32; -- CFAR window size
        G : INTEGER := 8; -- CFAR guard size
        windows_ptr : INTEGER := 4
    );
    PORT (
        -- Common control signals -------------------------
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        ---------------------------------------------------

        -- Input ------------------------------------------
        cfar_selector : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        scale_factor : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        entrant : IN STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
        ---------------------------------------------------

        -- Outputs ----------------------------------------
        filter_output : OUT STD_LOGIC
        ---------------------------------------------------
    );
END cfar;

ARCHITECTURE hierarchical OF cfar IS

    SIGNAL left_entering : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    SIGNAL left_outgoing : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);

    SIGNAL right_entering : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    SIGNAL right_outgoing : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);

    SIGNAL left_average : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);
    SIGNAL right_average : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);

    SIGNAL evaluated : STD_LOGIC_VECTOR(B - 1 DOWNTO 0);

BEGIN

    fifo_buffer : ENTITY work.pds_fifo(rtl)
        GENERIC MAP(
            B => B,
            N => N,
            G => G
        )
        PORT MAP(
            -- Common control signals -------------------------
            clock => clock,
            reset => reset,
            enable => enable,
            ---------------------------------------------------

            -- Input ------------------------------------------
            entrant => entrant,
            ---------------------------------------------------

            -- Outputs ----------------------------------------
            left_half_entering => left_entering,
            left_half_outgoing => left_outgoing,
            evaluated => evaluated,
            right_half_entering => right_entering,
            right_half_outgoing => right_outgoing
            ---------------------------------------------------
        );

    left_ape : ENTITY work.ape(rtl)
        GENERIC MAP(
            B => B,
            N => N,
            windows_ptr => windows_ptr
        )
        PORT MAP(
            -- Common control signals -------------------------
            clock => clock,
            reset => reset,
            enable => enable,
            ---------------------------------------------------

            -- APE inputs -------------------------------------
            entrant => left_entering,
            outgoing => left_outgoing,
            ---------------------------------------------------

            -- APE output -------------------------------------
            average => left_average
            ---------------------------------------------------
        );

    right_ape : ENTITY work.ape(rtl)
        GENERIC MAP(
            B => B,
            N => N,
            windows_ptr => windows_ptr
        )
        PORT MAP(
            -- Common control signals -------------------------
            clock => clock,
            reset => reset,
            enable => enable,
            ---------------------------------------------------

            -- APE inputs -------------------------------------
            entrant => right_entering,
            outgoing => right_outgoing,
            ---------------------------------------------------

            -- APE output -------------------------------------
            average => right_average
            ---------------------------------------------------
        );

    ctpe_block : ENTITY work.ctpe(rtl)
        GENERIC MAP(
            B => B,
            N => N,
            G => G
        )
        PORT MAP(
            -- Common control signals -------------------------
            clock => clock,
            reset => reset,
            enable => enable,
            ---------------------------------------------------

            -- Filter control signals -------------------------
            cfar_selector => cfar_selector,
            scale_factor => scale_factor,
            ---------------------------------------------------

            -- Filter inputs ----------------------------------
            ape_left => left_average,
            ape_right => right_average,
            filter_input => evaluated,
            ---------------------------------------------------

            -- Filter output ----------------------------------
            filter_output => filter_output
            ---------------------------------------------------
        );

END ARCHITECTURE hierarchical;