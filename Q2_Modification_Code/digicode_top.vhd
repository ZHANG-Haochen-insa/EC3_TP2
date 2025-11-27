library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entité principale du projet Digicode.
-- Elle connecte tous les sous-modules ensemble.
entity digicode_top is
    Port ( 
        -- Entrées globales
        CLK100MHZ   : in  STD_LOGIC; -- Horloge de la carte (ex: 100MHz sur Nexys A7)
        CPU_RESETN  : in  STD_LOGIC; -- Bouton de reset de la carte (actif à l'état bas)
        
        -- Boutons poussoirs pour le code
        BTND : in  STD_LOGIC;
        BTNR : in  STD_LOGIC;
        BTNU : in  STD_LOGIC;
        BTNL : in  STD_LOGIC;

        -- Interrupteurs
        SW0 : in  STD_LOGIC; -- Sera utilisé pour simuler la 'porte'
        SW1 : in  STD_LOGIC; -- Sera utilisé pour 'modif_code'

        -- LEDs de sortie
        LED0 : out STD_LOGIC; -- led_adresse(0)
        LED1 : out STD_LOGIC; -- led_adresse(1)
        LED2 : out STD_LOGIC; -- led_porte
        LED3 : out STD_LOGIC  -- led_chang_code
    );
end digicode_top;

architecture Behavioral of digicode_top is

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

    component machine_etats is
        Port ( 
            clk               : in  STD_LOGIC;
            reset             : in  STD_LOGIC;
            contenu_bouton    : in  STD_LOGIC_VECTOR (3 downto 0);
            contenu_mem       : in  STD_LOGIC_VECTOR (3 downto 0);
            modif_code        : in  STD_LOGIC;
            porte             : in  STD_LOGIC;
            adresse_machine   : out STD_LOGIC_VECTOR (1 downto 0);
            data_mem          : out STD_LOGIC_VECTOR (3 downto 0);
            ouverture_porte   : out STD_LOGIC;
            led_chang_code    : out STD_LOGIC;
            wen               : out STD_LOGIC
        );
    end component;

    -- Signaux internes pour relier les composants
    signal clk_divisee    : STD_LOGIC;
    signal reset_global   : STD_LOGIC;
    signal data_boutons   : STD_LOGIC_VECTOR(3 downto 0);
    signal data_from_mem  : STD_LOGIC_VECTOR(3 downto 0);
    signal addr_from_fsm  : STD_LOGIC_VECTOR(1 downto 0);
    signal data_to_mem    : STD_LOGIC_VECTOR(3 downto 0);
    signal wen_from_fsm   : STD_LOGIC;
    signal porte_ouverte  : STD_LOGIC;
    signal led_change     : STD_LOGIC;
    
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

    -- Instanciation de la mémoire
    U2_memoire : memoire
        port map (
            clk             => clk_divisee,
            reset           => reset_global,
            wen             => wen_from_fsm,
            adresse         => addr_from_fsm,
            entree_memoire  => data_to_mem,
            sortie_memoire  => data_from_mem
        );

    -- Instanciation de la machine à états
    U3_machine_etats : machine_etats
        port map (
            clk               => clk_divisee,
            reset             => reset_global,
            contenu_bouton    => data_boutons,
            contenu_mem       => data_from_mem,
            modif_code        => SW1, -- Switch 1 pour le mode modification
            porte             => SW0, -- Switch 0 pour simuler la porte
            adresse_machine   => addr_from_fsm,
            data_mem          => data_to_mem,
            ouverture_porte   => porte_ouverte,
            led_chang_code    => led_change,
            wen               => wen_from_fsm
        );

    -- Connexion des sorties aux LEDs physiques
    LED0 <= addr_from_fsm(0);
    LED1 <= addr_from_fsm(1);
    LED2 <= porte_ouverte;
    LED3 <= led_change;

end Behavioral;
