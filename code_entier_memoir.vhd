library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoire is
    Port (			sortie_memoire : out  STD_LOGIC_VECTOR (3 downto 0);
				reset, clk : in  STD_LOGIC;	
				adresse : in  STD_LOGIC_VECTOR (1 downto 0));
end memoire;

architecture Behavioral of memoire is
type tcode is array (0 to 3) of std_logic_vector (3 downto 0);
signal code : tcode;
 
begin

process (reset, clk)
begin
	if reset ='1' then
		code(0) <= "0001";
		code(1) <= "0010";
		code(2) <= "0100";
		code(3) <= "1000";

	end if;		
end process; 

			sortie_memoire <= code(to_integer(unsigned(adresse)));
			
end Behavioral;