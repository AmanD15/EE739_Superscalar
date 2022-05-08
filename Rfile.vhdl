library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Reg_File_Access is
port (
		clk : in std_logic;
		src_in1 : in std_logic_vector(2 downto 0);
		src_in2 : in std_logic_vector(2 downto 0);
		src_in3 : in std_logic_vector(2 downto 0);
		src_in4 : in std_logic_vector(2 downto 0);
		src_enable : in std_logic_vector(3 downto 0);
		dst_in1 : in std_logic_vector(2 downto 0);
		dst_in2 : in std_logic_vector(2 downto 0);
		dst_enable : in std_logic_vector(1 downto 0);
		src_out1 : out std_logic_vector(15 downto 0);
		src_out2 : out std_logic_vector(15 downto 0);
		src_out3 : out std_logic_vector(15 downto 0);
		src_out4 : out std_logic_vector(15 downto 0);
		src_valid : out std_logic_vector(3 downto 0);
		);
end entity Reg_File_Access;

architecture RFA of Reg_File_Access is
type ARF_type is array(7 downto 0) of std_logic_vector(19 downto 0);
type RRF_type is array(7 downto 0) of std_logic_vector(19 downto 0);
signal ARF : ARF_type := (others => (others => '0'));
signal RRF : RRF_type := (others => (others => '0'));
begin
--	if (src_enable(3) = '1') src_out4
end architecture RFA;