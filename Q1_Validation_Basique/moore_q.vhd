library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Machine à états finis (Moore) simplifiée pour la validation du code.
-- Cette version n'inclut pas la logique de changement de code et utilise 9 états.
entity moore_q is
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        -- Entrées
        contenu_bouton  : in  STD_LOGIC_VECTOR (3 downto 0);
        contenu_mem     : in  STD_LOGIC_VECTOR (3 downto 0);
        porte           : in  STD_LOGIC; -- 0 = porte fermée, 1 = porte ouverte
        -- Sorties
        adresse_machine : out STD_LOGIC_VECTOR (1 downto 0);
        ouverture_porte : out STD_LOGIC
    );
end moore_q;

architecture Behavioral of moore_q is

    -- Définition des 9 états de la machine
    type state_type is (
        ST_IDLE_1,      -- Attente du 1er chiffre
        ST_WAIT_REL_1,  -- Attente du relâchement du 1er bouton
        ST_IDLE_2,      -- Attente du 2ème chiffre
        ST_WAIT_REL_2,  -- Attente du relâchement du 2ème bouton
        ST_IDLE_3,      -- Attente du 3ème chiffre
        ST_WAIT_REL_3,  -- Attente du relâchement du 3ème bouton
        ST_IDLE_4,      -- Attente du 4ème chiffre
        ST_SUCCESS,     -- Code correct, porte ouverte
        ST_FAIL         -- Code incorrect
    );
    signal state, next_state : state_type := ST_IDLE_1;

    -- Signal pour détecter si un bouton est pressé
    signal bouton_presse : std_logic;

begin

    -- Processus synchrone pour la mise à jour de l'état
    SYNC_PROC: process (clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                state <= ST_IDLE_1;
            else
                state <= next_state;
            end if;        
        end if;
    end process;

    -- Logique de sortie (style Moore) : les sorties ne dépendent que de l'état actuel
    OUTPUT_DECODE: process (state)
    begin
        -- Initialisation des sorties par défaut
        ouverture_porte <= '0';
        adresse_machine <= "00";

        case state is
            when ST_IDLE_1 | ST_WAIT_REL_1 =>
                adresse_machine <= "00";
            when ST_IDLE_2 | ST_WAIT_REL_2 =>
                adresse_machine <= "01";
            when ST_IDLE_3 | ST_WAIT_REL_3 =>
                adresse_machine <= "10";
            when ST_IDLE_4 =>
                adresse_machine <= "11";
            when ST_SUCCESS =>
                ouverture_porte <= '1';
            when others => -- ST_FAIL
                null;
        end case;
    end process;

    -- Logique de transition d'états (combinatoire)
    NEXT_STATE_DECODE: process (state, contenu_bouton, contenu_mem, porte, bouton_presse)
    begin
        -- Par défaut, rester dans le même état pour éviter les latches
        next_state <= state;

        case state is
            -- Attente du 1er chiffre
            when ST_IDLE_1 =>
                if bouton_presse = '1' then
                    if contenu_bouton = contenu_mem then
                        next_state <= ST_WAIT_REL_1;
                    else
                        next_state <= ST_FAIL;
                    end if;
                end if;
            
            -- Attente du relâchement du 1er bouton
            when ST_WAIT_REL_1 =>
                if bouton_presse = '0' then
                    next_state <= ST_IDLE_2;
                end if;

            -- Attente du 2ème chiffre
            when ST_IDLE_2 =>
                if bouton_presse = '1' then
                    if contenu_bouton = contenu_mem then
                        next_state <= ST_WAIT_REL_2;
                    else
                        next_state <= ST_FAIL;
                    end if;
                end if;

            -- Attente du relâchement du 2ème bouton
            when ST_WAIT_REL_2 =>
                if bouton_presse = '0' then
                    next_state <= ST_IDLE_3;
                end if;
            
            -- Attente du 3ème chiffre
            when ST_IDLE_3 =>
                if bouton_presse = '1' then
                    if contenu_bouton = contenu_mem then
                        next_state <= ST_WAIT_REL_3;
                    else
                        next_state <= ST_FAIL;
                    end if;
                end if;

            -- Attente du relâchement du 3ème bouton
            when ST_WAIT_REL_3 =>
                if bouton_presse = '0' then
                    next_state <= ST_IDLE_4;
                end if;

            -- Attente du 4ème chiffre
            when ST_IDLE_4 =>
                if bouton_presse = '1' then
                    if contenu_bouton = contenu_mem then
                        next_state <= ST_SUCCESS;
                    else
                        next_state <= ST_FAIL;
                    end if;
                end if;

            -- État de succès : la porte est ouverte
            when ST_SUCCESS =>
                -- Si on ferme la porte (le switch 'porte' passe à 0), on retourne à l'état initial
                if porte = '0' then
                    next_state <= ST_IDLE_1;
                end if;

            -- État d'erreur
            when ST_FAIL =>
                -- Attendre que l'utilisateur relâche tous les boutons pour retourner à l'état initial
                if bouton_presse = '0' then
                    next_state <= ST_IDLE_1;
                end if;
                
            when others =>
                next_state <= ST_IDLE_1;

        end case;      
    end process;
    
    -- Détecte si un bouton est actuellement pressé (toute valeur différente de "0000")
    bouton_presse <= '0' when contenu_bouton = "0000" else '1';

end Behavioral;
