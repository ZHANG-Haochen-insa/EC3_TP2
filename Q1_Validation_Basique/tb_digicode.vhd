library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Testbench simplifié pour la version basique (moore_q + memoire).
entity tb_digicode is
end tb_digicode;

architecture Behavioral of tb_digicode is

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

    component memoire is
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            adresse         : in  STD_LOGIC_VECTOR (1 downto 0);
            sortie_memoire  : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    signal clk             : STD_LOGIC := '0';
    signal reset           : STD_LOGIC := '1';
    signal contenu_bouton  : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal contenu_mem     : STD_LOGIC_VECTOR (3 downto 0);
    signal porte           : STD_LOGIC := '0';
    signal adresse_machine : STD_LOGIC_VECTOR (1 downto 0);
    signal ouverture_porte : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

    constant CODE_1 : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    constant CODE_2 : STD_LOGIC_VECTOR(3 downto 0) := "0010";
    constant CODE_3 : STD_LOGIC_VECTOR(3 downto 0) := "0100";
    constant CODE_4 : STD_LOGIC_VECTOR(3 downto 0) := "1000";

begin

    UUT_MEM: memoire
        port map (
            clk             => clk,
            reset           => reset,
            adresse         => adresse_machine,
            sortie_memoire  => contenu_mem
        );

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

    CLK_PROCESS: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    STIM_PROCESS: process
    begin
        -- phase de reset
        reset <= '1';
        porte <= '0';
        contenu_bouton <= (others => '0');
        wait for 5 * CLK_PERIOD;
        reset <= '0';
        wait for 5 * CLK_PERIOD;

        -- Séquence correcte
        contenu_bouton <= CODE_1;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_2;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_3;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_4;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 6 * CLK_PERIOD;

        -- Fermeture/retour à l'état initial
        porte <= '0';
        wait for 6 * CLK_PERIOD;

        -- Essai incorrect: mauvais second chiffre
        contenu_bouton <= CODE_1;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_4;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 6 * CLK_PERIOD;

        -- Nouvelle séquence correcte pour observer la réouverture
        contenu_bouton <= CODE_1;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_2;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_3;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait for 3 * CLK_PERIOD;

        contenu_bouton <= CODE_4;
        wait for 3 * CLK_PERIOD;
        contenu_bouton <= (others => '0');
        wait;
    end process;

end Behavioral;
