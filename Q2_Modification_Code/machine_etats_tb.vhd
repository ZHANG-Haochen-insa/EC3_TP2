library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench pour machine_etats (Question 2 - avec modification de code)
entity machine_etats_tb is
end machine_etats_tb;

architecture Behavioral of machine_etats_tb is

    -- Déclaration du composant machine_etats
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

    -- Déclaration du composant memoire
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

    -- Signaux de test
    signal clk               : STD_LOGIC := '0';
    signal reset             : STD_LOGIC := '1';  -- Commencer avec reset actif
    signal contenu_bouton    : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal contenu_mem       : STD_LOGIC_VECTOR (3 downto 0);
    signal modif_code        : STD_LOGIC := '0';
    signal porte             : STD_LOGIC := '0';
    signal adresse_machine   : STD_LOGIC_VECTOR (1 downto 0);
    signal data_mem          : STD_LOGIC_VECTOR (3 downto 0);
    signal ouverture_porte   : STD_LOGIC;
    signal led_chang_code    : STD_LOGIC;
    signal wen               : STD_LOGIC;

    -- Constantes
    constant CLK_PERIOD : time := 10 ns;

    -- Code par défaut stocké en mémoire
    constant CODE_1 : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- BTND
    constant CODE_2 : STD_LOGIC_VECTOR(3 downto 0) := "0010"; -- BTNR
    constant CODE_3 : STD_LOGIC_VECTOR(3 downto 0) := "0100"; -- BTNU
    constant CODE_4 : STD_LOGIC_VECTOR(3 downto 0) := "1000"; -- BTNL

    -- Nouveau code pour le test de modification
    constant NEW_CODE_1 : STD_LOGIC_VECTOR(3 downto 0) := "1000"; -- BTNL
    constant NEW_CODE_2 : STD_LOGIC_VECTOR(3 downto 0) := "0100"; -- BTNU
    constant NEW_CODE_3 : STD_LOGIC_VECTOR(3 downto 0) := "0010"; -- BTNR
    constant NEW_CODE_4 : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- BTND

begin

    -- Instanciation de la mémoire
    UUT_MEM: memoire
        port map (
            clk             => clk,
            reset           => reset,
            wen             => wen,
            adresse         => adresse_machine,
            entree_memoire  => data_mem,
            sortie_memoire  => contenu_mem
        );

    -- Instanciation de la machine à états machine_etats
    UUT: machine_etats
        port map (
            clk               => clk,
            reset             => reset,
            contenu_bouton    => contenu_bouton,
            contenu_mem       => contenu_mem,
            modif_code        => modif_code,
            porte             => porte,
            adresse_machine   => adresse_machine,
            data_mem          => data_mem,
            ouverture_porte   => ouverture_porte,
            led_chang_code    => led_chang_code,
            wen               => wen
        );

    -- Génération de l'horloge
    CLK_PROCESS: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Processus de test
    STIM_PROCESS: process
    begin
        -- Initialisation
        report "===== DÉBUT DU TEST Q2 (avec modification de code) =====";
        contenu_bouton <= "0000";
        porte <= '0';
        modif_code <= '0';
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "Test 1: Vérification du reset";
        assert ouverture_porte = '0' report "ERREUR: La porte devrait être fermée après reset" severity error;
        assert led_chang_code = '0' report "ERREUR: LED changement devrait être éteinte" severity error;

        -- ====================================================================
        -- TEST 2: Vérification du code par défaut (0001, 0010, 0100, 1000)
        -- ====================================================================
        report "Test 2: Vérification avec le code par défaut";

        wait for CLK_PERIOD * 2;
        contenu_bouton <= CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_2;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_3;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_4;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        assert ouverture_porte = '1' report "ERREUR: La porte devrait être ouverte" severity error;
        report "SUCCESS: La porte s'ouvre avec le code par défaut";

        -- ====================================================================
        -- TEST 3: Entrer en mode modification de code
        -- ====================================================================
        report "Test 3: Activation du mode modification";
        wait for CLK_PERIOD * 2;
        modif_code <= '1';
        wait for CLK_PERIOD * 3;

        assert led_chang_code = '1' report "ERREUR: LED changement devrait être allumée" severity error;
        report "SUCCESS: Mode modification activé (LED allumée)";

        -- ====================================================================
        -- TEST 4: Saisie d'un nouveau code (1000, 0100, 0010, 0001)
        -- ====================================================================
        report "Test 4: Saisie du nouveau code";

        -- Nouveau code 1: 1000 (BTNL)
        wait for CLK_PERIOD * 2;
        contenu_bouton <= NEW_CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        -- Nouveau code 2: 0100 (BTNU)
        contenu_bouton <= NEW_CODE_2;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        -- Nouveau code 3: 0010 (BTNR)
        contenu_bouton <= NEW_CODE_3;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        -- Nouveau code 4: 0001 (BTND)
        contenu_bouton <= NEW_CODE_4;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 3;

        report "SUCCESS: Nouveau code saisi";

        -- ====================================================================
        -- TEST 5: Sortir du mode modification et tester l'ancien code
        -- ====================================================================
        report "Test 5: Test avec l'ancien code (devrait échouer)";
        modif_code <= '0';
        porte <= '0';
        wait for CLK_PERIOD * 3;

        -- Essayer l'ancien code (0001, 0010, 0100, 1000)
        contenu_bouton <= CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_2;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 3;

        assert ouverture_porte = '0' report "ERREUR: La porte ne devrait pas s'ouvrir avec l'ancien code" severity error;
        report "SUCCESS: L'ancien code ne fonctionne plus";

        -- ====================================================================
        -- TEST 6: Tester le nouveau code
        -- ====================================================================
        report "Test 6: Test avec le nouveau code (devrait réussir)";
        wait for CLK_PERIOD * 2;

        -- Nouveau code complet
        contenu_bouton <= NEW_CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= NEW_CODE_2;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= NEW_CODE_3;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= NEW_CODE_4;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        assert ouverture_porte = '1' report "ERREUR: La porte devrait s'ouvrir avec le nouveau code" severity error;
        report "SUCCESS: La porte s'ouvre avec le nouveau code";

        -- ====================================================================
        -- TEST 7: Vérification que le code a bien été enregistré en mémoire
        -- ====================================================================
        report "Test 7: Fermeture et ré-ouverture avec le nouveau code";
        porte <= '0';
        wait for CLK_PERIOD * 3;

        -- Ré-essayer le nouveau code
        contenu_bouton <= NEW_CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= NEW_CODE_2;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= NEW_CODE_3;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= NEW_CODE_4;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        assert ouverture_porte = '1' report "ERREUR: Le code devrait être persistant en mémoire" severity error;
        report "SUCCESS: Le nouveau code est bien enregistré en mémoire";

        -- ====================================================================
        -- FIN DU TEST
        -- ====================================================================
        wait for CLK_PERIOD * 10;
        report "===== TOUS LES TESTS Q2 SONT TERMINÉS =====";
        wait;
    end process;

end Behavioral;
