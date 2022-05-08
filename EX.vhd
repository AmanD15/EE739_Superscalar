library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

package EX_stage is
component Execute is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		stall_out : out std_logic;
		pc : in std_logic_vector(15 downto 0);
		op_code : in std_logic_vector(3 downto 0);
		cz : in std_logic_vector(1 downto 0);
		wb_in : in std_logic_vector(2 downto 0);
		data_in : in std_logic_vector(127 downto 0);
		mem_address : in std_logic_vector(15 downto 0);
		reg_bits : in std_logic_vector(7 downto 0);
		mem_bits : in std_logic_vector(7 downto 0);
		reg_bits_out : out std_logic_vector(7 downto 0);
		mem_bits_out : out std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(127 downto 0);
		wb_out : out std_logic_vector(2 downto 0);
		wb_enable : out std_logic;
		pc_next : out std_logic_vector(15 downto 0);
		mem_add_out : out std_logic_vector(15 downto 0);
		mem_sr : in std_logic;
		mem_sr_out : out std_logic
		);
end component Execute;
end package EX_stage;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Execute is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		clk : in std_logic;
		stall_out : out std_logic;
		pc : in std_logic_vector(15 downto 0);
		op_code : in std_logic_vector(3 downto 0);
		cz : in std_logic_vector(1 downto 0);
		wb_in : in std_logic_vector(2 downto 0);
		data_in : in std_logic_vector(127 downto 0);
		mem_address : in std_logic_vector(15 downto 0);
		reg_bits : in std_logic_vector(7 downto 0);
		mem_bits : in std_logic_vector(7 downto 0);
		reg_bits_out : out std_logic_vector(7 downto 0);
		mem_bits_out : out std_logic_vector(7 downto 0);
		data_out : out std_logic_vector(127 downto 0);
		wb_out : out std_logic_vector(2 downto 0);
		wb_enable : out std_logic;
		pc_next : out std_logic_vector(15 downto 0);
		mem_add_out : out std_logic_vector(15 downto 0);
		mem_sr : in std_logic;
		mem_sr_out : out std_logic
		);
end entity Execute;

architecture Exec of Execute is
signal c_flag : std_logic := '0';
signal z_flag : std_logic := '0';
begin
	process(clk)
	
	variable data_a, data_b, data_c : std_logic_vector(15 downto 0);
	variable data_out_var : std_logic_vector(127 downto 0);
	variable data_add : std_logic_vector(16 downto 0);
	variable data_add2 : std_logic_vector(15 downto 0);
	variable data_nand : std_logic_vector(15 downto 0);
	variable c_flag_var : std_logic;
	variable z_flag_var : std_logic;
	variable z_var1 : std_logic;
	variable z_var2 : std_logic;
	variable pc_var : std_logic_vector(15 downto 0);
	variable wb_en : std_logic;

	begin
		if (rising_edge(clk)) then
			if (stall = '0') then
				c_flag_var := c_flag;
				z_flag_var := z_flag;
				wb_en := '0';
				data_a := data_in(15 downto 0);
				data_b := data_in(31 downto 16);
				data_c := data_in(47 downto 32);
				pc_var := std_logic_vector(unsigned(pc) + to_unsigned(1,16));
				data_out_var := data_in;
				data_add := std_logic_vector(unsigned('0'&data_a)+unsigned('0'&data_b));
				data_add2 := std_logic_vector(unsigned(pc)+unsigned(data_c));
				data_nand := (data_a nand data_b);
				if (data_add = "0000000000000000") then z_var1 := '1'; else z_var1 := '0'; end if;
				if (data_nand = "000000000000000") then z_var2 := '1'; else z_var2 := '0'; end if;
								
				case op_code is
					-- add immediate
					when "0000" =>
						z_flag_var := z_var1;
						data_out_var(15 downto 0)  := data_add(15 downto 0);
						c_flag_var := data_add(16);
						wb_en := '1';
					
					-- add
					when "0001" => case cz is
						when "00" => 
							z_flag_var := z_var1;
							c_flag_var := data_add(16);
							data_out_var(15 downto 0)  := data_add(15 downto 0);
							wb_en := '1';
						when "01" => 
							if (z_flag='1') then 
								data_out_var(15 downto 0)  := data_add(15 downto 0);
								z_flag_var := z_var1;
								c_flag_var := data_add(16);
								wb_en := '1';
							end if;
						when "10" =>
							if (c_flag='1') then
								data_out_var(15 downto 0)  := data_add(15 downto 0);
								z_flag_var := z_var1;
								c_flag_var := data_add(16);
								wb_en := '1';
							end if;
						when "11" =>
							data_out_var(15 downto 0)  := data_add(15 downto 0);
							z_flag_var :=  z_var1;
							c_flag_var := data_add(16);
							wb_en := '1';
						when others => null;
					end case;
					
					-- nand
					when "0010" =>
						case cz is
							when "00" => data_out_var(15 downto 0)  := data_nand; z_flag_var := z_var2; wb_en := '1';
							when "01" =>
								if (z_flag='1') then data_out_var(15 downto 0)  := data_nand; z_flag_var := z_var2; wb_en := '1'; end if;
							when "10" =>
								if (c_flag='1') then data_out_var(15 downto 0)  := data_nand; z_flag_var := z_var2; wb_en := '1'; end if;
							when others => null;
						end case;
						
					--lhi
					when "0011" => data_out_var(15 downto 0)  := data_b; wb_en := '1';
					
					--lw , sw
					when "0100" | "0101" =>
						mem_add_out <= data_add(15 downto 0);
						data_out_var(15 downto 0) := data_c;
											
					-- sm, lm, la, sa
					when "1100" | "1101" | "1110" | "1111" => 
						mem_add_out <= mem_address;
						reg_bits_out <= reg_bits;
					
					--beq
					when "1000" =>
						if (data_b = data_a) then
							pc_var := data_add2;
						end if;
					
					-- jal
					when "1001" => data_out_var(15 downto 0)  := pc_var; pc_var := data_add2; wb_en := '1';
					
					-- jlr
					when "1010" => data_out_var(15 downto 0)  := pc_var; pc_var := data_b; wb_en := '1';
					
					--jri
					when "1011" =>	pc_var := data_add(15 downto 0);
					when others => null;
				end case;
				
				pc_next <= pc_var;
				wb_out <= wb_in;
				z_flag <= z_flag_var;
				c_flag <= c_flag_var;
				wb_enable <= wb_en;
				data_out <= data_out_var;
				mem_bits_out <= mem_bits;
				reg_bits_out <= reg_bits;
				mem_sr_out <= mem_sr;
			end if;
			stall_out <= stall;
		end if;
	end process;
end architecture Exec;