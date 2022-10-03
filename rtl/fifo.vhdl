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
        -- Common control signals -------------------------
        clock : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        ---------------------------------------------------

        -- Input ------------------------------------------
        entrant : in std_logic_vector(B-1 downto 0);
        ---------------------------------------------------

        -- Outputs -----------------------------------------
        left_half : out std_logic_vector(B-1 downto 0);
        evaluated : out std_logic_vector(B-1 downto 0);
        right_half : out std_logic_vector(B-1 downto 0)
        ---------------------------------------------------
    );
end fifo;

architecture rtl of fifo is

    constant half_size : integer := B * (N / 2);
    constant guard_size : integer := B * G;
    constant eval_size : integer := B * 1;

    constant block_size : integer := (half_size * 2) + (guard_size * 2) + eval_size;

    signal aux : std_logic_vector(block_size - 1 downto 0);

    constant eval_high : integer := aux'high - half_size - guard_size;
    constant eval_low : integer := aux'low + half_size + guard_size;

begin

    sequence : process(clock) is
    begin
        if rising_edge(clock) then
            if reset = '0' then
                aux <= (others => '0');
            elsif enable = '1' then
                -- shift to the right by slicing and concatenating
                aux <= aux(aux'high - B downto aux'low) & entrant;
            end if;
        end if;
    end process sequence;

    left_half <= aux(aux'high downto (aux'high - left_half'high));
    evaluated <= aux(eval_high downto eval_low);
    right_half <= aux((aux'low + right_half'high) downto aux'low);

end architecture rtl;