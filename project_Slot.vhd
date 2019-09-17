library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity project_Slot is
port(
	push_button : 			in signed(15 downto 0);
	Seven_Seg_abcdefgh : 	out signed(7 downto 0);
	Seven_Seg_sel : 		out signed(5 downto 0); 
	CLK					:	in	std_logic
	);
end entity;


architecture project_Slot_Module of project_Slot is

component Display port(
		BCD_IN_5 : 				in signed(3 downto 0);
		BCD_IN_4 : 				in signed(3 downto 0);
		BCD_IN_3 : 				in signed(3 downto 0);
		BCD_IN_2 : 				in signed(3 downto 0);
		BCD_IN_1 : 				in signed(3 downto 0);
		BCD_IN_0 : 				in signed(3 downto 0);
		SEGMENT_OUT_abcdefgh: out signed(7 downto 0);
		Seven_Seg_sel : 		out signed(5 downto 0);
		CLK_Display : in std_logic;
		Write_Enable: in std_logic
	);
 end component;	


component Binary_to_BCD  port (
    Binary_Num   : in  signed (7 downto 0);
	hundreds: out signed (3 downto 0);
    tens     : out signed (3 downto 0);
    ones     : out signed (3 downto 0);
	CLK 		: in std_logic
								);

end component;

component Button_Check port(
	Button_Hardware   : in signed(15 downto 0);
	CLK				:in std_logic;
	Restart_Soft	: out std_logic;
	STOP_5_Soft		: out std_logic;
	STOP_4_Soft		: out std_logic;
	STOP_3_Soft		: out std_logic
 );
end component;

--클락신호를 저장----------------------------------------------------------------------------------------------------------

	signal Counter 	: signed(31 downto 0):=X"00000000";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
	signal Period_20ms_ClK	: std_logic :='0';
	signal Period_10ms_ClK	: std_logic :='0';
	signal Period_5ms_ClK	: std_logic :='0';
	signal Period_2ms_ClK	: std_logic :='0';
	signal Button_CLK		:	std_logic := '0';
	
--Seven Segment 에 출력할 BCD값 저장 5MSB 0 LSD	
	signal SIG5_BCD : signed(3 downto 0) :="0000";
	signal SIG4_BCD : signed(3 downto 0) :="0000";
	signal SIG3_BCD : signed(3 downto 0) :="0000";
	signal SIG2_BCD : signed(3 downto 0) :="1001";
	signal SIG1_BCD : signed(3 downto 0) :="0000";
	signal SIG0_BCD : signed(3 downto 0) :="0000";
--Seven Segment 에 abcdefgh 의값
	signal Write_E : std_logic := '0';
	signal Write_Num : std_logic := '0';
	signal Write_Score : std_logic := '0';
	
--버튼관련 변수-------------------------------------------------------------------------------
	signal Restart_Bt 	: std_logic:= '0';
	signal STOP_5_Bt	: std_logic:= '0';
	signal STOP_4_Bt	: std_logic:= '0';
	signal STOP_3_Bt	: std_logic:= '0';
-----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------점수를 저장하는 공간
	signal Calculate_Score : std_logic := '0';
	signal Final_Val : signed(7 downto 0) := "00000000";
	signal Final_Val_1 : signed(7 downto 0) := "00000000";
	signal Decimal_10TH	:signed(3 downto 0) := "0000";
	signal Decimal_1TH	:signed(3 downto 0) := "0000";
	signal Decimal_100TH	:signed(3 downto 0) := "0000";
	
---------------------------------------------------------------------------------------------------------------

begin

---클락 설정------------------------------------------------------------------------
process(CLK)	--감지신호가 clock_50m 인 process문
	begin
	if rising_edge(CLK) then	   --clock_50m이 상승에지 일때
		Counter <= Counter + 1; --init_counter 하나씩 증가함.
	end if;
end process;
Button_CLK 		<= Counter(8);
Period_20ms_ClK <= Counter(23);
Period_10ms_ClK<= Counter(24);
Period_5ms_ClK<=Counter(8);
Period_2ms_ClK <= Counter(25);


--★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★숫자 계기판★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
process(CLK)
begin

