library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench pour moore_q (Question 1 - Validation Basique)
entity tb_digicode is
end tb_digicode;

architecture Behavioral of tb_digicode is

    -- Déclaration du composant moore_q
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
    signal clk             : STD_LOGIC := '0';
    signal reset           : STD_LOGIC := '1';  -- Commencer avec reset actif
    signal contenu_bouton  : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal contenu_mem     : STD_LOGIC_VECTOR (3 downto 0);
    signal porte           : STD_LOGIC := '0';
    signal adresse_machine : STD_LOGIC_VECTOR (1 downto 0);
    signal ouverture_porte : STD_LOGIC;

    -- Note: wen et entree_memoire ne sont pas définis car Q1 n'utilise pas la fonction d'écriture
    -- Ces signaux seront fixés directement dans le port map de la mémoire

    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant DEBOUNCE_TIME : time := 50 ns; -- Temps pour simuler le debounce

    -- Code par défaut stocké en mémoire
    constant CODE_1 : STD_LOGIC_VECTOR(3 downto 0) := "0001"; -- BTND
    constant CODE_2 : STD_LOGIC_VECTOR(3 downto 0) := "0010"; -- BTNR
    constant CODE_3 : STD_LOGIC_VECTOR(3 downto 0) := "0100"; -- BTNU
    constant CODE_4 : STD_LOGIC_VECTOR(3 downto 0) := "1000"; -- BTNL

begin

    -- Instanciation de la mémoire (mode lecture seule pour Q1)
    UUT_MEM: memoire
        port map (
            clk             => clk,
            reset           => reset,
            wen             => '0',          -- Toujours '0' : pas d'écriture en Q1
            adresse         => adresse_machine,
            entree_memoire  => "0000",       -- Valeur non utilisée
            sortie_memoire  => contenu_mem
        );

    -- Instanciation de la machine à états moore_q
    UUT: moore_q
        port map (
            clk             => clk,
            reset           => reset,
            contenu_bouton  => contenu_bouton,
            contenu_mem     => contenu_mem,
            porte           => porte,
            adresse_machine => adresse_machine,
            ouverture_porte => ouverture_porte
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
        report "===== DÉBUT DU TEST =====";
        contenu_bouton <= "0000";
        porte <= '0';
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';
        wait for CLK_PERIOD * 2;

        report "Test 1: Vérification du reset";
        assert ouverture_porte = '0' report "ERREUR: La porte devrait être fermée après reset" severity error;
        assert adresse_machine = "00" report "ERREUR: L'adresse devrait être 00 après reset" severity error;

        -- ====================================================================
        -- TEST 2: Saisie du code CORRECT (0001, 0010, 0100, 1000)
        -- ====================================================================
        report "Test 2: Saisie du code correct";

        -- Premier chiffre: 0001 (BTND)
        wait for CLK_PERIOD * 2;
        contenu_bouton <= CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000"; -- Relâchement
        wait for CLK_PERIOD * 2;

        -- Deuxième chiffre: 0010 (BTNR)
        contenu_bouton <= CODE_2;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000"; -- Relâchement
        wait for CLK_PERIOD * 2;

        -- Troisième chiffre: 0100 (BTNU)
        contenu_bouton <= CODE_3;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000"; -- Relâchement
        wait for CLK_PERIOD * 2;

        -- Quatrième chiffre: 1000 (BTNL)
        contenu_bouton <= CODE_4;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000"; -- Relâchement
        wait for CLK_PERIOD * 2;

        -- Vérification que la porte est ouverte
        assert ouverture_porte = '1' report "ERREUR: La porte devrait être ouverte après code correct" severity error;
        report "SUCCESS: La porte est ouverte après code correct";

        -- ====================================================================
        -- TEST 3: Fermeture de la porte (porte passe de 0 à 1 puis retour à 0)
        -- ====================================================================
        report "Test 3: Fermeture de la porte";
        wait for CLK_PERIOD * 2;
        porte <= '1'; -- Simuler l'ouverture physique de la porte
        wait for CLK_PERIOD * 3;
        porte <= '0'; -- Fermeture de la porte
        wait for CLK_PERIOD * 3;

        -- Vérification que la machine retourne à l'état initial
        assert ouverture_porte = '0' report "ERREUR: La porte devrait être fermée" severity error;
        assert adresse_machine = "00" report "ERREUR: L'adresse devrait être 00 après fermeture" severity error;
        report "SUCCESS: La machine retourne à l'état initial après fermeture";

        -- ====================================================================
        -- TEST 4: Saisie d'un code INCORRECT (erreur au 2ème chiffre)
        -- ====================================================================
        report "Test 4: Saisie d'un code incorrect";
        wait for CLK_PERIOD * 2;

        -- Premier chiffre: 0001 (CORRECT)
        contenu_bouton <= CODE_1;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        -- Deuxième chiffre: 1000 (INCORRECT, devrait être 0010)
        contenu_bouton <= CODE_4;
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 3;

        -- Vérification que la porte reste fermée
        assert ouverture_porte = '0' report "ERREUR: La porte devrait rester fermée après code incorrect" severity error;
        assert adresse_machine = "00" report "ERREUR: La machine devrait retourner à l'adresse 00 après échec" severity error;
        report "SUCCESS: La porte reste fermée après code incorrect";

        -- ====================================================================
        -- TEST 5: Nouveau test avec code correct après un échec
        -- ====================================================================
        report "Test 5: Code correct après un échec";
        wait for CLK_PERIOD * 2;

        -- Saisie complète du code correct
        contenu_bouton <= CODE_1; -- 0001
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_2; -- 0010
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_3; -- 0100
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_4; -- 1000
        wait for CLK_PERIOD * 3;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        -- Vérification
        assert ouverture_porte = '1' report "ERREUR: La porte devrait être ouverte" severity error;
        report "SUCCESS: La porte s'ouvre après un nouvel essai correct";

        -- ====================================================================
        -- TEST 6: Test de l'adresse mémoire pendant la saisie
        -- ====================================================================
        report "Test 6: Vérification des adresses mémoire";
        porte <= '0';
        wait for CLK_PERIOD * 3;

        -- Vérifier que l'adresse change bien au fur et à mesure
        wait for CLK_PERIOD * 2;
        assert adresse_machine = "00" report "ERREUR: Adresse initiale devrait être 00" severity error;

        contenu_bouton <= CODE_1;
        wait for CLK_PERIOD * 2;
        assert adresse_machine = "00" report "ERREUR: Adresse devrait être 00 pour le 1er chiffre" severity error;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_2;
        wait for CLK_PERIOD * 2;
        assert adresse_machine = "01" report "ERREUR: Adresse devrait être 01 pour le 2ème chiffre" severity error;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_3;
        wait for CLK_PERIOD * 2;
        assert adresse_machine = "10" report "ERREUR: Adresse devrait être 10 pour le 3ème chiffre" severity error;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        contenu_bouton <= CODE_4;
        wait for CLK_PERIOD * 2;
        assert adresse_machine = "11" report "ERREUR: Adresse devrait être 11 pour le 4ème chiffre" severity error;
        contenu_bouton <= "0000";
        wait for CLK_PERIOD * 2;

        report "SUCCESS: Les adresses mémoire changent correctement";

        -- ====================================================================
        -- FIN DU TEST
        -- ====================================================================
        wait for CLK_PERIOD * 10;
        report "===== TOUS LES TESTS SONT TERMINÉS =====";
        wait;
    end process;

end Behavioral;
