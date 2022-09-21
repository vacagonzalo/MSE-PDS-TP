library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctpe is
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

        -- Filter control signals -------------------------
        cfar_selector : in std_logic_vector(1 downto 0);
        scale_factor : in std_logic_vector(B-1 downto 0);
        ---------------------------------------------------

        -- Filter inputs ----------------------------------
        ape_left : in std_logic_vector(B-1 downto 0);
        ape_right : in std_logic_vector(B-1 downto 0);
        filter_input : in std_logic_vector(B-1 downto 0);
        ---------------------------------------------------

        -- Filter output ----------------------------------
        filter_output : out std_logic
        ---------------------------------------------------
    );
end ctpe;

architecture rtl of ctpe is

    type algorithm_t is (maximum, minimum, average);
    signal algorithm : algorithm_t;

    signal threshold : std_logic_vector(B-1 downto 0);
    signal scaled_threshold : std_logic_vector(B-1 downto 0);

    function algorithm_selector(
        selector : in std_logic_vector(1 downto 0))
        return algorithm_t is
    variable algo : algorithm_t;
    begin
        if selector = "00" then
            algo := maximum;
        elsif selector = "01" then
            algo := minimum;
        else
            algo := average;
        end if;
        return algo;
    end function algorithm_selector;

    function get_maximum(
        alpha : std_logic_vector(B-1 downto 0);
        bravo : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
    variable charlie : std_logic_vector(B-1 downto 0);
    begin
        if alpha > bravo then
            charlie := alpha;
        else
            charlie := bravo;
        end if;
        return charlie;
    end function get_maximum;

    function get_minimum(
        alpha : std_logic_vector(B-1 downto 0);
        bravo : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
    variable charlie : std_logic_vector(B-1 downto 0);
    begin
        if alpha < bravo then
            charlie := alpha;
        else
            charlie := bravo;
        end if;
        return charlie;
    end function get_minimum;

    function get_average(
        alpha : std_logic_vector(B-1 downto 0);
        bravo : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
    variable charlie : std_logic_vector(B-1 downto 0);
    begin
        charlie := std_logic_vector( (unsigned(alpha)/2) + (unsigned(bravo)/2) );
        return charlie;
    end function get_average;

    function multiplication(
        alpha : std_logic_vector(B-1 downto 0);
        bravo : std_logic_vector(B-1 downto 0))
        return std_logic_vector is
    variable charlie : std_logic_vector((B*2)-1 downto 0);
    variable big_half : std_logic_vector(B-1 downto 0);
    variable small_half : std_logic_vector(B-1 downto 0);
    constant zero : std_logic_vector(B-1 downto 0) := (others => '0');
    begin
        charlie := std_logic_vector(unsigned(alpha) * unsigned(bravo));
        big_half := charlie((B*2)-1 downto B);
        small_half := charlie(B-1 downto 0);
        if big_half /= zero then
            small_half := (others => '1');
        end if;
        return small_half;
    end function multiplication;

begin
    state_machine : process(clock) is
    begin
        if rising_edge(clock) then
            if reset = '0' then
                filter_output <= '0';
            elsif enable = '1' then

                algorithm <= algorithm_selector(cfar_selector);

                case algorithm is
                    when maximum => threshold <= get_maximum(ape_left, ape_right);
                    when minimum => threshold <= get_minimum(ape_left, ape_right);
                    when average => threshold <= get_average(ape_left, ape_right);
                end case;

                scaled_threshold <= multiplication(threshold, scale_factor);

                if filter_input > scaled_threshold then
                    filter_output <= '1';
                else
                    filter_output <= '0';
                end if;
            end if;
        end if;
    end process state_machine;
end architecture rtl;