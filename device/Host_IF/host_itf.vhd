library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity host_itf is
port (
		clk 		: in std_logic;
		nRESET		: in std_logic;
		FPGA_nRST	: in std_logic;
		HOST_nOE	: in std_logic;
		HOST_nWE	: in std_logic;
		HOST_nCS	: in std_logic;
		HOST_ADD	: in std_logic_vector(20 downto 0);
		HDI			: in std_logic_vector(15 downto 0);
		HDO			: out std_logic_vector(15 downto 0);
		
		--CLCD
		CLCD_RS 	: out std_logic;
		CLCD_RW		: out std_logic;
		CLCD_E		: out std_logic;
		CLCD_DQ		: out std_logic_vector(7 downto 0);
				
		--LED
		LED_D		: out std_logic_vector(7 downto 0);
		
		--6DIGIT 7-SGMENT
		SEG_COM		: out std_logic_vector(5 downto 0);
		SEG_Data	: out std_logic_vector(7 downto 0);

		--DOT MATRIX
		DOT_SCAN	: out std_logic_vector(9 downto 0);
		DOT_DATA	: out std_logic_vector(6 downto 0);

		-- Piezo
		Piezo		: out std_logic;
		
		--DIP Switch
		DIP_D		: in std_logic_vector(15 downto 0);

		--Keypad
		PUSH_RD		: in std_logic_vector(3 downto 0);
		PUSH_LD		: out std_logic_vector(3 downto 0);
						
		--Tack Switch		
		PUSH_SW		: in std_logic_vector(3 downto 0);
		
		clk_3k		: in std_logic;
		host_sel	: out std_logic;
		sw			: in std_logic

	
);
end host_itf;

architecture a of host_itf is

signal x8800_0010 : std_logic_vector(15 downto 0); --CLCD

signal x8800_0020 : std_logic_vector(15 downto 0); --LED

signal x8800_0030 : std_logic_vector(15 downto 0); --6 DIGIT 7-SEGMENT seg_com
signal x8800_0032 : std_logic_vector(15 downto 0); --6 DIGIT 7-SEGMENT seg_data

signal x8800_0040 : std_logic_vector(15 downto 0); --DOT MATRIX SCAN
signal x8800_0042 : std_logic_vector(15 downto 0); --DOT MATRIX data

signal x8800_0050 : std_logic_vector(15 downto 0); --Piezo

signal x8800_0062 : std_logic_vector(15 downto 0); --Dip Switch data

signal x8800_0070 : std_logic_vector(15 downto 0); --Keypad RD
signal x8800_0072 : std_logic_vector(15 downto 0); --Keypad LD

signal x8800_0080 : std_logic_vector(15 downto 0); --Tack Switch

signal x8800_0090 : std_logic_vector(15 downto 0); -- Host Mode
signal x8800_0092 : std_logic_vector(15 downto 0); -- FPGA use



signal x8800_00A0 : std_logic_vector(15 downto 0);
signal x8800_00B0 : std_logic_vector(15 downto 0);
signal x8800_00C0 : std_logic_vector(15 downto 0);
signal x8800_00D0 : std_logic_vector(15 downto 0);
signal x8800_00E0 : std_logic_vector(15 downto 0);

-- bus sel
signal x8800_00F0 : std_logic_vector(15 downto 0);
signal reg_sw : std_logic_vector(1 downto 0);
SIGNAL V_SEL  : STD_LOGIC;
signal clk_cnt : integer range 0 to 3;


	
begin 


--write		
	process(clk,nRESET)
	begin
		if nRESET = '0' then
			x8800_0010 <= (others => '0');--CLCD			
			x8800_0020 <= (others => '0');--LED
			
			x8800_0030 <= (others => '0');--6 DIGIT 7-SEGMENT com
			x8800_0032 <= (others => '0');--6 DIGIT 7-SEGMENT data 

			x8800_0040 <= (others => '0');--DOT MATRIX Scan
			x8800_0042 <= (others => '0');--DOT MATRIX data
			
			x8800_0050 <= (others => '0');--Piezo
						
			x8800_0072 <= (others => '0');--Keypad LD
			x8800_00A0 <= (others => '0');
			x8800_00B0 <= (others => '0');
			x8800_00C0 <= (others => '0');
			x8800_00D0 <= (others => '0');
			x8800_00E0 <= (others => '0');
			x8800_00F0 <= (others => '0');
		elsif clk'event and clk = '1' then
			if HOST_nCS = '0' and HOST_nWE = '0' then
				case HOST_ADD(19 downto 0) is
					when x"00010" => x8800_0010 <= HDI; --CLCD
					when x"00020" => x8800_0020 <= HDI; --LED
					when x"00030" => x8800_0030 <= HDI; --6 DIGIT 7-SEGMENT com
					when x"00032" => x8800_0032 <= HDI; --6 DIGIT 7-SEGMENT data
					when x"00040" => x8800_0040 <= HDI; --DOT MATRIX Scan
					when x"00042" => x8800_0042 <= HDI; --DOT MATRIX data
					when x"00050" => x8800_0050 <= HDI; --Piezo 
					when x"00072" => x8800_0072 <= HDI; --Keypad LD
					when x"000A0" => x8800_00A0 <= HDI;
					when x"000B0" => x8800_00B0 <= HDI;
					when x"000C0" => x8800_00C0 <= HDI;
					when x"000D0" => x8800_00D0 <= HDI;
					when x"000E0" => x8800_00E0 <= HDI;
					when x"000F0" => x8800_00F0 <= HDI; -- Host mode
					when others => null;
				end case;
			else
				if FPGA_nRST = '0' then					-- Host mode
					x8800_00F0 <= (others => '0');	-- Host mode
				elsif reg_sw = "10" then				-- Host mode
					x8800_00F0 <= not x8800_00F0;		-- Host mode
				end if;										-- Host mode
			end if;
		end if;
	end process;
