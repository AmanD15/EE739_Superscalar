library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.my_pkg.all;
use work.IF_Stage.all;
use work.ID_Stage.all;
use work.RA_stage.all;
use work.EX_stage.all;
use work.MA_stage.all;

entity VSCPU is
	generic( addr_width : natural := 16;
				data_width : natural := 16
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

signal stall : std_logic := '1';
signal address : std_logic_vector(15 downto 0);
signal readWrite_I : std_logic := '0';
signal inst_f : std_logic_vector(15 downto 0);
signal pc : std_logic_vector(15 downto 0);
signal pc_fet, pc_dec_out, pc_ra, pc_alu: std_logic_vector(15 downto 0);
signal op_dec, op_ra : std_logic_vector(3 downto 0);
signal r_a_dec, r_b_dec, r_c_dec, r_co, wb_out_alu, wb_out_ma: std_logic_vector(2 downto 0);
signal cz_dec, cz_ra : std_logic_vector(1 downto 0);
signal wb_enable_alu, wb_enable_ma: std_logic;
signal imm_dec: std_logic_vector(8 downto 0);
signal reg_upd_ra, reg_upd_alu, reg_upd_ma, mem_upd_ra, mem_upd_alu: std_logic_vector(7 downto 0);
signal mem_add_in_alu, mem_add_out_alu : std_logic_vector(15 downto 0);
signal ma_data_out, data_ra, data_out_alu: std_logic_vector(127 downto 0);
signal ms_ra, ms_alu : std_logic;
signal control_hazard : std_logic;
signal alu_valid, alu_valid_n, alu_valid_nn, alu_valid_nnn : std_logic := '0';
signal stall_stage1_out, stall_stage2_out, stall_stage3_out, stall_stage4_out, stall_stage5_out : std_logic;
signal stall_stage2_in, stall_stage3_in, stall_stage4_in, stall_stage5_in, stall_stage6_in: std_logic;
signal stall_stage1, stall_stage2, stall_stage3, stall_stage4: std_logic;
begin

process(clk,reset)
begin
	if (reset = '1') then
		pc <= "0000000000000000";
		control_hazard <= '1';
		alu_valid <= '0';
		alu_valid_n <= '0';
		alu_valid_nn <= '0';
		alu_valid_nnn <= '0';
		stall <= '1';
	elsif (rising_edge(clk)) then
		if (start = '1') then stall <= '0'; end if;
		if (stall = '0') then
			pc <= pc_alu;
			if ((pc_alu = pc_ra) or (alu_valid = '0')) then control_hazard <= '0'; else control_hazard <= '1'; end if;
			alu_valid <= alu_valid_n;
			alu_valid_n <= alu_valid_nn;
			alu_valid_nn <= alu_valid_nnn;
			alu_valid_nnn <= '1';
		end if;
	end if;
end process;

address <= addr when (write_flag = '1') else pc_fet;
stall_stage2_in <= stall or control_hazard or stall_stage1_out;
stall_stage3_in <= stall or control_hazard or stall_stage2_out;
stall_stage4_in <= stall or control_hazard or stall_stage3_out;
stall_stage5_in <= stall or stall_stage4_out;
stall_stage6_in <= stall or stall_stage5_out;

Inst_Mem : memory port map (clk => clk, addr => address, data => data,
							readWrite => write_flag ,output => inst_f
							);

stage1 : Inst_Fetch port map (stall => stall,
							clk => clk,
							pc => pc,
							pc_out => pc_fet,
							control_hazard => control_hazard,
							stall_out => stall_stage1_out
							);

stage2 : Inst_Decode port map (stall => stall_stage2_in,
							pc => pc_fet,
							clk => clk,
							inst => inst_f, 
							op_code => op_dec,
							r_a => r_a_dec,
							r_b => r_b_dec,
							r_c => r_c_dec , 
							imm => imm_dec,
							cz => cz_dec,
							pc_out => pc_dec_out,
							stall_out => stall_stage2_out
							);
							
stage3 : register_read port map (stall_r => stall_stage3_in,
							stall_w => stall_stage6_in,
							clk=>clk,
							pc => pc_dec_out,
							r_a => r_a_dec,
							r_b => r_b_dec,
							r_c => r_c_dec,
							imm => imm_dec,
							op_code => op_dec,
							cz=> cz_dec,
							enable_5 => wb_enable_ma,
							data_5 => ma_data_out,
							addr_5 => wb_out_ma,
							reg_addr_5 => reg_upd_ma,
							data_out => data_ra,
							cz_out => cz_ra,
							r_co => r_co,
							op_out => op_ra,
							pc_out => pc_ra,
							mem_address_out => mem_add_in_alu,
							data_in_alu => data_out_alu(15 downto 0),
							wb_in_alu => wb_out_alu,
							wb_enbl_alu => wb_enable_alu,
							data_in_mem => ma_data_out(15 downto 0),
							wb_in_mem => wb_out_ma,
							wb_enbl_mem => wb_enable_ma,
							reg_updates => reg_upd_ra,
							mem_updates => mem_upd_ra,
							mem_sr => ms_ra,
							stall_out => stall_stage3_out
							);
		
stage4 : Execute port map (stall=> stall_stage4_in,
							clk=> clk,
							pc=>pc_ra,
							op_code=> op_ra,
							cz=> cz_ra,
							wb_in =>r_co,
							data_in => data_ra,
							mem_address => mem_add_in_alu,
							reg_bits => reg_upd_ra,
							reg_bits_out => reg_upd_alu,
							mem_bits => mem_upd_ra,
							mem_bits_out => mem_upd_alu,
							data_out => data_out_alu,
							wb_out => wb_out_alu,
							wb_enable => wb_enable_alu,
							pc_next =>pc_alu,
							mem_add_out => mem_add_out_alu,
							mem_sr => ms_ra,
							mem_sr_out => ms_alu,
							stall_out => stall_stage4_out
							);
							
stage5 : Mem_Access port map (stall => stall_stage5_in,
							clk => clk,
							start_address => mem_add_out_alu,
							data_in => data_out_alu,
							data_out => ma_data_out,
							wb_in => wb_out_alu,
							wb_enable => wb_enable_alu,
							reg_bits => reg_upd_alu,
							mem_bits => mem_upd_alu,
							mem_sr => ms_alu,
							wb_out => wb_out_ma,
							wb_enable_out => wb_enable_ma,
							reg_bits_out => reg_upd_ma,
							stall_out => stall_stage5_out
							);
end architecture arch;
