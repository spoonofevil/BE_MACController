----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.03.2023 14:05:10
-- Design Name: 
-- Module Name: controlleur - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controlleur is
    Port ( RBYTEP : out STD_LOGIC;
           RCLEANP : out STD_LOGIC;
           RDATAO : out STD_LOGIC_VECTOR (7 downto 0);
           RCVNGP : out STD_LOGIC;
           RDATAI : in STD_LOGIC_VECTOR (7 downto 0);
           RDONEP : out STD_LOGIC;
           RENABP : in STD_LOGIC;
           RSMATIP : out STD_LOGIC;
           RSTARTD : out STD_LOGIC;
           CLK : in STD_LOGIC;
           RESETN : in STD_LOGIC);
end controlleur;

architecture Behavioral of controlleur is
Signal countCLK : integer := 0;
Signal countFrame : integer := 0;
Signal receiving : boolean:= false;
Signal filterPassed : boolean:= false;
Signal MACaddrSelf: STD_LOGIC_VECTOR (47 downto 0):=x"aabbccddeeff";
Signal MACaddrBroadcast: STD_LOGIC_VECTOR (47 downto 0):=x"ffffffffffff";
Signal MACaddrOther: STD_LOGIC_VECTOR (47 downto 0);
begin

reception : process 
begin
wait until CLK'event and CLK ='1';
--donnée arrivée dans DATAI
if countCLK=8 then
    countCLK<=0;
    if RENABP='1' then
        if RDATAI=b"10101011" then --sequence debut ou fin
            if receiving then --fin de trame en reception
                if countFrame>64 and filterPassed then
                    RDONEP<='1';
                else
                    RCLEANP<='1';
                end if;
                RCVNGP<='0';
                receiving<=false;
            else--debut de reception
                RSTARTD<='1';
                --RDATAO<=RDATAI;
                RCVNGP<='1';
                filterPassed<=true;
                receiving<=true;
                filterPassed<=false;
                countFrame<=0;
            end if;
        else
            if receiving then
                    if countFrame<48 then
                        MACaddrOther(countFrame + 7 downto countFrame)<=RDATAI;
                        --filter
                        if MACaddrOther=MACaddrSelf then
                            filterPassed<=filterPassed and true;
                        else
                            filterPassed<=false;
                        end if;
                    else
                        RDATAO<=RDATAI;
                        RBYTEP<='1';
                    end if;
                    countFrame<=countFrame+8;
             end if;
        end if;
        
        
    end if;
else
    countCLK<=countCLK+1;
end if;
RBYTEP<='0';
RSTARTD<='0';
RDONEP<='0';
RCLEANP<='1';

end process reception;

end Behavioral;