if (rising_edge(Period_20ms_ClK) and (STOP_5_Bt = '0' ) and (Calculate_Score ='0'))then --맨앞 5번 자리는 20ms에 한번씩 증가
				
				if (SIG5_BCD = "1001"  or SIG5_BCD = "1010")  then SIG5_BCD <= "0000";
				else
				SIG5_BCD <= SIG5_BCD + 1;
				end if;

elsif (rising_edge(Period_20ms_ClK) and final_Val = "01011010" and (Calculate_Score ='1')) then
SIG5_BCD <= "1010";
end if;

end process;
Process(CLK)
begin		
if (rising_edge(Period_2ms_ClK) and (STOP_4_Bt = '0' ) and (Calculate_Score ='0')) then
			
				if ( SIG4_BCD = "1001" or SIG4_BCD ="1011")  then SIG4_BCD <= "0000";
				else
				SIG4_BCD <= SIG4_BCD + 1;
				end if;
elsif (rising_edge(Period_2ms_ClK) and final_Val = "01011010" and (Calculate_Score ='1')) then
SIG4_BCD <= "1011";
end if;

end process;

Process(CLK)
begin			
if (rising_edge(Period_10ms_ClK) and (STOP_3_Bt = '0' ) and (Calculate_Score ='0')) then
			
				if (SIG3_BCD = "1001" or SIG3_BCD= "1100")  then SIG3_BCD <= "0000";
				else
				SIG3_BCD <= SIG3_BCD + 1;
				end if;
elsif (rising_edge(Period_10ms_ClK) and final_Val = "01011010" and (Calculate_Score ='1')) then
SIG3_BCD <= "1100";
end if;
end process;



------------------------------------------점수 계산 파트--------------------------
process(CLK,STOP_5_Bt,STOP_4_Bt,STOP_3_Bt)
begin
--if rising_edge(CLK) then
	if ((STOP_5_Bt = '1' ) and (STOP_4_Bt ='1' ) and (STOP_3_Bt = '1') and Calculate_Score = '0') then --세버튼 모두 정지상태가 되었을 때
			Calculate_Score <= '1'; --점수 계산 시작		
------------------------------------------예외 케이스-----------------------------------------------------------------------			
			if(SIG5_BCD = SIG4_BCD and SIG4_BCD =SIG3_BCD) then
		
		if(SIG5_BCD = "0000" and SIG4_BCD = "0000" AND SIG3_BCD = "0000") then    
            Final_Val <= "00001010";  --이때 점수는 10점!
      end if;   	
		if(SIG5_BCD = "0001" and SIG4_BCD = "0001" AND SIG3_BCD = "0001") then    
            Final_Val <= "00001010";  --이때 점수는 10점!
      end if;      
     if(SIG5_BCD = "0010" and SIG4_BCD = "0010" AND SIG3_BCD = "0010") then    
            Final_Val <= "00001010";  --이때 점수는 10점!
      end if;      
     if(SIG5_BCD = "0011" and SIG4_BCD = "0011" AND SIG3_BCD = "0011") then    
            Final_Val <= "00001010";  --이때 점수는 10점!
      end if;      
     if(SIG5_BCD = "0100" and SIG4_BCD = "0100" AND SIG3_BCD = "0100") then    
            Final_Val <= "00010100";  --이때 점수는 20점!
      end if;      
     if(SIG5_BCD = "0101" and SIG4_BCD = "0101" AND SIG3_BCD = "0101") then    
            Final_Val <= "00010100";  --이때 점수는 20점!
      end if;      
     if(SIG5_BCD = "0110" and SIG4_BCD = "0110" AND SIG3_BCD = "0110") then    
            Final_Val <= "00010100";  --이때 점수는 20점!
      end if;      
     if(SIG5_BCD = "0111" and SIG4_BCD = "0111" AND SIG3_BCD = "0111") then    
            Final_Val <= "01011010";  --이때 점수는 90점!
      end if;      
     if(SIG5_BCD = "1000" and SIG4_BCD = "1000" AND SIG3_BCD = "1000") then    
            Final_Val <= "00101000";  --이때 점수는 30점!
      end if;
     if(SIG5_BCD = "1001" and SIG4_BCD = "1001" AND SIG3_BCD = "1001") then    
            Final_Val <= "00101000"; --이때 점수는 30점!
      end if;    
		
	else
			Final_Val <= ("0000" & SIG5_BCD) +("0000" & SIG4_BCD) +("0000" & SIG3_BCD);
	end if;
	elsif ((STOP_5_Bt = '0' ) and (STOP_4_Bt ='0' ) and (STOP_3_Bt = '0')) then
		Calculate_Score <= '0'; --점수 계산 종료
	end if;
