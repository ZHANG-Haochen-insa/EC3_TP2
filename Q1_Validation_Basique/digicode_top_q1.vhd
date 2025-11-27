library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entité principale du projet Digicode - Question 1 (Validation basique)
-- Cette version utilise la machine moore_q1 simplifiée à 9 états
entity digicode_top_q1 is
    Port (
        -- Entrées globales
        CLK100MHZ   : in  STD_LOGIC; -- Horloge de la carte (ex: 100MHz sur Nexys A7)
        CPU_RESETN  : in  STD_LOGIC; -- Bouton de reset de la carte

        -- Boutons poussoirs pour le code
        BTND : in  STD_LOGIC;
        BTNR : in  STD_LOGIC;
        BTNU : in  STD_LOGIC;
        BTNL : in  STD_LOGIC;

        -- Interrupteur
        SW0 : in  STD_LOGIC; -- Sera utilisé pour simuler la 'porte'

        -- LEDs de sortie
        LED0 : out STD_LOGIC; -- led_adresse(0)
        LED1 : out STD_LOGIC; -- led_adresse(1)
        LED2 : out STD_LOGIC  -- led_porte (ouverture_porte)
    );
end digicode_top_q1;

architecture Behavioral of digicode_top_q1 is

    -- Déclaration des composants qui seront instanciés
    component division_horloge is
        Port (
            clk_in  : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            clk_out : out STD_LOGIC
        );
    end component;

    component memoire is
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            wen             : in  STD_LOGIC;
            adresse         : in  STD_LOGIC_VECTOR (1 downto 0);
            entree_memoire  : in  STD_LOGIC_VECTOR (3 downto 0);
            sortie_memoire  : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component moore_q is
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            contenu_bouton  : in  STD_LOGIC_VECTOR (3 downto 0);
            contenu_mem     : in  STD_LOGIC_VECTOR (3 downto 0);
            porte           : in  STD_LOGIC;
            adresse_machine : out STD_LOGIC_VECTOR (1 downto 0);
            ouverture_porte : out STD_LOGIC
        );
    end component;

    -- Signaux internes pour relier les composants
    signal clk_divisee    : STD_LOGIC;
    signal reset_global   : STD_LOGIC;
    signal data_boutons   : STD_LOGIC_VECTOR(3 downto 0);
    signal data_from_mem  : STD_LOGIC_VECTOR(3 downto 0);
    signal addr_from_fsm  : STD_LOGIC_VECTOR(1 downto 0);
    signal porte_ouverte  : STD_LOGIC;

    -- Note: wen et data_to_mem ne sont pas définis car Q1 n'utilise pas la fonction d'écriture
    -- Ces signaux seront fixés directement dans le port map de la mémoire

begin

    -- Le reset de la carte : utilisation directe sans inversion.
    reset_global <= CPU_RESETN;

    -- Concaténation des entrées des boutons en un seul vecteur.
    -- L'ordre est important : BTNL, BTNU, BTNR, BTND
    data_boutons <= BTNL & BTNU & BTNR & BTND;

    -- Instanciation du diviseur d'horloge
    U1_div_horloge : division_horloge
        port map (
            clk_in  => CLK100MHZ,
            reset   => reset_global,
            clk_out => clk_divisee
        );

    -- Instanciation de la mémoire (mode lecture seule pour Q1)
    U2_memoire : memoire
        port map (
            clk             => clk_divisee,
            reset           => reset_global,
            wen             => '0',          -- Toujours '0' : pas d'écriture en Q1
            adresse         => addr_from_fsm,
            entree_memoire  => "0000",       -- Valeur non utilisée
            sortie_memoire  => data_from_mem
        );

    -- Instanciation de la machine à états moore_q (version simplifiée)
    U3_moore_q : moore_q
        port map (
            clk             => clk_divisee,
            reset           => reset_global,
            contenu_bouton  => data_boutons,
            contenu_mem     => data_from_mem,
            porte           => SW0,
            adresse_machine => addr_from_fsm,
            ouverture_porte => porte_ouverte
        );

    -- Connexion des sorties aux LEDs physiques
    LED0 <= addr_from_fsm(0);
    LED1 <= addr_from_fsm(1);
    LED2 <= porte_ouverte;

end Behavioral;
