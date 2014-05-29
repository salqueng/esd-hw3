library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Logic_out1 is
port (
		High	: out std_logic;
		Low		: out std_logic;
		Z		: out std_logic	
);
end Logic_out1;

architecture a of Logic_out1 is

begin

	High	<= '1';
	Low		<= '0';
	Z		<= 'Z';

end a;
		