--end if;
end process;


process(CLK)
begin
if rising_edge(CLK) then
	if(Calculate_Score = '1') then --게임이 끝나면 점수계산
	
	if(final_Val = "01011010") then
				SIG2_BCD<= "1101";
				SIG1_BCD<= "1110";
				SIG0_BCD<= "1111";
	else
	SIG1_BCD <= Decimal_10TH;
	SIG0_BCD <= Decimal_1TH;
	
	end if;
	else
	SIG1_BCD <= "0000";
	SIG0_BCD <= "0000";
	SIG2_BCD <= "1111"; 
	end if;
end if;
end process;

---------------------------------------점수 계산 파트---------------------------


------★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★점수 계기판★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★


----------------------------------------------------------------------------------------


-- 3번째 화면은 게임공간과 점수공간을 나누어야 하기 때문에 항상 하면을 끈다--------------------------------------------------------------------------------------------------
 
-----------------------------------------------------------------------------------------------------------------------------------------------------------
Write_E <= (Write_Num or Write_Score); 
-------------------------------------버튼상태를 확인해주는 인터페이스-----------------------------------------------------------------------------------------------
Button_Checker : Button_Check port map(push_button,CLK,Restart_Bt,STOP_5_Bt,STOP_4_Bt,STOP_3_Bt);
-------------------------------------점수계기판의 십진수를 BCD코드로 변환 -------------------------------------------------------------------------------------------
Binary_to_BCD_Changer: Binary_to_BCD port map(Final_Val,Decimal_100TH,Decimal_10TH,Decimal_1TH,CLK);
-----------------------------------항시 출력을 담당하는 인터페이스---------------------------------------------------------------------------
Display_PART: Display port map(SIG5_BCD,SIG4_BCD,SIG3_BCD,SIG2_BCD,SIG1_BCD,SIG0_BCD,Seven_Seg_abcdefgh,Seven_Seg_sel,Period_5ms_ClK,'1');
end architecture;

------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;





entity BCD_to_segment is
port(
		BCD_IN : in signed(3 downto 0);
		SEGMENT_OUT_abcdefgh: out signed(7 downto 0);
		CLK_BCD : in std_logic
	);
end entity;

architecture BCD_to_segment_Module of BCD_to_segment is
begin
	
	process(CLK_BCD)
	--process is
	begin

	if(BCD_IN = "0000") then --0을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "00111111";
	elsif(BCD_IN = "0001") then--1을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "00000110";
	elsif(BCD_IN = "0010") then--2을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01011011";
	elsif(BCD_IN = "0011") then--3을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01001111";
	elsif(BCD_IN = "0100") then--4을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01100110";
	elsif(BCD_IN = "0101") then--5을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01101101";
	elsif(BCD_IN = "0110") then--6을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01111101";
	elsif(BCD_IN = "0111") then--7을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "00000111";
	elsif(BCD_IN = "1000") then--8을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01111111";
	elsif(BCD_IN = "1001") then--9을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01100111";
	elsif(BCD_IN = "1010") then--ㄷ을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "00111001";
	elsif(BCD_IN = "1011") then--H을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01110110";
	elsif(BCD_IN = "1100") then--ㅂ 을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01111110";
	elsif(BCD_IN = "1101") then--ㅏ 을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01110000";
	elsif(BCD_IN = "1110") then--14/T을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "01000100";
	elsif(BCD_IN = "1111") then--15/NULL을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "00000000";
 	else				--그 이외을 Segment 형식으로 변환
		SEGMENT_OUT_abcdefgh <= "00000000";
	end if;
	--wait for 1 ns;
	
	end process;
	
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;



