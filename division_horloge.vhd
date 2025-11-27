library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entité pour diviser l'horloge système (ex: 100MHz) en une horloge plus lente.
entity division_horloge is
    Port ( 
        clk_in : in  STD_LOGIC;
        reset  : in  STD_LOGIC;
        clk_out: out STD_LOGIC
    );
end division_horloge;

architecture Behavioral of division_horloge is
    -- Un compteur pour la division. 25 bits avec une horloge de 100MHz
    -- donne une fréquence de sortie d'environ 100MHz / 2^25 ~= 3Hz.
    signal compteur : unsigned(24 downto 0) := (others => '0');
begin

    process(clk_in, reset)
    begin
        if reset = '1' then
            compteur <= (others => '0');
            clk_out <= '0';
        elsif rising_edge(clk_in) then
            compteur <= compteur + 1;
        end if;
    end process;
    
    -- La sortie bascule à chaque fois que le bit de poids fort du compteur change.
    clk_out <= compteur(24);

end Behavioral;
