library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Machine à états finis pour la logique du digicode.
entity machine_etats is
    Port ( 
        clk               : in  STD_LOGIC;
        reset             : in  STD_LOGIC;
        -- Entrées des boutons et switchs
        contenu_bouton    : in  STD_LOGIC_VECTOR (3 downto 0); -- Valeur du bouton poussoir pressé
        contenu_mem       : in  STD_LOGIC_VECTOR (3 downto 0); -- Valeur lue de la mémoire
        modif_code        : in  STD_LOGIC; -- Switch pour passer en mode modification
        porte             : in  STD_LOGIC; -- Switch pour indiquer si la porte est fermée (0) ou ouverte (1)
        -- Sorties vers les autres composants et LEDs
        adresse_machine   : out STD_LOGIC_VECTOR (1 downto 0); -- Adresse à lire/écrire en mémoire
        data_mem          : out STD_LOGIC_VECTOR (3 downto 0); -- Donnée à écrire en mémoire (le bouton pressé)
        ouverture_porte   : out STD_LOGIC; -- Signal pour ouvrir la porte (LED)
        led_chang_code    : out STD_LOGIC; -- LED indiquant le mode changement de code
        wen               : out STD_LOGIC  -- Write Enable pour la mémoire
    );
end machine_etats;

architecture Behavioral of machine_etats is

    -- Définition des états de la machine
    type state_type is (
        ST_IDLE,          -- Attente de la première saisie
        ST_CHECK_1, ST_WAIT_REL_1, -- Vérification du 1er chiffre et attente du relâchement
        ST_CHECK_2, ST_WAIT_REL_2, -- Vérification du 2ème chiffre
        ST_CHECK_3, ST_WAIT_REL_3, -- Vérification du 3ème chiffre
        ST_CHECK_4, ST_WAIT_REL_4, -- Vérification du 4ème chiffre
        ST_SUCCESS,       -- Code correct
        ST_FAIL,          -- Code incorrect
        ST_OPEN,          -- Porte ouverte, en attente de fermeture
        ST_GOTO_CHANGE,   -- Etat intermédiaire pour passer en mode changement
        ST_CHANGE_MODE,   -- En mode changement de code, attente de la 1ère saisie
        ST_WRITE_1, ST_WAIT_WRITE_REL_1, -- Ecriture du 1er chiffre
        ST_WRITE_2, ST_WAIT_WRITE_REL_2, -- Ecriture du 2ème chiffre
        ST_WRITE_3, ST_WAIT_WRITE_REL_3, -- Ecriture du 3ème chiffre
        ST_WRITE_4, ST_WAIT_WRITE_REL_4  -- Ecriture du 4ème chiffre
    );
    signal state, next_state : state_type := ST_IDLE;

    -- Signal pour savoir si un bouton est pressé (différent de "0000")
    signal bouton_presse : std_logic;