entity Display is port
(
		BCD_IN_5 : 				in signed(3 downto 0);
		BCD_IN_4 : 				in signed(3 downto 0);
		BCD_IN_3 : 				in signed(3 downto 0);
		BCD_IN_2 : 				in signed(3 downto 0);
		BCD_IN_1 : 				in signed(3 downto 0);
		BCD_IN_0 : 				in signed(3 downto 0);
		SEGMENT_OUT_abcdefgh: out signed(7 downto 0);
		Seven_Seg_sel : 		out signed(5 downto 0);
		CLK_Display : in std_logic;
		Write_Enable : in std_logic
	);
end entity;

architecture Display_Module of Display is



component BCD_to_segment  port ( BCD_IN: in signed(3 downto 0);  
								SEGMENT_OUT_abcdefgh : out signed(7 downto 0);
								CLK_BCD : in std_logic
								);

 end component;	
-----------------------------------------------------------------------------------------------------------------------------
	signal SEGMENT_OUT_abcdefgh_5 : signed(7 downto 0) :="00000000";
	signal SEGMENT_OUT_abcdefgh_4 : signed(7 downto 0) :="00000000";
	signal SEGMENT_OUT_abcdefgh_3 : signed(7 downto 0) :="00000000";
	signal SEGMENT_OUT_abcdefgh_2 : signed(7 downto 0) :="00000000";
	signal SEGMENT_OUT_abcdefgh_1 : signed(7 downto 0) :="00000000";
	signal SEGMENT_OUT_abcdefgh_0 : signed(7 downto 0) :="00000000";
--------------------------------------------------------------------------------
	signal Currently_Displaying	: integer := 6;
	
--이 값이 6이면, 출력포인터의 위치가 어디에도 없다. 5면 SEGMENT_OUT_의 5 4면 4 0이면 0이다.	
 --------------------------------------------------------------------------------
 
 begin
-----------------------------------------------------------------------------------------------------------------------------
--순차 출력 알고리즘------------------------------------------------------------------------------------------------------------
Process(CLK_Display)
begin

if(rising_edge (CLK_Display)) then
if(Write_Enable = '1') then

if (Currently_Displaying = 6 ) then
Seven_Seg_sel <="111111";		
Currently_Displaying <= 5;
elsif (Currently_Displaying = 5) then
Seven_Seg_sel <= "011111";
SEGMENT_OUT_abcdefgh<=SEGMENT_OUT_abcdefgh_5;
Currently_Displaying <= 4;
elsif (Currently_Displaying = 4) then
Seven_Seg_sel <= "101111";
SEGMENT_OUT_abcdefgh<=SEGMENT_OUT_abcdefgh_4;
Currently_Displaying <= 3;
elsif (Currently_Displaying = 3) then
Seven_Seg_sel <= "110111";
SEGMENT_OUT_abcdefgh<=SEGMENT_OUT_abcdefgh_3;
Currently_Displaying <= 2;
elsif (Currently_Displaying = 2) then
Seven_Seg_sel <= "111011";
SEGMENT_OUT_abcdefgh<=SEGMENT_OUT_abcdefgh_2;
Currently_Displaying <= 1;
elsif (Currently_Displaying = 1) then
Seven_Seg_sel <= "111101";
SEGMENT_OUT_abcdefgh<=SEGMENT_OUT_abcdefgh_1;
Currently_Displaying <= 0;
elsif (Currently_Displaying = 0) then
Seven_Seg_sel <= "111110";
SEGMENT_OUT_abcdefgh<=SEGMENT_OUT_abcdefgh_0;
Currently_Displaying <= 6;
else
Seven_Seg_sel <="111111";
Currently_Displaying <= 6;
end if;

else
Seven_Seg_sel <="111111";
end if;

end if;
end process;
 
---항상 bcd의 값을 Seven Segment 의 값으로 변환
B5 : BCD_to_segment port map(BCD_IN_5,SEGMENT_OUT_abcdefgh_5,CLK_Display);
B4 : BCD_to_segment port map(BCD_IN_4,SEGMENT_OUT_abcdefgh_4,CLK_Display);
B3 : BCD_to_segment port map(BCD_IN_3,SEGMENT_OUT_abcdefgh_3,CLK_Display);
B2 : BCD_to_segment port map(BCD_IN_2,SEGMENT_OUT_abcdefgh_2,CLK_Display);
B1 : BCD_to_segment port map(BCD_IN_1,SEGMENT_OUT_abcdefgh_1,CLK_Display);
B0 : BCD_to_segment port map(BCD_IN_0,SEGMENT_OUT_abcdefgh_0,CLK_Display); 

