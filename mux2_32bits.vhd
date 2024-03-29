library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux2_32bits is
Port(
   DIn0 : in  STD_LOGIC_VECTOR (31 downto 0);
   DIn1 : in  STD_LOGIC_VECTOR (31 downto 0);
   ctrl : in  STD_LOGIC;
   Dout : out  STD_LOGIC_VECTOR (31 downto 0)
);
end mux2_32bits;

architecture Behavioral of mux2_32bits is

begin

Dout <= DIn1 when (ctrl ='1') else DIn0;
end Behavioral;

