library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY CLK_div_gen1 IS
	PORT(
		CLK_50MHz	: IN  STD_LOGIC;
		CLK_1MHz	: OUT STD_LOGIC;
		CLK_1KHz	: OUT STD_LOGIC;
		CLK_3KHz	: OUT STD_LOGIC;
		
		nreset		: in std_logic
	);
END CLK_div_gen1;

ARCHITECTURE HB OF CLK_div_gen1 IS

	SIGNAL CNT_1MHz		: INTEGER RANGE 0 TO 24;
	SIGNAL BCLK_1MHz	: STD_LOGIC;

	SIGNAL CNT_1KHz		: INTEGER RANGE 0 TO 24999;
	SIGNAL BCLK_1KHz	: STD_LOGIC;

	SIGNAL CNT_3KHz		: INTEGER RANGE 0 TO 8333;
	SIGNAL BCLK_3KHz	: STD_LOGIC;
			
BEGIN


---------------------------------------------------------------
--  CLOCK 1MHz Generator					--
------------------------------------------------------------------	
PROCESS(CLK_50MHz,nRESET)
BEGIN
	IF nRESET = '0' THEN
		BCLK_1MHz <= '0';
		CNT_1MHz <= 0;
	ELSIF CLK_50MHz'EVENT AND CLK_50MHz = '1' THEN
		IF CNT_1MHz = 24 THEN
			CNT_1MHz <= 0;
			BCLK_1MHz <= NOT BCLK_1MHz;
		ELSE
			CNT_1MHz <= CNT_1MHz + 1;
		END IF;
	END IF;
END PROCESS;

CLK_1MHz <= BCLK_1MHz;

---------------------------------------------------------------
--  CLOCK 1KHz Generator					--
------------------------------------------------------------------
PROCESS(CLK_50MHz, nRESET)
BEGIN
	IF nRESET = '0' THEN
		BCLK_1KHz <= '0';
		CNT_1KHz <= 0;
	ELSIF CLK_50MHz'EVENT AND CLK_50MHz = '1' THEN
		IF CNT_1KHz = 24999 THEN
			CNT_1KHz <= 0;
			BCLK_1KHz <= NOT BCLK_1KHz;
		ELSE
			CNT_1KHz <= CNT_1KHz + 1;
		END IF;
	end if;
END PROCESS;

CLK_1KHz <= BCLK_1KHz;
---------------------------------------------------------------
--  CLOCK 3KHz Generator					--
------------------------------------------------------------------
PROCESS(CLK_50MHz, nRESET)
BEGIN
	IF nRESET = '0' THEN
		CNT_3KHz <= 0;
		BCLK_3KHz <= '0';
	ELSIF CLK_50MHz'EVENT AND CLK_50MHz = '1' THEN
		IF CNT_3KHz = 4167 THEN
			CNT_3KHz <= 0;
			BCLK_3KHz <= NOT BCLK_3KHz;
		ELSE
			CNT_3KHz <= CNT_3KHz + 1;
		END IF;
	END IF;
END PROCESS;

CLK_3KHz <= BCLK_3KHz;


END HB;