begin

    -- Processus synchrone pour la mise à jour de l'état
    SYNC_PROC: process (clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state <= ST_IDLE;
            else
                state <= next_state;
            end if;        
        end if;
    end process;

    -- Logique de sortie (style Moore)
    OUTPUT_DECODE: process (state)
    begin
        -- Initialisation des sorties par défaut
        ouverture_porte <= '0';
        led_chang_code  <= '0';
        wen             <= '0';
        data_mem        <= "0000";
        adresse_machine <= "00";

        case state is
            when ST_IDLE =>
                adresse_machine <= "00";
            when ST_CHECK_1 | ST_WAIT_REL_1 =>
                adresse_machine <= "00";
            when ST_CHECK_2 | ST_WAIT_REL_2 =>
                adresse_machine <= "01";
            when ST_CHECK_3 | ST_WAIT_REL_3 =>
                adresse_machine <= "10";
            when ST_CHECK_4 | ST_WAIT_REL_4 =>
                adresse_machine <= "11";
            when ST_SUCCESS =>
                ouverture_porte <= '1';
            when ST_OPEN =>
                ouverture_porte <= '1';
            when ST_GOTO_CHANGE | ST_CHANGE_MODE | ST_WRITE_1 | ST_WAIT_WRITE_REL_1 | ST_WRITE_2 | ST_WAIT_WRITE_REL_2 | ST_WRITE_3 | ST_WAIT_WRITE_REL_3 | ST_WRITE_4 | ST_WAIT_WRITE_REL_4 =>
                led_chang_code <= '1';
            when others => -- Inclut ST_FAIL
                null;
        end case;
    end process;

    -- Logique de transition d'états
    NEXT_STATE_DECODE: process (state, contenu_bouton, contenu_mem, modif_code, porte, bouton_presse)
    begin
        -- Par défaut, on reste dans le même état
        next_state <= state;
        -- Le signal de sortie pour l'écriture est positionné ici (style Mealy pour la simplicité)
        wen <= '0';
        data_mem <= contenu_bouton;

        case state is
            -------------------- SÉQUENCE DE VÉRIFICATION --------------------
            when ST_IDLE =>
                if bouton_presse = '1' then
                    next_state <= ST_CHECK_1;
                end if;

            when ST_CHECK_1 =>
                if contenu_bouton = contenu_mem then
                    next_state <= ST_WAIT_REL_1;
                else
                    next_state <= ST_FAIL;
                end if;
            
            when ST_WAIT_REL_1 =>
                if bouton_presse = '0' then
                    next_state <= ST_CHECK_2;
                end if;

            when ST_CHECK_2 =>
                if bouton_presse = '0' then
                    next_state <= ST_CHECK_2; -- Attendre une nouvelle pression
                elsif contenu_bouton = contenu_mem then
                    next_state <= ST_WAIT_REL_2;
                else
                    next_state <= ST_FAIL;
                end if;

            when ST_WAIT_REL_2 =>
                if bouton_presse = '0' then
                    next_state <= ST_CHECK_3;
                end if;

            when ST_CHECK_3 =>
                if bouton_presse = '0' then
                    next_state <= ST_CHECK_3;
                elsif contenu_bouton = contenu_mem then
                    next_state <= ST_WAIT_REL_3;
                else
                    next_state <= ST_FAIL;
                end if;

            when ST_WAIT_REL_3 =>
                if bouton_presse = '0' then
                    next_state <= ST_CHECK_4;
                end if;

            when ST_CHECK_4 =>
                if bouton_presse = '0' then
                    next_state <= ST_CHECK_4;
                elsif contenu_bouton = contenu_mem then
                    next_state <= ST_SUCCESS;
                else
                    next_state <= ST_FAIL;
                end if;
            
            when ST_WAIT_REL_4 => -- N'est pas utilisé dans cette logique, mais bon à garder
                 if bouton_presse = '0' then
                    next_state <= ST_SUCCESS;
                end if;

            -------------------- RÉSULTATS ET CHANGEMENT --------------------
            when ST_FAIL =>
                if bouton_presse = '0' then -- Attendre que l'utilisateur relâche tout
                    next_state <= ST_IDLE;
                end if;

            when ST_SUCCESS =>
                next_state <= ST_OPEN;
            
            when ST_OPEN =>
                if modif_code = '1' then -- Si on active le switch de modification
                    next_state <= ST_GOTO_CHANGE;
                elsif porte = '0' then -- Si on "ferme" la porte
                    next_state <= ST_IDLE;
                end if;

            -------------------- SÉQUENCE DE CHANGEMENT DE CODE --------------------
            when ST_GOTO_CHANGE =>
                if modif_code = '0' then -- Sécurité pour éviter un passage accidentel
                    next_state <= ST_OPEN;
                else
                    next_state <= ST_CHANGE_MODE;
                end if;
                
            when ST_CHANGE_MODE =>
                 if modif_code = '0' then -- Si on quitte le mode changement
                     next_state <= ST_IDLE;
                 elsif bouton_presse = '1' then
                     next_state <= ST_WRITE_1;
                 end if;

            when ST_WRITE_1 =>
                wen <= '1';
                next_state <= ST_WAIT_WRITE_REL_1;

            when ST_WAIT_WRITE_REL_1 =>
                if bouton_presse = '0' then
                    next_state <= ST_WRITE_2;
                end if;

            when ST_WRITE_2 =>
                if bouton_presse = '1' then
                    wen <= '1';
                    next_state <= ST_WAIT_WRITE_REL_2;
                end if;
            
            when ST_WAIT_WRITE_REL_2 =>
                if bouton_presse = '0' then
                    next_state <= ST_WRITE_3;
                end if;

            when ST_WRITE_3 =>
                if bouton_presse = '1' then
                    wen <= '1';
                    next_state <= ST_WAIT_WRITE_REL_3;
                end if;

            when ST_WAIT_WRITE_REL_3 =>
                if bouton_presse = '0' then
                    next_state <= ST_WRITE_4;
                end if;

            when ST_WRITE_4 =>
                if bouton_presse = '1' then
                    wen <= '1';
                    next_state <= ST_WAIT_WRITE_REL_4;
                end if;
            
            when ST_WAIT_WRITE_REL_4 =>
                if bouton_presse = '0' then -- Fin du changement
                    next_state <= ST_IDLE; 
                end if;

            -------------------- DEFAULT --------------------
            when others =>
                next_state <= ST_IDLE;
        end case;      
    end process;
    
    -- Détecte si un bouton est actuellement pressé
    bouton_presse <= '0' when contenu_bouton = "0000" else '1';

end Behavioral;