--read	
	process(nreset,clk)
	begin
		if nreset = '0' then
			HDO <= (others => '0');
		elsif clk'event and clk = '1' then
			if HOST_nCS = '0' and HOST_nOE = '0' then
				case HOST_ADD(19 downto 0) is
					when x"00010" => HDO <= x8800_0010;  -- CLCD
					when x"00020" => HDO <= x8800_0020;  -- LED
					when x"00030" => HDO <= x8800_0030;  -- 6 DIGIT 7-SEGMENT com
					when x"00032" => HDO <= x8800_0032;  -- 6 DIGIT 7-SEGMENT data
					when x"00040" => HDO <= x8800_0040;  -- DOT MATRIX SCAN
					when x"00042" => HDO <= x8800_0042;  -- DOT MATRIX Data
					when x"00050" => HDO <= x8800_0050;  -- Buzzer
					when x"00062" => HDO <= x8800_0062;  -- DIP Switch data
					when x"00070" => HDO <= x8800_0070;  -- Keypad RD
					when x"00072" => HDO <= x8800_0072;  -- Keypad LD
					when x"00080" => HDO <= x8800_0080;  -- Tack Switch
					when x"00090" => HDO <= x8800_0090;	 
					when x"00092" => HDO <= x8800_0092;
					when x"000A0" => HDO <= x8800_00A0;
					when x"000B0" => HDO <= x8800_00B0;
					when x"000C0" => HDO <= x8800_00C0;
					when x"000D0" => HDO <= x8800_00D0;
					when x"000E0" => HDO <= x8800_00E0;
					when x"000F0" => HDO <= x8800_00F0;  -- Host Mode
					when others => null;
				end case;
			end if;
		end if;
	end process;

--CLCD
CLCD_RS		<= x8800_0010(10);
CLCD_RW		<= x8800_0010(9);
CLCD_E		<= x8800_0010(8);
CLCD_DQ		<= x8800_0010(7 downto 0);

--LED
LED_D		<= x8800_0020(7 downto 0);

--6 Digit 7-segment
SEG_COM		<= not x8800_0030(5 downto 0);
SEG_Data	<= x8800_0032(7 downto 0);

--Dot Matrix
DOT_SCAN	<= x8800_0040(9 downto 0);
DOT_DATA	<= x8800_0042(6 downto 0);

--Piezo
Piezo		<= '1' when x8800_0050(0) = '1' else '0';

-- Keypad
x8800_0070	<="00000000"&"0000"& PUSH_RD when nRESET = '1' else "0000000000000000";
PUSH_LD		<=x8800_0072(3 downto 0);

--dip_switch
x8800_0062 <= dip_d when nRESET = '1' else "0000000000000000";

-- Tack Switch
x8800_0080	<= "000000000000" & not PUSH_SW when nRESET = '1' else "0000000000000000";

-- fpga use
x8800_0092 <= "0000000000" & "101010" when nRESET = '1' else "0000000000000000";

--bus sel
host_sel <= x8800_00F0(0);

	PROCESS(nRESET,clk_3k)
	BEGIN
		IF nRESET = '0' THEN
			V_SEL <= '1';
			clk_cnt <= 0;
		ELSIF clk_3k='1' AND clk_3k'EVENT THEN
			if sw = '0' then
				if clk_cnt >= 3 then
					clk_cnt <= 3;
				else
					clk_cnt <= clk_cnt + 1;
				end if;
				
				if clk_cnt = 2 then
					V_SEL <= '0';
				else
					V_SEL <= '1';
				end if;
			else
				clk_cnt <= 0;
			end if;
		END IF;
	END PROCESS;

	process(clk,nRESET)
	begin
		if nRESET = '0' then
			reg_sw <= "00";
		elsif clk'event and clk = '1' then
			reg_sw <= reg_sw(0) & V_SEL;
		end if;
	end process;



end a;
		