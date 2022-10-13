library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cfar is
    generic(
        B : integer := 12; -- Data width in bits
        N : integer := 32; -- CFAR window size
        G : integer := 8;  -- CFAR guard size
        windows_ptr : integer := 4
    );
    port(
        -- Common control signals -------------------------
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        ---------------------------------------------------

        -- Input ------------------------------------------
        cfar_selector : in std_logic_vector(1 downto 0);
        scale_factor : in std_logic_vector(B-1 downto 0);
        entrant : in std_logic_vector(B-1 downto 0);
        ---------------------------------------------------

        -- Outputs ----------------------------------------
        filter_output : out std_logic
        ---------------------------------------------------
    );
end cfar;

architecture hierarchical of cfar is

    signal left_entering : std_logic_vector(B-1 downto 0);
    signal left_outgoing : std_logic_vector(B-1 downto 0);

    signal right_entering : std_logic_vector(B-1 downto 0);
    signal right_outgoing : std_logic_vector(B-1 downto 0);

    signal left_average  : std_logic_vector(B-1 downto 0);
    signal right_average : std_logic_vector(B-1 downto 0);

    signal evaluated : std_logic_vector(B-1 downto 0);

begin

    fifo_buffer : entity work.pds_fifo(rtl)
        generic map (
            B => B,
            N => N,
            G => G
        )
        port map (
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

    left_ape : entity work.ape(rtl)
        generic map (
            B => B,
            N => N,
            windows_ptr => windows_ptr
        )
        port map (
            -- Common control signals -------------------------
            clock  => clock,
            reset  => reset,
            enable => enable,
            ---------------------------------------------------

            -- APE inputs -------------------------------------
            entrant  => left_entering,
            outgoing => left_outgoing,
            ---------------------------------------------------

            -- APE output -------------------------------------
            average => left_average
            ---------------------------------------------------
        );

    right_ape : entity work.ape(rtl)
        generic map (
            B => B,
            N => N,
            windows_ptr => windows_ptr
        )
        port map (
            -- Common control signals -------------------------
            clock  => clock,
            reset  => reset,
            enable => enable,
            ---------------------------------------------------

            -- APE inputs -------------------------------------
            entrant  => right_entering,
            outgoing => right_outgoing,
            ---------------------------------------------------

            -- APE output -------------------------------------
            average => right_average
            ---------------------------------------------------
        );

    ctpe_block : entity work.ctpe(rtl)
        generic map (
            B => B,
            N => N,
            G => G
        )
        port map (
            -- Common control signals -------------------------
            clock => clock,
            reset => reset,
            enable => enable,
            ---------------------------------------------------

            -- Filter control signals -------------------------
            cfar_selector => cfar_selector,
            scale_factor  => scale_factor,
            ---------------------------------------------------

            -- Filter inputs ----------------------------------
            ape_left     => left_average,
            ape_right    => right_average,
            filter_input => evaluated,
            ---------------------------------------------------

            -- Filter output ----------------------------------
            filter_output => filter_output
            ---------------------------------------------------
        );

end architecture hierarchical;