end architecture;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity Binary_to_BCD is
   Port ( 
      Binary_Num   : in  signed (7 downto 0);
    hundreds : out signed (3 downto 0);
      tens     : out signed (3 downto 0);
      ones     : out signed (3 downto 0);
	  CLK		: in std_logic 
   );
end entity;
 
architecture Binary_to_BCD_Module of Binary_to_BCD is
begin
process (CLK,Binary_Num)
 variable SHIFTED : signed(19 downto 0);
 
 alias num is SHIFTED(7 downto 0);
 alias one is SHIFTED(11 downto 8);
 alias ten is SHIFTED(15 downto 12);
 alias hun is SHIFTED(19 downto 16);
 
begin
num := Binary_Num;
one := X"0";
ten := X"0";
hun := X"0";
for i in 1 to num'Length loop
    if one >= 5 then
       one := one + 3;
     end if;
         
    if ten >= 5 then
       ten := ten + 3;
    end if;
         
    if hun >= 5 then
       hun := hun + 3;
    end if;
       SHIFTED := shift_left(SHIFTED, 1);
		 -- SHift 기능을 이용하여 한 비트식 살펴본다.
      end loop;
 hundreds <= signed(hun);
 tens     <= signed(ten);
 ones     <= signed(one);
	  
   end process;
 
end architecture;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 

------------------------------------실제 버튼이 하드웨어적으로 눌렸을때 노이즈와 모든 효과를 고려하여, 회로의 논리적으로 맞게 변환하여 출력해준다.
 entity Button_Check is
 port
 (
	Button_Hardware   : in  signed(15 downto 0);
	CLK				:	in 	std_logic;
	Restart_Soft	: out std_logic;
	STOP_5_Soft		: out std_logic;
	STOP_4_Soft		: out std_logic;
	STOP_3_Soft		: out std_logic
 );
 end entity;
 

 architecture Button_Check_Module of Button_Check is
 signal Past_Button_Hardware	: signed(15 downto 0) :=X"0000";
 signal Restart_Bt_s				:std_logic :='0';
 signal	STOP_5_Soft_s				:std_logic :='0';
 signal STOP_4_Soft_s				:std_logic :='0';
 signal	STOP_3_Soft_s				:std_logic :='0';
 
 begin
 process(CLK)
 begin
 if rising_edge(CLK) then
 		Past_Button_Hardware <= (not Button_Hardware);
----마스터 리셋이 들어오기 전까지는 S5,S4,S3는 항상 같은 상태를 유지한다. 		
		if (Past_Button_Hardware = (not Button_Hardware)) then
				
				Restart_Bt_s <= (Past_Button_Hardware(3));
								
								
			if(Restart_Bt_s = '1')		then
					--reset;
				Restart_Bt_s <= '0';
				STOP_5_Soft_S <= '0';
				STOP_4_Soft_s <= '0';
				STOP_3_Soft_s <= '0';
								
			else					
				if(Past_Button_Hardware(2) /= '0') then
				STOP_3_Soft_s <=(Past_Button_Hardware(2));
				end if;
			
				if(Past_Button_Hardware(1) /= '0') then
				STOP_4_Soft_s <=(Past_Button_Hardware(1));
				end if;
				if(Past_Button_Hardware(0) /= '0') then
				STOP_5_Soft_s <= (Past_Button_Hardware(0));
				end if;
			
			end if;
		--버튼 구문
		else
		--잡음 이 들어왔을때
		--nothing!
		end if;
 end if;
 
 Restart_Soft <= Restart_Bt_s;
 STOP_5_Soft <= STOP_5_Soft_s;
 STOP_4_Soft <= STOP_4_Soft_s;
 STOP_3_Soft <= STOP_3_Soft_s;
 
 
 end process;
 end architecture;


