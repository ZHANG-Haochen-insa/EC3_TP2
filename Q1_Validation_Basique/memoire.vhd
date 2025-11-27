library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Mémoire pour stocker le code à 4 chiffres.
-- Peut être lue ou écrite.
entity memoire is
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        adresse         : in  STD_LOGIC_VECTOR (1 downto 0);
        sortie_memoire  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end memoire;

architecture Behavioral of memoire is
    -- Type pour un tableau de 4 mots de 4 bits
    type tcode is array (0 to 3) of std_logic_vector (3 downto 0);
    -- Signal interne pour stocker le code (initialisé avec le code par défaut)
    signal code : tcode := ("0001", "0010", "0100", "1000");

begin

    -- Processus de remise à zéro du code par défaut
    process (clk, reset)
    begin
        if reset = '1' then
            -- Initialisation du code par défaut au reset
            code(0) <= "0001"; -- BTND
            code(1) <= "0010"; -- BTNR
            code(2) <= "0100"; -- BTNU
            code(3) <= "1000"; -- BTNL
        end if;
    end process;

    -- Lecture asynchrone : la sortie reflète toujours le contenu à l'adresse sélectionnée
    sortie_memoire <= code(to_integer(unsigned(adresse)));
			
end Behavioral;