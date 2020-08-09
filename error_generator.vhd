LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY error_generator IS 
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		
		D_inst_type_err : OUT STD_LOGIC;
		D_op_code_err : OUT STD_LOGIC;
		D_reg_src1_err : OUT STD_LOGIC;
		D_reg_src2_err : OUT STD_LOGIC;
		D_reg_dest_err : OUT STD_LOGIC;
		D_inm_ext_err : OUT STD_LOGIC;
		D_ALU_ctrl_err : OUT STD_LOGIC;
		D_branch_err : OUT STD_LOGIC;
		D_branch_if_eq_err : OUT STD_LOGIC;
		D_jump_err : OUT STD_LOGIC;
		D_reg_src1_v_err : OUT STD_LOGIC;
		D_reg_src2_v_err : OUT STD_LOGIC;
		D_inm_src2_v_err : OUT STD_LOGIC;
		D_mem_write_err : OUT STD_LOGIC;
		D_byte_err : OUT STD_LOGIC;
		D_mem_read_err : OUT STD_LOGIC;
		D_reg_we_err : OUT STD_LOGIC;
		D_iret_err : OUT STD_LOGIC;
		D_invalid_inst_err : OUT STD_LOGIC


	);
END error_generator;

ARCHITECTURE structure OF error_generator IS

BEGIN


	D_inst_type_err <= '0';
	D_op_code_err <= '0';
	D_reg_src1_err <= '0';
	D_reg_src2_err <= '0';
	D_reg_dest_err <= '0';
	D_inm_ext_err <= '0';
	D_ALU_ctrl_err <= '0';
	D_branch_err <= '0';
	D_branch_if_eq_err <= '0';
	D_jump_err <= '0';
	D_reg_src1_v_err <= '0';
	D_reg_src2_v_err <= '0';
	D_inm_src2_v_err <= '0';
	D_mem_write_err <= '0';
	D_byte_err <= '0';
	D_mem_read_err <= '0';
	D_reg_we_err <= '0';
	D_iret_err <= '0';
	D_invalid_inst_err <= '0';


END structure;