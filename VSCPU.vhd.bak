library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;
use work.IF_Stage.all;

entity VSCPU is
	generic( addr_width : natural := 16;
				data_width : natural := 16;
				pc_start : natural := 1
			);
	port( clk : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			write_flag : in std_logic;
			addr : in std_logic_vector(addr_width-1 downto 0);
			data : in std_logic_vector(data_width-1 downto 0)
			);
end entity VSCPU;

architecture arch of VSCPU is

signal stall : std_logic := '0';
signal address : std_logic_vector(addr_width-1 downto 0);
signal readWrite_I : std_logic;
signal inst_fetch : std_logic_vector(data_width-1 downto 0);
signal pc :std_logic_vector(addr_width-1 downto 0);
signal pc_out :std_logic_vector(addr_width-1 downto 0);

begin
Inst_Mem : memory port map (clk , address , data , readWrite_I , inst_fetch);
inst1 : Inst_Fetch port map (stall, clk, pc, pc_out);

end architecture arch;
