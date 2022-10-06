library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
    generic(
        B : integer := 12; -- Data width in bits
        N : integer := 32; -- CFAR window size
        G : integer := 8   -- CFAR guard size
    );
    port(
        -- Common control signals -------------------------------
        clock  : in std_logic;
        reset  : in std_logic;
        enable : in std_logic;
        ---------------------------------------------------------

        -- Input ------------------------------------------------
        entrant : in std_logic_vector(B-1 downto 0);
        ---------------------------------------------------------

        -- Outputs ----------------------------------------------
        left_half_entering  : out std_logic_vector(B-1 downto 0);
        left_half_outgoing  : out std_logic_vector(B-1 downto 0);
        evaluated           : out std_logic_vector(B-1 downto 0);
        right_half_entering : out std_logic_vector(B-1 downto 0);
        right_half_outgoing : out std_logic_vector(B-1 downto 0)
        ---------------------------------------------------------
    );
end fifo;

architecture rtl of fifo is

    type memory_t is array (N + (2 * G) downto 0) of std_logic_vector(B-1 downto 0);
    signal memory : memory_t;

begin

    sequence : process(clock) is
    begin
        if rising_edge(clock) then
            if reset = '0' then
                for i in (memory'left) downto (memory'right) loop
                    memory(i) <= (others => '0');
                end loop;
            elsif enable = '1' then
                for i in (memory'left) downto (memory'right + 1) loop
                    memory(i-1) <= memory(i);
                end loop;
                memory(memory'left) <= entrant;
            end if;
        end if;
    end process sequence;

    left_half_entering  <= memory(memory'left);
    left_half_outgoing  <= memory(memory'left - (N/2));

    evaluated <= memory((memory'left + memory'right) / 2);

    right_half_entering <= memory(memory'right + (N/2));
    right_half_outgoing <= memory(memory'right);

end architecture rtl;