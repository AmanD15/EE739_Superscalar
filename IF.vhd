library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

package IF_Stage is

component Inst_Fetch is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		stall_out : out std_logic;
		clk : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		pc_out : out std_logic_vector(15 downto 0);
		control_hazard : in std_logic
		);
end component Inst_Fetch;

end package IF_Stage;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;

entity Inst_Fetch is
generic (inst_width : integer := 16);
port (stall : in std_logic;
		stall_out : out std_logic;
		clk : in std_logic;
		pc : in std_logic_vector(15 downto 0);
		pc_out : out std_logic_vector(15 downto 0);
		control_hazard : in std_logic
		);
end entity Inst_Fetch;

architecture Fetch of Inst_Fetch is
signal n_pc : std_logic_vector(15 downto 0);
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (stall='0') then
				if (control_hazard = '1') then
					pc_out <= pc;
					n_pc <= std_logic_vector(unsigned(pc)+1);
				else
					pc_out <= n_pc;
					n_pc <= std_logic_vector(unsigned(n_pc)+1);
				end if;
			end if;
			stall_out <= stall;
		end if;
	end process;
end architecture Fetch;