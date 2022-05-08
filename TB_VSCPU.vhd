library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_pkg.all;

entity TB_VSCPU is
	generic( addr_width : natural := 16;
				data_width : natural := 16
			);
end entity TB_VSCPU;

architecture arch of TB_VSCPU is
	signal clk,reset,start,write_flag : std_logic := '0';
	signal addr : std_logic_vector(addr_width-1 downto 0);
	signal data : std_logic_vector(data_width-1 downto 0);
	
	procedure next_input 
		(signal clk: in std_logic;
		signal write_flag: out std_logic;
		signal addr_out,data_out : out std_logic_vector;
		data_in: in std_logic_vector;
		i : inout integer) is
	begin
		wait until (clk='1');
		write_flag <= '1';
		addr_out <= int2slv(i,addr_out'length);
		data_out <= data_in;
		wait until (clk='0');
		write_flag <= '0';
		i := i + 1;
	end procedure;
	
begin
	dut : entity work.VSCPU(arch) 
		generic map (addr_width => addr_width, data_width => data_width)
		port map(clk,reset,start,write_flag,addr,data);
	
	process
	variable data_to_write : std_logic_vector(data_width-1 downto 0);
	variable i : integer := 0;
	
	begin
	wait until clk='0';
	reset <= '1';
	wait until clk='1';
	reset <= '0';

--	addi to initialize few registers
	data_to_write := "0000"&"010"&"000"&"000101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"000"&"001"&"001101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"001"&"100"&"001011";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"000"&"011"&"101101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"011"&"010"&"000111";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	data_to_write := "0000"&"100"&"101"&"111101";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	-- store all
	data_to_write := "1111"&"000"&"000000000";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	-- store one reg to memory
	data_to_write := "0101"&"000"&"111"&"000000";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	-- load multiple
	data_to_write := "1100"&"000"&"001111111";
	next_input(clk,write_flag,addr,data,data_to_write,i);
	
	start <= '1';
	wait until clk='1';
	start <= '0';
	wait;
	end process;
	
	process
	begin
		for i in 1 to 500 loop
			clk <= not clk;
			wait for 1ns;
		end loop;
		wait;
	end process;
	
end architecture arch;
