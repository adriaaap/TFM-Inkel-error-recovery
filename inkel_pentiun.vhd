LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.UTILS.ALL;

ENTITY inkel_pentiun IS
	PORT(
		clk     : IN  STD_LOGIC;
		reset   : IN  STD_LOGIC;
		pc_out  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END inkel_pentiun;

ARCHITECTURE structure OF inkel_pentiun IS
	COMPONENT reg_status IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_in : IN STD_LOGIC;
			exc_new : IN STD_LOGIC;
			exc_code_new : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_new : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_old : IN STD_LOGIC;
			exc_code_old : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_old : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_out : OUT STD_LOGIC;
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT memory IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			f_req : IN STD_LOGIC;
			d_req : IN STD_LOGIC;
			d_we : IN STD_LOGIC;
			f_done : OUT STD_LOGIC;
			d_done : OUT STD_LOGIC;
			f_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			d_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			d_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			f_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			d_data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT exception_unit IS
		PORT(
			invalid_access_F : IN STD_LOGIC;
			mem_addr_F : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			invalid_inst_D : IN STD_LOGIC;
			inst_D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			invalid_access_C : IN STD_LOGIC;
			mem_addr_C : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_F : OUT STD_LOGIC;
			exc_code_F : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_D : OUT STD_LOGIC;
			exc_code_D : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_D : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_A : OUT STD_LOGIC;
			exc_code_A : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_A : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_C : OUT STD_LOGIC;
			exc_code_C : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_C : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT pc IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			addr_jump : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken : IN STD_LOGIC;
			exception_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exception : IN STD_LOGIC;
			iret : IN STD_LOGIC;
			load_PC : IN STD_LOGIC;
			pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			error_detected : IN STD_LOGIC;
			recovery_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			new_recovery_pc : IN STD_LOGIC;
			branch_was_taken : IN STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reg_priv_status IS
		PORT(clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			exc_W : IN STD_LOGIC;
			iret_A : IN STD_LOGIC;
			priv_status : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT fetch IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			priv_status_r : IN STD_LOGIC;
        	priv_status_w : IN STD_LOGIC;
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken : IN STD_LOGIC;
			inst : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v : OUT STD_LOGIC;
			invalid_access : OUT STD_LOGIC;
			mem_req : OUT STD_LOGIC;
			mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_done : IN STD_LOGIC;
			mem_data_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT cache_stage IS
		PORT(
			clk             : IN  STD_LOGIC;
			reset           : IN  STD_LOGIC;
			priv_status     : IN  STD_LOGIC;
			addr            : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_in         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			data_out        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			re              : IN  STD_LOGIC;
			we              : IN  STD_LOGIC;
			is_byte         : IN  STD_LOGIC;
			id              : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			done            : OUT STD_LOGIC;
			invalid_access  : OUT STD_LOGIC;
			mem_req         : OUT STD_LOGIC;
			mem_addr        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we          : OUT STD_LOGIC;
			mem_done        : IN  STD_LOGIC;
			mem_data_in     : IN  STD_LOGIC_VECTOR(127 DOWNTO 0);
			mem_data_out    : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			sb_store_id     : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
			sb_store_commit : IN  STD_LOGIC;
			sb_squash       : IN  STD_LOGIC;
			sb_error_detected : IN  STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reg_FD IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			inst_v_in : IN STD_LOGIC;
			inst_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v_out : OUT STD_LOGIC;
			inst_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux2_32bits IS
		PORT(
			DIn0 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn1 : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			ctrl : IN  STD_LOGIC;
			Dout : OUT  STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_bank IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			debug_dump : IN STD_LOGIC;
			src1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			src2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			data1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			data2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			we : IN STD_LOGIC;
			dest : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exception : IN STD_LOGIC;
			exc_code : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT decode IS
		PORT(
			inst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_v : IN STD_LOGIC;
			pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status : IN STD_LOGIC;
			inst_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			op_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			reg_src1 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2 : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			inm_ext : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_ctrl : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			branch : OUT STD_LOGIC;
			branch_if_eq : OUT STD_LOGIC;
			jump : OUT STD_LOGIC;
			reg_src1_v : OUT STD_LOGIC;
			reg_src2_v : OUT STD_LOGIC;
			inm_src2_v : OUT STD_LOGIC;
			mem_write : OUT STD_LOGIC;
			byte : OUT STD_LOGIC;
			mem_read : OUT STD_LOGIC;
			reg_we : OUT STD_LOGIC;
			iret : OUT STD_LOGIC;
			invalid_inst : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT bypass_unit IS
		PORT(
			reg_src1_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_src2_D        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_src1_v_D      : IN STD_LOGIC;
			reg_src2_v_D      : IN STD_LOGIC;
			inm_src2_v_D      : IN STD_LOGIC;
			reg_dest_A        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_A          : IN STD_LOGIC;
			reg_dest_C        : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_C          : IN STD_LOGIC;
			reg_dest_M5       : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			reg_we_M5         : IN STD_LOGIC;
			reg_src1_D_p_ROB  : IN STD_LOGIC;
			reg_src1_D_inst_type_ROB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_src2_D_p_ROB  : IN STD_LOGIC;
			reg_src2_D_inst_type_ROB : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			mux_src1_D_BP     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			mux_src2_D_BP     : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			mux_mem_data_D_BP : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			mux_mem_data_A_BP : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT detention_unit IS
		PORT(
			reset          : IN STD_LOGIC;
			inst_type_D    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_src1_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_D     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src1_v_D   : IN STD_LOGIC;
			reg_src2_v_D   : IN STD_LOGIC;
			mem_we_D 	   : IN STD_LOGIC;
			branch_taken_A : IN STD_LOGIC;
			mul_M1		   : IN STD_LOGIC;
			mul_M2		   : IN STD_LOGIC;
			reg_dest_M2    : IN STD_LOGIC_VECTOR(4 downto 0);
			mul_M3		   : IN STD_LOGIC;
			reg_dest_M3    : IN STD_LOGIC_VECTOR(4 downto 0);
			mul_M4		   : IN STD_LOGIC;
			reg_dest_M4    : IN STD_LOGIC_VECTOR(4 downto 0);
			reg_dest_M5    : IN STD_LOGIC_VECTOR(4 downto 0);
			mul_M5 		   : IN STD_LOGIC;
			inst_type_A    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_dest_A     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_we_A       : IN STD_LOGIC;
			mem_read_A     : IN STD_LOGIC;
			reg_dest_C     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			mem_read_C     : IN STD_LOGIC;
			done_F         : IN STD_LOGIC;
			done_C         : IN STD_LOGIC;
			exc_D          : IN STD_LOGIC;
			exc_A          : IN STD_LOGIC;
			exc_C          : IN STD_LOGIC;
			conflict       : OUT STD_LOGIC;
			reg_PC_reset   : OUT STD_LOGIC;
			reg_F_D_reset  : OUT STD_LOGIC;
			reg_D_A_reset  : OUT STD_LOGIC;
			reg_A_C_reset  : OUT STD_LOGIC;
			reg_PC_we      : OUT STD_LOGIC;
			reg_F_D_we     : OUT STD_LOGIC;
			reg_D_A_we     : OUT STD_LOGIC;
			reg_A_C_we     : OUT STD_LOGIC;
			rob_count      : OUT STD_LOGIC;
			rob_rollback   : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reg_DA IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			branch_in : IN STD_LOGIC;
			branch_if_eq_in : IN STD_LOGIC;
			jump_in : IN STD_LOGIC;
			inm_ext_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_ctrl_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			reg_src1_v_in : IN STD_LOGIC;
			reg_src2_v_in : IN STD_LOGIC;
			inm_src2_v_in : IN STD_LOGIC;
			reg_src1_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			reg_data2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			iret_in : IN STD_LOGIC;
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			branch_out : OUT STD_LOGIC;
			branch_if_eq_out : OUT STD_LOGIC;
			jump_out : OUT STD_LOGIC;
			inm_ext_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALU_ctrl_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			reg_src1_v_out : OUT STD_LOGIC;
			reg_src2_v_out : OUT STD_LOGIC;
			inm_src2_v_out : OUT STD_LOGIC;
			reg_src1_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			reg_data2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			iret_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT mux4_32bits IS
		PORT(
			DIn0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DIn3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ctrl : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT mux8_32bits IS
		PORT(
			Din0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din1 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din2 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din3 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din4 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din5 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din6 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Din7 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ctrl : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU IS
		PORT(
			DA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			DB : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			ALUctrl : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			Dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ALU_MUL_seg IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			load : IN STD_LOGIC;
			done_C : IN STD_LOGIC;
			DA : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 1
			DB : IN  STD_LOGIC_VECTOR (31 downto 0); --entrada 2
			reg_dest_in : IN STD_LOGIC_VECTOR(4 downto 0);
			reg_we_in : IN STD_LOGIC;
			M2_mul : OUT STD_LOGIC;
			reg_dest_M2 : OUT STD_LOGIC_VECTOR(4 downto 0);
			M3_mul : OUT STD_LOGIC;
			reg_dest_M3 : OUT STD_LOGIC_VECTOR(4 downto 0);
			M4_mul : OUT STD_LOGIC;
			reg_dest_M4 : OUT STD_LOGIC_VECTOR(4 downto 0);
			M5_mul : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 downto 0);
			reg_we_out : OUT STD_LOGIC;
			Dout : OUT  STD_LOGIC_VECTOR(31 downto 0);
			-- reg status signals --
			pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_in : IN STD_LOGIC;
			exc_new : IN STD_LOGIC;
			exc_code_new : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_new : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_old : IN STD_LOGIC;
			exc_code_old : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_old : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_in : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			priv_status_out : OUT STD_LOGIC;
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			rob_idx_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			inst_type_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_AC IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			mem_we_in : IN STD_LOGIC;
			byte_in : IN STD_LOGIC;
			mem_read_in : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we_out : OUT STD_LOGIC;
			byte_out : OUT STD_LOGIC;
			mem_read_out : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			ALU_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_W IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			we : IN STD_LOGIC;
			reg_we_in : IN STD_LOGIC;
			reg_dest_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we_in : IN STD_LOGIC;
			branch_taken_in : IN STD_LOGIC;
			v : OUT STD_LOGIC;
			reg_we_out : OUT STD_LOGIC;
			reg_dest_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_we_out : OUT STD_LOGIC;
			branch_taken_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT reorder_buffer IS
		PORT(
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			rob_we_1 : IN STD_LOGIC;
			rob_w_pos_1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			reg_v_in_1 : IN STD_LOGIC;
			reg_in_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_in_1 : IN STD_LOGIC;
			exc_code_in_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_in_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_type_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			store_1 : IN STD_LOGIC;
			rob_we_2 : IN STD_LOGIC;
			rob_w_pos_2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			reg_v_in_2 : IN STD_LOGIC;
			reg_in_2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_in_2 : IN STD_LOGIC;
			exc_code_in_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_in_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_type_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			rob_we_3 : IN STD_LOGIC;
			rob_w_pos_3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			reg_v_in_3 : IN STD_LOGIC;
			reg_in_3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_in_3 : IN STD_LOGIC;
			exc_code_in_3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_in_3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			inst_type_3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			branch_taken_3 : IN STD_LOGIC;
			reg_v_out : OUT STD_LOGIC;
			reg_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_out : OUT STD_LOGIC;
			exc_code_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			valid_out : OUT STD_LOGIC;
			tail_we : IN STD_LOGIC;
			rollback_tail : IN STD_LOGIC;
			tail_out : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			reg_src1_D_BP : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src1_D_v_BP : IN STD_LOGIC;
			reg_src1_D_p_BP : OUT STD_LOGIC;
			reg_src1_D_inst_type_BP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_src1_D_data_BP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			reg_src2_D_BP : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_src2_D_v_BP : IN STD_LOGIC;
			reg_src2_D_p_BP : OUT STD_LOGIC;
			reg_src2_D_inst_type_BP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			reg_src2_D_data_BP : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			sb_store_id : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			sb_store_commit : OUT STD_LOGIC;
			sb_squash : OUT STD_LOGIC;
			error_detected : IN STD_LOGIC;
			new_recovery_pc : OUT STD_LOGIC;
			branch_was_taken : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT output_comparator IS
		PORT(
			-- Main rob input
			reg_v_1 : IN STD_LOGIC;
			reg_1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_1 : IN STD_LOGIC;
			exc_code_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			valid_1	: IN STD_LOGIC;
			-- Dup rob input
			reg_v_2 : IN STD_LOGIC;
			reg_2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			reg_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_2 : IN STD_LOGIC;
			exc_code_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			pc_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			valid_2 : IN STD_LOGIC;
			-- ALU 1 input
			jump_addr_A_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken_A_1 : IN STD_LOGIC;
			-- ALU 2 input
			jump_addr_A_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			branch_taken_A_2 : IN STD_LOGIC;
			-- Cache 1 input
			mem_req_C_1 : IN STD_LOGIC;
			mem_we_C_1 : IN STD_LOGIC;
			mem_addr_C_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out_C_1 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			-- Cache 2 input
			mem_req_C_2 : IN STD_LOGIC;
			mem_we_C_2 : IN STD_LOGIC;
			mem_addr_C_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			mem_data_out_C_2 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			-- Segmentation regs 1 input
			reg_F_D_reset_DU_1 : IN STD_LOGIC;
			reg_D_A_reset_DU_1 : IN STD_LOGIC;
			reg_F_D_we_1 : IN STD_LOGIC;
			reg_D_A_we_1 : IN STD_LOGIC;
			-- Segmentation regs 2 input
			reg_F_D_reset_DU_2 : IN STD_LOGIC;
			reg_D_A_reset_DU_2 : IN STD_LOGIC;
			reg_F_D_we_2 : IN STD_LOGIC;
			reg_D_A_we_2 : IN STD_LOGIC;
			-- Stall unit 1 input
			load_PC_1 : IN STD_LOGIC;
			reset_PC_1 : IN STD_LOGIC;
			-- Stall unit 2 input
			load_PC_2	: IN STD_LOGIC;
			reset_PC_2 : IN STD_LOGIC;
			-- Exception unit 1 input
			exc_F_E_1 : IN STD_LOGIC;
			exc_D_E_1 : IN STD_LOGIC;
			exc_code_F_E_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_code_D_E_1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_F_E_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_data_D_E_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			-- Exception unit 2 input
			exc_F_E_2 : IN STD_LOGIC;
			exc_D_E_2 : IN STD_LOGIC;
			exc_code_F_E_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_code_D_E_2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			exc_data_F_E_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			exc_data_D_E_2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			-- Output
			error_detected : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT error_generator IS 
		PORT (clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		
		-- ALU stage --
		branch_A_err : OUT STD_LOGIC;
		jump_A_err : OUT STD_LOGIC;
		reg_data1_A_err : OUT STD_LOGIC;
		pc_A_err : OUT STD_LOGIC;
		reg_data2_A_err : OUT STD_LOGIC;
		inm_ext_A_err : OUT STD_LOGIC;
		inm_src2_v_A_err : OUT STD_LOGIC;
		branch_if_eq_A_err : OUT STD_LOGIC;
		ALU_ctrl_A_err : OUT STD_LOGIC;
		mem_data_A_err : OUT STD_LOGIC;
		mem_we_A_err : OUT STD_LOGIC;
		byte_A_err : OUT STD_LOGIC;
		mem_read_A_err : OUT STD_LOGIC;
		reg_we_A_err : OUT STD_LOGIC;
		reg_dest_A_err : OUT STD_LOGIC;
		priv_status_A_err : OUT STD_LOGIC;
		rob_idx_A_err : OUT STD_LOGIC;
		inst_type_A_err : OUT STD_LOGIC;
		iret_A_err : OUT STD_LOGIC;

    		-- Cache stage --
    		cache_we_C_err : OUT STD_LOGIC;
    		cache_re_C_err : OUT STD_LOGIC;
    		byte_C_err : OUT STD_LOGIC;
    		reg_we_C_err : OUT STD_LOGIC;
    		priv_status_C_err : OUT STD_LOGIC;
    		inst_type_C_err : OUT STD_LOGIC;
    		rob_idx_C_err : OUT STD_LOGIC;
    		reg_dest_C_err : OUT STD_LOGIC;
    		pc_C_err : OUT STD_LOGIC;
    		ALU_out_C_err : OUT STD_LOGIC;
    		cache_data_in_C_err : OUT STD_LOGIC;

    		-- MUL stage --
    		mul_M5_err : OUT STD_LOGIC;
    		mul_out_M5_err : OUT STD_LOGIC;
    		reg_dest_M5_err : OUT STD_LOGIC;
    		reg_we_M5_err : OUT STD_LOGIC;
    		pc_M5_err : OUT STD_LOGIC;
    		priv_status_M5_err : OUT STD_LOGIC;
    		rob_idx_M5_err : OUT STD_LOGIC;
    		inst_type_M5_err : OUT STD_LOGIC;

    		-- Writeback stage --
    		-- MEM -- 
    		v_W_MEM_err : OUT STD_LOGIC;
    		reg_we_W_MEM_err : OUT STD_LOGIC;
    		reg_dest_W_MEM_err : OUT STD_LOGIC;
    		reg_data_W_MEM_err : OUT STD_LOGIC;
    		mem_we_W_MEM_err : OUT STD_LOGIC;
    		pc_W_MEM_err : OUT STD_LOGIC;
    		rob_idx_W_MEM_err : OUT STD_LOGIC;
    		inst_type_W_MEM_err : OUT STD_LOGIC;
    		-- ALU --
    		v_W_ALU_err : OUT STD_LOGIC;
    		reg_we_W_ALU_err : OUT STD_LOGIC;
    		reg_dest_W_ALU_err : OUT STD_LOGIC;
    		reg_data_W_ALU_err : OUT STD_LOGIC;
    		pc_W_ALU_err : OUT STD_LOGIC;
    		rob_idx_W_ALU_err : OUT STD_LOGIC;
    		inst_type_W_ALU_err : OUT STD_LOGIC;
    		-- MUL --
    		v_W_MUL_err : OUT STD_LOGIC;
    		reg_we_W_MUL_err : OUT STD_LOGIC;
    		reg_dest_W_MUL_err : OUT STD_LOGIC;
    		reg_data_W_MUL_err : OUT STD_LOGIC;
    		pc_W_MUL_err : OUT STD_LOGIC;
    		rob_idx_W_MUL_err : OUT STD_LOGIC;
    		inst_type_W_MUL_err : OUT STD_LOGIC

		);
	END COMPONENT;

	-- Fetch stage signals
	SIGNAL inst_v_F : STD_LOGIC;
	SIGNAL mem_req_F : STD_LOGIC;
	SIGNAL mem_done_F : STD_LOGIC;
	SIGNAL priv_status_F : STD_LOGIC;
	SIGNAL invalid_access_F : STD_LOGIC;
	SIGNAL rob_idx_F : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL pc_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inst_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_addr_F : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in_F : STD_LOGIC_VECTOR(127 DOWNTO 0);

	-- Decode stage signals
	SIGNAL inst_v_D : STD_LOGIC;
	SIGNAL branch_D : STD_LOGIC;
	SIGNAL jump_D : STD_LOGIC;
	SIGNAL branch_if_eq_D : STD_LOGIC;
	SIGNAL reg_we_D : STD_LOGIC;
	SIGNAL mem_read_D : STD_LOGIC;
	SIGNAL byte_D : STD_LOGIC;
	SIGNAL mem_we_D : STD_LOGIC;
	SIGNAL reg_src1_v_D : STD_LOGIC;
	SIGNAL reg_src2_v_D : STD_LOGIC;
	SIGNAL inm_src2_v_D : STD_LOGIC;
	SIGNAL priv_status_D : STD_LOGIC;
	SIGNAL invalid_inst_D : STD_LOGIC;
	SIGNAL iret_D : STD_LOGIC;
	SIGNAL inst_type_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_ctrl_D : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL rob_idx_D : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_src1_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src2_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_dest_D : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL op_code_D : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL inst_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data1_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL conflict_D : STD_LOGIC;
	SIGNAL mem_data_D_BP : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data1_BP_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL data2_BP_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- Original signals before potential errors are introduced --
	SIGNAL inst_type_D_original : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL op_code_D_original : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL reg_src1_D_original : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src2_D_original : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_dest_D_original : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL inm_ext_D_original : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_ctrl_D_original : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL branch_D_original : STD_LOGIC;
	SIGNAL jump_D_original : STD_LOGIC;
	SIGNAL branch_if_eq_D_original : STD_LOGIC;
	SIGNAL reg_src1_v_D_original : STD_LOGIC;
	SIGNAL reg_src2_v_D_original : STD_LOGIC;
	SIGNAL inm_src2_v_D_original : STD_LOGIC;
	SIGNAL mem_we_D_original : STD_LOGIC;
	SIGNAL mem_read_D_original : STD_LOGIC;
	SIGNAL byte_D_original : STD_LOGIC;
	SIGNAL reg_we_D_original : STD_LOGIC;
	SIGNAL invalid_inst_D_original : STD_LOGIC;
	SIGNAL iret_D_original : STD_LOGIC;
	-- ALU stage signals
	SIGNAL Z : STD_LOGIC;
	SIGNAL branch_A : STD_LOGIC;
	SIGNAL jump_A : STD_LOGIC;
	SIGNAL jump_or_branch_A : STD_LOGIC;
	SIGNAL branch_if_eq_A : STD_LOGIC;
	SIGNAL branch_taken_A : STD_LOGIC;
	SIGNAL mem_read_A : STD_LOGIC;
	SIGNAL reg_src1_v_A : STD_LOGIC;
	SIGNAL reg_src2_v_A : STD_LOGIC;
	SIGNAL inm_src2_v_A : STD_LOGIC;
	SIGNAL mem_we_A : STD_LOGIC;
	SIGNAL byte_A : STD_LOGIC;
	SIGNAL reg_we_A : STD_LOGIC;
	SIGNAL priv_status_A : STD_LOGIC;
	SIGNAL iret_A : STD_LOGIC;
	SIGNAL inst_type_A : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_ctrl_A : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL rob_idx_A : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src1_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src2_A : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL jump_addr_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data1_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_data1_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_data2_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A_BP : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Cache stage signals
	SIGNAL cache_we_C : STD_LOGIC;
	SIGNAL cache_re_C : STD_LOGIC;
	SIGNAL byte_C : STD_LOGIC;
	SIGNAL reg_we_C : STD_LOGIC;
	SIGNAL priv_status_C : STD_LOGIC;
	SIGNAL invalid_access_C : STD_LOGIC;
	SIGNAL done_C : STD_LOGIC;
	SIGNAL mem_req_C : STD_LOGIC;
	SIGNAL mem_we_C : STD_LOGIC;
	SIGNAL mem_done_C : STD_LOGIC;
	SIGNAL mem_addr_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_in_C : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL mem_data_out_C : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL inst_type_C : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL rob_idx_C : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_C : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_in_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_store_id_C : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL sb_store_commit_C : STD_LOGIC;
	SIGNAL sb_squash_C : STD_LOGIC;

	-- Mul stage signals
	SIGNAL Mul_pipeline_reset : STD_LOGIC;
	SIGNAL mul_M1 : STD_LOGIC;
	SIGNAL mul_M2 : STD_LOGIC;
	SIGNAL reg_dest_M2 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M3 : STD_LOGIC;
	SIGNAL reg_dest_M3 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M4 : STD_LOGIC;
	SIGNAL reg_dest_M4 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M5 : STD_LOGIC;
	SIGNAL mul_out_M5 : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_dest_M5 : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL reg_we_M5 : STD_LOGIC;
	SIGNAL pc_M5 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL priv_status_M5 : STD_LOGIC;
	SIGNAL rob_idx_M5 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_M5 : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Writeback stage signals
	SIGNAL v_W_MEM : STD_LOGIC;
	SIGNAL reg_we_W_MEM : STD_LOGIC;
	SIGNAL reg_dest_W_MEM : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_we_W_MEM : STD_LOGIC;
	SIGNAL pc_W_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_MEM : STD_LOGIC;
	SIGNAL exc_code_W_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_MEM : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MEM : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MEM : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL v_W_ALU : STD_LOGIC;
	SIGNAL reg_we_W_ALU : STD_LOGIC;
	SIGNAL reg_dest_W_ALU : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_ALU : STD_LOGIC;
	SIGNAL exc_code_W_ALU : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_ALU : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_ALU : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_ALU : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL branch_taken_W_ALU : STD_LOGIC;
	SIGNAL v_W_MUL : STD_LOGIC;
	SIGNAL reg_we_W_MUL : STD_LOGIC;
	SIGNAL reg_dest_W_MUL : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MUL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_MUL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_MUL : STD_LOGIC;
	SIGNAL exc_code_W_MUL : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_MUL : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MUL : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MUL : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- ROB output signals
	SIGNAL reg_we_ROB : STD_LOGIC;
	SIGNAL reg_dest_ROB : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_ROB : STD_LOGIC;
	SIGNAL exc_code_ROB : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL valid_ROB : STD_LOGIC;
	SIGNAL debug_dump_ROB : STD_LOGIC;
	SIGNAL reg_src1_D_p_ROB : STD_LOGIC;
	SIGNAL reg_src1_D_inst_type_ROB : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_src1_D_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_src2_D_p_ROB : STD_LOGIC;
	SIGNAL reg_src2_D_inst_type_ROB : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_src2_D_data_ROB : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL new_recovery_pc : STD_LOGIC;
	SIGNAL branch_was_taken : STD_LOGIC;
	SIGNAL reg_we_ROB_validated : STD_LOGIC;
	SIGNAL exc_ROB_validated : STD_LOGIC;

	-- Segmentation registers signals
	SIGNAL reg_F_D_reset : STD_LOGIC;
	SIGNAL reg_F_D_reset_DU : STD_LOGIC;
	SIGNAL reg_D_A_reset : STD_LOGIC;
	SIGNAL reg_D_A_reset_DU : STD_LOGIC;
	SIGNAL reg_A_C_reset : STD_LOGIC;
	SIGNAL reg_A_C_reset_DU : STD_LOGIC;
	SIGNAL reg_W_MEM_reset : STD_LOGIC;
	SIGNAL reg_W_ALU_reset : STD_LOGIC;
	SIGNAL reg_W_MUL_reset : STD_LOGIC;
	SIGNAL reg_F_D_we : STD_LOGIC;
	SIGNAL reg_D_A_we : STD_LOGIC;
	SIGNAL reg_A_C_we : STD_LOGIC;

	-- Stage

	-- Stall unit signals
	SIGNAL load_PC : STD_LOGIC;
	SIGNAL reset_PC : STD_LOGIC;
	SIGNAL rob_count_DU : STD_LOGIC;
	SIGNAL rob_rollback_DU : STD_LOGIC;

	-- Bypass unit signals
	SIGNAL mux_src1_D_BP_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_src2_D_BP_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_mem_data_D_BP_ctrl : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_mem_data_A_BP_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Exception unit signals
	SIGNAL exc_F_E : STD_LOGIC;
	SIGNAL exc_D : STD_LOGIC;
	SIGNAL exc_D_E : STD_LOGIC;
	SIGNAL exc_A : STD_LOGIC;
	SIGNAL exc_A_E : STD_LOGIC;
	SIGNAL exc_M5 : STD_LOGIC;
	SIGNAL exc_M5_E : STD_LOGIC;
	SIGNAL exc_C : STD_LOGIC;
	SIGNAL exc_C_E : STD_LOGIC;
	SIGNAL exc_code_F_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_M5 : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_M5_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C_E : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_F_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_M5 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_M5_E : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C_E : STD_LOGIC_VECTOR(31 DOWNTO 0);



    -- START 2nd pipeline signals --
    -- Signals with the name "***_dup" are signals that have been fully duplicated for the second pipeline --

    -- Signals with the name "***_ghost" are signals for the outputs generated in the duplicated pipeline that would normally go to a unit that has not been duplicated. 
    -- These signals are compared with the signals from the main pipeline, then they are discarded"

    -- The rest of the input signals in the duplicated pipeline that have not been renamed as "***_dup" come from a signal generated outside the duplicate pipeline, which sends data to both pipelines"

	-- Decode stage signals
	SIGNAL conflict_D_dup : STD_LOGIC;

	-- ALU stage signals
	SIGNAL Z_dup : STD_LOGIC;
	SIGNAL branch_A_dup : STD_LOGIC;
	SIGNAL jump_A_dup : STD_LOGIC;
	SIGNAL jump_or_branch_A_dup : STD_LOGIC;
	SIGNAL branch_if_eq_A_dup : STD_LOGIC;
	SIGNAL branch_taken_A_dup : STD_LOGIC;
	SIGNAL mem_read_A_dup : STD_LOGIC;
	SIGNAL reg_src1_v_A_dup : STD_LOGIC; -- unused signal? --
	SIGNAL reg_src2_v_A_dup : STD_LOGIC; -- unused signal? --
	SIGNAL inm_src2_v_A_dup : STD_LOGIC;
	SIGNAL mem_we_A_dup : STD_LOGIC;
	SIGNAL byte_A_dup : STD_LOGIC;
	SIGNAL reg_we_A_dup : STD_LOGIC;
	SIGNAL priv_status_A_dup : STD_LOGIC;
	SIGNAL iret_A_dup : STD_LOGIC;
	SIGNAL inst_type_A_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ALU_ctrl_A_dup : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL rob_idx_A_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_A_dup : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_src1_A_dup : STD_LOGIC_VECTOR(4 DOWNTO 0); -- unused signal? --
	SIGNAL reg_src2_A_dup : STD_LOGIC_VECTOR(4 DOWNTO 0); -- unused signal? --
	SIGNAL pc_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL jump_addr_A_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data1_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data2_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL inm_ext_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_data1_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_data2_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_data_A_BP_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-- Cache stage signals
	SIGNAL cache_we_C_dup : STD_LOGIC;
	SIGNAL cache_re_C_dup : STD_LOGIC;
	SIGNAL byte_C_dup : STD_LOGIC;
	SIGNAL reg_we_C_dup : STD_LOGIC;
	SIGNAL priv_status_C_dup : STD_LOGIC; --exists but avoid sending it to fetch
	SIGNAL invalid_access_C_dup : STD_LOGIC;
	SIGNAL done_C_dup : STD_LOGIC;
	SIGNAL mem_req_C_ghost : STD_LOGIC;
	SIGNAL mem_we_C_ghost : STD_LOGIC;
	SIGNAL mem_addr_C_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0); --keep for exception unit, ghost output to memory
	SIGNAL mem_data_out_C_ghost : STD_LOGIC_VECTOR(127 DOWNTO 0);
	SIGNAL inst_type_C_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL rob_idx_C_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_C_dup : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_C_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_C_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_in_C_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_data_C_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL sb_store_id_C_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL sb_store_commit_C_dup : STD_LOGIC;
	SIGNAL sb_squash_C_dup : STD_LOGIC;
	-- These are the clean signals generated as outputs from the stage. These signals will then be assigned to their "dup" equivalents (which are treated as the final output 
        -- of their stage) when processed with error signals. This step was not required for the ALU because the base output signal comes from the first pipeline.
	SIGNAL cache_we_C_clean : STD_LOGIC;
	SIGNAL cache_re_C_clean : STD_LOGIC;
	SIGNAL byte_C_clean : STD_LOGIC;
	SIGNAL reg_we_C_clean : STD_LOGIC;
	SIGNAL priv_status_C_clean : STD_LOGIC; --exists but avoid sending it to fetch
	SIGNAL inst_type_C_clean : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL rob_idx_C_clean : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL reg_dest_C_clean : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL pc_C_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_out_C_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL cache_data_in_C_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);


	-- Mul stage signals
	SIGNAL Mul_pipeline_reset_dup : STD_LOGIC;
	SIGNAL mul_M1_dup : STD_LOGIC;
	SIGNAL mul_M2_dup : STD_LOGIC;
	SIGNAL reg_dest_M2_dup : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M3_dup : STD_LOGIC;
	SIGNAL reg_dest_M3_dup : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M4_dup : STD_LOGIC;
	SIGNAL reg_dest_M4_dup : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL mul_M5_dup : STD_LOGIC;
	SIGNAL mul_out_M5_dup : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_dest_M5_dup : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL reg_we_M5_dup : STD_LOGIC;
	SIGNAL pc_M5_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL priv_status_M5_dup : STD_LOGIC;
	SIGNAL rob_idx_M5_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_M5_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- The MUL stage is a multi-cycle, multi-stage unit. However, for the sake of simplicity, we will only generate errors at the output of the 5th register (i.e., on the final result)
	SIGNAL mul_M5_clean : STD_LOGIC;
	SIGNAL mul_out_M5_clean : STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL reg_dest_M5_clean : STD_LOGIC_VECTOR(4 downto 0);
	SIGNAL reg_we_M5_clean : STD_LOGIC;
	SIGNAL pc_M5_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL priv_status_M5_clean : STD_LOGIC;
	SIGNAL rob_idx_M5_clean : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_M5_clean : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Writeback stage signals
	SIGNAL v_W_MEM_dup : STD_LOGIC;
	SIGNAL reg_we_W_MEM_dup : STD_LOGIC;
	SIGNAL reg_dest_W_MEM_dup : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MEM_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_we_W_MEM_dup : STD_LOGIC;
	SIGNAL pc_W_MEM_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_MEM_dup : STD_LOGIC;
	SIGNAL exc_code_W_MEM_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_MEM_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MEM_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MEM_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL v_W_ALU_dup : STD_LOGIC;
	SIGNAL reg_we_W_ALU_dup : STD_LOGIC;
	SIGNAL reg_dest_W_ALU_dup : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_ALU_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_ALU_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_ALU_dup : STD_LOGIC;
	SIGNAL exc_code_W_ALU_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_ALU_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_ALU_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_ALU_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL branch_taken_W_ALU_dup : STD_LOGIC;
	SIGNAL v_W_MUL_dup : STD_LOGIC;
	SIGNAL reg_we_W_MUL_dup : STD_LOGIC;
	SIGNAL reg_dest_W_MUL_dup : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MUL_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_MUL_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_W_MUL_dup : STD_LOGIC;
	SIGNAL exc_code_W_MUL_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_W_MUL_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MUL_dup : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MUL_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- Clean writeback stage signals --
	-- MEM -- 
	SIGNAL v_W_MEM_clean : STD_LOGIC;
	SIGNAL reg_we_W_MEM_clean : STD_LOGIC;
	SIGNAL reg_dest_W_MEM_clean : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MEM_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_we_W_MEM_clean : STD_LOGIC;
	SIGNAL pc_W_MEM_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MEM_clean : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MEM_clean : STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- ALU --
	SIGNAL v_W_ALU_clean : STD_LOGIC;
	SIGNAL reg_we_W_ALU_clean : STD_LOGIC;
	SIGNAL reg_dest_W_ALU_clean : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_ALU_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_ALU_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_ALU_clean : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_ALU_clean : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL branch_taken_W_ALU_clean : STD_LOGIC;
	-- MUL --
	SIGNAL v_W_MUL_clean : STD_LOGIC;
	SIGNAL reg_we_W_MUL_clean : STD_LOGIC;
	SIGNAL reg_dest_W_MUL_clean : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_W_MUL_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_W_MUL_clean : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL rob_idx_W_MUL_clean : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inst_type_W_MUL_clean : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- ROB output signals
	SIGNAL reg_we_ROB_ghost : STD_LOGIC;
	SIGNAL reg_dest_ROB_ghost : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL reg_data_ROB_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_ROB_ghost : STD_LOGIC;
	SIGNAL exc_code_ROB_ghost : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_ROB_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pc_ROB_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL valid_ROB_ghost : STD_LOGIC;
	SIGNAL debug_dump_ROB_ghost : STD_LOGIC;
	SIGNAL reg_src1_D_p_ROB_dup : STD_LOGIC;
	SIGNAL reg_src1_D_inst_type_ROB_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_src1_D_data_ROB_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL reg_src2_D_p_ROB_dup : STD_LOGIC;
	SIGNAL reg_src2_D_inst_type_ROB_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL reg_src2_D_data_ROB_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL new_recovery_pc_ghost : STD_LOGIC;
	SIGNAL branch_was_taken_ghost : STD_LOGIC;

	-- Segmentation registers signals
	SIGNAL reg_F_D_reset_DU_ghost : STD_LOGIC;
	SIGNAL reg_D_A_reset_DU_ghost : STD_LOGIC;
	SIGNAL reg_A_C_reset_dup : STD_LOGIC;
	SIGNAL reg_A_C_reset_DU_dup : STD_LOGIC;
	SIGNAL reg_W_MEM_reset_dup : STD_LOGIC;
	SIGNAL reg_W_ALU_reset_dup : STD_LOGIC;
	SIGNAL reg_W_MUL_reset_dup : STD_LOGIC;
	SIGNAL reg_A_C_we_dup : STD_LOGIC;
	SIGNAL reg_F_D_we_ghost : STD_LOGIC;
	SIGNAL reg_D_A_we_ghost : STD_LOGIC;



	-- Stage

	-- Stall unit signals
	SIGNAL load_PC_ghost : STD_LOGIC;
	SIGNAL reset_PC_ghost : STD_LOGIC;
	SIGNAL rob_count_DU_dup : STD_LOGIC;
	SIGNAL rob_rollback_DU_dup : STD_LOGIC;

	-- Bypass unit signals
	SIGNAL mux_src1_D_BP_ctrl_dup : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_src2_D_BP_ctrl_dup : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_mem_data_D_BP_ctrl_dup : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mux_mem_data_A_BP_ctrl_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);

	-- Exception unit signals
	SIGNAL exc_F_E_ghost : STD_LOGIC;
	SIGNAL exc_D_E_ghost : STD_LOGIC;
	SIGNAL exc_A_E_dup : STD_LOGIC;
	SIGNAL exc_M5_dup : STD_LOGIC;
	SIGNAL exc_M5_E_dup : STD_LOGIC;
	SIGNAL exc_C_dup : STD_LOGIC;
	SIGNAL exc_C_E_dup : STD_LOGIC;
	SIGNAL exc_code_F_E_ghost : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_D_E_ghost : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_A_E_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_M5_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_M5_E_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_code_C_E_dup : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL exc_data_F_E_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_D_E_ghost : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_A_E_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_M5_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_M5_E_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL exc_data_C_E_dup : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL error_detected : STD_LOGIC;

    -- END 2nd pipeline signals

    -- Signals from error generator --
    -- In every stage, we might introduce errors on the input data for that stage. The input data comes from the register that feeds the stage. --
    -- For instance, for the ALU step, the errors will be introduced to the data as it comes out from register reg_DA. --
    -- If the stage produces wrong outputs due to an induced error, these shall be stored on the next register (if the error is not detected immediately)
    -- ALU --
    	SIGNAL branch_A_err : STD_LOGIC;
    	SIGNAL jump_A_err : STD_LOGIC;
    	SIGNAL reg_data1_A_err : STD_LOGIC;
    	SIGNAL pc_A_err : STD_LOGIC;
    	SIGNAL reg_data2_A_err : STD_LOGIC;
    	SIGNAL inm_ext_A_err : STD_LOGIC;
    	SIGNAL inm_src2_v_A_err : STD_LOGIC;
    	SIGNAL branch_if_eq_A_err : STD_LOGIC;
    	SIGNAL ALU_ctrl_A_err : STD_LOGIC;
    	SIGNAL mem_data_A_err : STD_LOGIC;
    	SIGNAL mem_we_A_err : STD_LOGIC;
    	SIGNAL byte_A_err : STD_LOGIC;
    	SIGNAL mem_read_A_err : STD_LOGIC;
    	SIGNAL reg_we_A_err : STD_LOGIC;
    	SIGNAL reg_dest_A_err : STD_LOGIC;
    	SIGNAL priv_status_A_err : STD_LOGIC;
    	SIGNAL rob_idx_A_err : STD_LOGIC;
    	SIGNAL inst_type_A_err : STD_LOGIC;
    	SIGNAL iret_A_err : STD_LOGIC;

    	-- Cache stage --
    	SIGNAL cache_we_C_err : STD_LOGIC;
    	SIGNAL cache_re_C_err : STD_LOGIC;
    	SIGNAL byte_C_err : STD_LOGIC;
    	SIGNAL reg_we_C_err : STD_LOGIC;
    	SIGNAL priv_status_C_err : STD_LOGIC;
    	SIGNAL inst_type_C_err : STD_LOGIC;
    	SIGNAL rob_idx_C_err : STD_LOGIC;
    	SIGNAL reg_dest_C_err : STD_LOGIC;
    	SIGNAL pc_C_err : STD_LOGIC;
    	SIGNAL ALU_out_C_err : STD_LOGIC;
    	SIGNAL cache_data_in_C_err : STD_LOGIC;

    	-- MUL stage --
    	SIGNAL mul_M5_err : STD_LOGIC;
    	SIGNAL mul_out_M5_err : STD_LOGIC;
    	SIGNAL reg_dest_M5_err : STD_LOGIC;
    	SIGNAL reg_we_M5_err : STD_LOGIC;
    	SIGNAL pc_M5_err : STD_LOGIC;
    	SIGNAL priv_status_M5_err : STD_LOGIC;
    	SIGNAL rob_idx_M5_err : STD_LOGIC;
    	SIGNAL inst_type_M5_err : STD_LOGIC;

    	-- Writeback stage --
    	-- MEM -- 
    	SIGNAL v_W_MEM_err : STD_LOGIC;
    	SIGNAL reg_we_W_MEM_err : STD_LOGIC;
    	SIGNAL reg_dest_W_MEM_err : STD_LOGIC;
    	SIGNAL reg_data_W_MEM_err : STD_LOGIC;
    	SIGNAL mem_we_W_MEM_err : STD_LOGIC;
    	SIGNAL pc_W_MEM_err : STD_LOGIC;
    	SIGNAL rob_idx_W_MEM_err : STD_LOGIC;
    	SIGNAL inst_type_W_MEM_err : STD_LOGIC;
    	-- ALU --
    	SIGNAL v_W_ALU_err : STD_LOGIC;
    	SIGNAL reg_we_W_ALU_err : STD_LOGIC;
    	SIGNAL reg_dest_W_ALU_err : STD_LOGIC;
    	SIGNAL reg_data_W_ALU_err : STD_LOGIC;
    	SIGNAL pc_W_ALU_err : STD_LOGIC;
    	SIGNAL rob_idx_W_ALU_err : STD_LOGIC;
    	SIGNAL inst_type_W_ALU_err : STD_LOGIC;
    	-- MUL --
    	SIGNAL v_W_MUL_err : STD_LOGIC;
    	SIGNAL reg_we_W_MUL_err : STD_LOGIC;
    	SIGNAL reg_dest_W_MUL_err : STD_LOGIC;
    	SIGNAL reg_data_W_MUL_err : STD_LOGIC;
    	SIGNAL pc_W_MUL_err : STD_LOGIC;
    	SIGNAL rob_idx_W_MUL_err : STD_LOGIC;
    	SIGNAL inst_type_W_MUL_err : STD_LOGIC;




BEGIN

	mem: memory PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_ROB,
		f_req => mem_req_F,
		d_req => mem_req_C,
		d_we => mem_we_C,
		f_done => mem_done_F,
		d_done => mem_done_C,
		f_addr => mem_addr_F,
		d_addr => mem_addr_C,
		d_data_in => mem_data_out_C,
		f_data_out => mem_data_in_F,
		d_data_out => mem_data_in_C
	);

	----------------------------- Control -------------------------------

	exc : exception_unit PORT MAP(
		invalid_access_F => invalid_access_F,
		mem_addr_F => pc_F,
		invalid_inst_D => invalid_inst_D,
		inst_D => inst_D,
		invalid_access_C => invalid_access_C,
		mem_addr_C => ALU_out_C,
		exc_F => exc_F_E,
		exc_code_F => exc_code_F_E,
		exc_data_F => exc_data_F_E,
		exc_D => exc_D_E,
		exc_code_D => exc_code_D_E,
		exc_data_D => exc_data_D_E,
		exc_A => exc_A_E,
		exc_code_A => exc_code_A_E,
		exc_data_A => exc_data_A_E,
		exc_C => exc_C_E,
		exc_code_C => exc_code_C_E,
		exc_data_C => exc_data_C_E
	);

	DU : detention_unit PORT MAP(
		reset => reset,
		inst_type_D => inst_type_D,
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_dest_D => reg_dest_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		mem_we_D => mem_we_D,
		branch_taken_A => branch_taken_A,
		mul_M1 => mul_M1,
		mul_M2 => mul_M2,
		reg_dest_M2 => reg_dest_M2,
		mul_M3 => mul_M3,
		reg_dest_M3 => reg_dest_M3,
		mul_M4 => mul_M4,
		reg_dest_M4 => reg_dest_M4,
		mul_M5 => mul_M5,
		reg_dest_M5 => reg_dest_M5,
		inst_type_A => inst_type_A,
		reg_dest_A => reg_dest_A,
		reg_we_A => reg_we_A,
		mem_read_A => mem_read_A,
		reg_dest_C => reg_dest_C,
		mem_read_C => cache_re_C,
		done_F => inst_v_F,
		done_C => done_C,
		exc_D => exc_D,
		exc_A => exc_A,
		exc_C => exc_C,
		conflict => conflict_D,
		reg_PC_reset => reset_PC,
		reg_F_D_reset => reg_F_D_reset_DU,
		reg_D_A_reset => reg_D_A_reset_DU,
		reg_A_C_reset => reg_A_C_reset_DU,
		reg_PC_we => load_PC,
		reg_F_D_we => reg_F_D_we,
		reg_D_A_we => reg_D_A_we,
		reg_A_C_we => reg_A_C_we,
		rob_count => rob_count_DU,
		rob_rollback => rob_rollback_DU
	);

	BP : bypass_unit PORT MAP(
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		inm_src2_v_D => inm_src2_v_D,
		reg_dest_A => reg_dest_A,
		reg_we_A => reg_we_A,
		reg_dest_C => reg_dest_C,
		reg_we_C => reg_we_C,
		reg_dest_M5 => reg_dest_M5,
		reg_we_M5 => reg_we_M5,
		reg_src1_D_p_ROB => reg_src1_D_p_ROB,
		reg_src1_D_inst_type_ROB => reg_src1_D_inst_type_ROB,
		reg_src2_D_p_ROB => reg_src2_D_p_ROB,
		reg_src2_D_inst_type_ROB => reg_src2_D_inst_type_ROB,
		mux_src1_D_BP => mux_src1_D_BP_ctrl,
		mux_src2_D_BP => mux_src2_D_BP_ctrl,
		mux_mem_data_D_BP => mux_mem_data_D_BP_ctrl,
		mux_mem_data_A_BP => mux_mem_data_A_BP_ctrl
	);

	----------------------------- Fetch -------------------------------

	reg_pc: pc PORT MAP(
		clk => clk,
		reset => reset_PC,
		addr_jump => jump_addr_A,
		branch_taken => branch_taken_A,
		exception_addr => pc_ROB,
		exception => exc_ROB_validated,
		iret => iret_A,
		load_PC => load_PC,
		pc => pc_F,
		error_detected => error_detected,
		recovery_pc => pc_ROB,
		new_recovery_pc => new_recovery_pc,
		branch_was_taken => branch_was_taken
	);

	priv_status : reg_priv_status PORT MAP(
		clk => clk,
		reset => reset,
		exc_W => exc_ROB_validated,
		iret_A => iret_A,
		priv_status => priv_status_F
	);

	f: fetch PORT MAP(
		clk => clk,
		reset => reset,
		priv_status_r => priv_status_F,
		priv_status_w => priv_status_C,
		pc => pc_F,
		branch_taken => branch_taken_A,
		inst => inst_F,
		inst_v => inst_v_F,
		invalid_access => invalid_access_F,
		mem_req => mem_req_F,
		mem_addr => mem_addr_F,
		mem_done => mem_done_F,
		mem_data_in => mem_data_in_F
	);

	reg_F_D_reset <= reg_F_D_reset_DU OR exc_F_E OR error_detected;

	reg_F_D: reg_FD PORT MAP(
		clk => clk,
		reset => reg_F_D_reset,
		we => reg_F_D_we,
		inst_v_in => inst_v_F,
		inst_in => inst_F,
		inst_v_out => inst_v_D,
		inst_out => inst_D
	);

	reg_status_F_D: reg_status PORT MAP(
		clk => clk,
		reset => reg_F_D_reset_DU,
		we => reg_F_D_we,
		pc_in => pc_F,
		priv_status_in => priv_status_F,
		exc_new => exc_F_E,
		exc_code_new => exc_code_F_E,
		exc_data_new => exc_data_F_E,
		exc_old => '0',
		exc_code_old => (OTHERS => 'X'),
		exc_data_old => (OTHERS => 'X'),
		rob_idx_in => rob_idx_F,
		inst_type_in => INST_TYPE_NOP,
		pc_out => pc_D,
		priv_status_out => priv_status_D,
		exc_out => exc_D,
		exc_code_out => exc_code_D,
		exc_data_out => exc_data_D,
		rob_idx_out => rob_idx_D,
		inst_type_out => open
	);

	----------------------------- Decode -------------------------------


	d: decode PORT MAP(
		inst => inst_D,
		inst_v => inst_v_D,
		pc => pc_D,
		priv_status => priv_status_D,
		inst_type => inst_type_D,
		op_code => op_code_D,
		reg_src1 => reg_src1_D,
		reg_src2 => reg_src2_D,
		reg_dest => reg_dest_D,
		inm_ext => inm_ext_D,
		ALU_ctrl => ALU_ctrl_D,
		branch => branch_D,
		branch_if_eq => branch_if_eq_D,
		jump => jump_D,
		reg_src1_v => reg_src1_v_D,
		reg_src2_v => reg_src2_v_D,
		inm_src2_v => inm_src2_v_D,
		mem_write => mem_we_D,
		byte => byte_D,
		mem_read => mem_read_D,
		reg_we => reg_we_D,
		iret => iret_D,
		invalid_inst => invalid_inst_D
	);


	rb: reg_bank PORT MAP(
		clk => clk,
		reset => reset,
		debug_dump => debug_dump_ROB,
		src1 => reg_src1_D,
		src2 => reg_src2_D,
		data1 => reg_data1_D,
		data2 => reg_data2_D,
		we => reg_we_ROB_validated,
		dest => reg_dest_ROB,
		data_in => reg_data_ROB,
		exception => exc_ROB_validated,
		exc_code => exc_code_ROB,
		exc_data => exc_data_ROB
	);

	mux_src1_D_BP : mux8_32bits PORT MAP(
		Din0 => reg_data1_D,
		Din1 => ALU_out_A,
		Din2 => reg_data_C,
		Din3 => mul_out_M5,
		Din4 => reg_src1_D_data_ROB,
		Din5 => (OTHERS => '0'),
		Din6 => (OTHERS => '0'),
		Din7 => (OTHERS => '0'),
		ctrl => mux_src1_D_BP_ctrl,
		Dout => data1_BP_D
	);

	mux_src2_D_BP : mux8_32bits PORT MAP(
		Din0 => reg_data2_D,
		Din1 => ALU_out_A,
		Din2 => reg_data_C,
		Din3 => mul_out_M5,
		Din4 => reg_src2_D_data_ROB,
		Din5 => (OTHERS => '0'),
		Din6 => (OTHERS => '0'),
		Din7 => (OTHERS => '0'),
		ctrl => mux_src2_D_BP_ctrl,
		Dout => data2_BP_D
	);

	mux_mem_data_D_BP : mux8_32bits PORT MAP(
		Din0 => reg_data2_D,
		Din1 => ALU_out_A,
		Din2 => reg_data_C,
		Din3 => mul_out_M5,
		Din4 => reg_src2_D_data_ROB,
		Din5 => (OTHERS => '0'),
		Din6 => (OTHERS => '0'),
		Din7 => (OTHERS => '0'),
		ctrl => mux_mem_data_D_BP_ctrl,
		Dout => mem_data_D_BP
	);

	reg_D_A_reset <= reg_D_A_reset_DU OR exc_D_E OR error_detected;

	reg_D_A: reg_DA PORT MAP(
		clk => clk,
		reset => reg_D_A_reset,
		we => reg_D_A_we,
		mem_we_in => mem_we_D,
		byte_in => byte_D,
		mem_read_in => mem_read_D,
		reg_we_in => reg_we_D,
		branch_in => branch_D,
		branch_if_eq_in => branch_if_eq_D,
		jump_in => jump_D,
		inm_ext_in => inm_ext_D,
		ALU_ctrl_in => ALU_ctrl_D,
		reg_src1_v_in => reg_src1_v_D,
		reg_src2_v_in => reg_src2_v_D,
		inm_src2_v_in => inm_src2_v_D,
		reg_src1_in => reg_src1_D,
		reg_src2_in => reg_src2_D,
		reg_dest_in => reg_dest_D,
		reg_data1_in => data1_BP_D,
		reg_data2_in => data2_BP_D,
		mem_data_in => mem_data_D_BP,
		iret_in => iret_D,
		mem_we_out => mem_we_A,
		byte_out => byte_A,
		mem_read_out => mem_read_A,
		reg_we_out => reg_we_A,
		branch_out => branch_A,
		branch_if_eq_out => branch_if_eq_A,
		jump_out => jump_A,
		inm_ext_out => inm_ext_A,
		ALU_ctrl_out => ALU_ctrl_A,
		reg_src1_v_out => reg_src1_v_A,
		reg_src2_v_out => reg_src2_v_A,
		inm_src2_v_out => inm_src2_v_A,
		reg_src1_out => reg_src1_A,
		reg_src2_out => reg_src2_A,
		reg_dest_out => reg_dest_A,
		reg_data1_out => reg_data1_A,
		reg_data2_out => reg_data2_A,
		mem_data_out => mem_data_A,
		iret_out => iret_A
	);

	reg_status_D_A: reg_status PORT MAP(
		clk => clk,
		reset => reg_D_A_reset_DU,
		we => reg_D_A_we,
		pc_in => pc_D,
		priv_status_in => priv_status_D,
		exc_new => exc_D_E,
		exc_code_new => exc_code_D_E,
		exc_data_new => exc_data_D_E,
		exc_old => exc_D,
		exc_code_old => exc_code_D,
		exc_data_old => exc_data_D,
		rob_idx_in => rob_idx_D,
		inst_type_in => inst_type_D,
		pc_out => pc_A,
		priv_status_out => priv_status_A,
		exc_out => exc_A,
		exc_code_out => exc_code_A,
		exc_data_out => exc_data_A,
		rob_idx_out => rob_idx_A,
		inst_type_out => inst_type_A
	);

	--------------------------------- Execution ------------------------------------------

	jump_or_branch_A <= branch_A OR jump_A;

	mux_src1_A: mux2_32bits PORT MAP(
		DIn0 => reg_data1_A,
		Din1 => pc_A,
		ctrl => jump_or_branch_A,
		Dout => ALU_data1_A
	);

	mux_src2_A: mux2_32bits PORT MAP(
		DIn0 => reg_data2_A,
		Din1 => inm_ext_A,
		ctrl => inm_src2_v_A,
		Dout => ALU_data2_A
	);

	-- Z = '1' when operands equal
	Z <= to_std_logic(reg_data1_A = reg_data2_A);
	branch_taken_A <= (to_std_logic(Z = branch_if_eq_A) AND branch_A) OR jump_A OR iret_A;

	ALU_MIPs: ALU PORT MAP(
		DA => ALU_data1_A,
		DB => ALU_data2_A,
		ALUctrl => ALU_ctrl_A,
		Dout => ALU_out_A
	);

	jump_addr_A <= ALU_out_A;

	mux_mem_data_A_BP : mux4_32bits PORT MAP(
		Din0 => mem_data_A,
		Din1 => reg_data_C,
		Din2 => (OTHERS => '0'),
		DIn3 => mul_out_M5,
		ctrl => mux_mem_data_A_BP_ctrl,
		Dout => mem_data_A_BP
	);

	reg_A_C_reset <= reg_A_C_reset_DU OR exc_A_E OR error_detected;

	reg_A_C : reg_AC PORT MAP(
		clk => clk,
		reset => reg_A_C_reset,
		we => reg_A_C_we,
		mem_we_in => mem_we_A,
		byte_in => byte_A,
		mem_read_in => mem_read_A,
		reg_we_in => reg_we_A,
		reg_dest_in => reg_dest_A,
		ALU_out_in => ALU_out_A,
		mem_data_in => mem_data_A_BP,
		mem_we_out => cache_we_C,
		byte_out => byte_C,
		mem_read_out => cache_re_C,
		reg_we_out => reg_we_C,
		reg_dest_out => reg_dest_C,
		ALU_out_out => ALU_out_C,
		mem_data_out => cache_data_in_C
	);

	reg_status_A_C: reg_status PORT MAP(
		clk => clk,
		reset => reg_A_C_reset_DU,
		we => reg_A_C_we,
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A,
		inst_type_in => inst_type_A,
		pc_out => pc_C,
		priv_status_out => priv_status_C,
		exc_out => exc_C,
		exc_code_out => exc_code_C,
		exc_data_out => exc_data_C,
		rob_idx_out => rob_idx_C,
		inst_type_out => inst_type_C
	);

	-------------------------------- ALU Pipeline -----------------------------------------

	-- We might get an exception from F. Therefor, we still don't know the type of instruction
	reg_W_ALU_reset <= reset OR NOT (to_std_logic(inst_type_A = INST_TYPE_ALU) OR (to_std_logic(inst_type_A = INST_TYPE_NOP) AND exc_A)) OR error_detected;

	reg_W_ALU : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_ALU_reset,
		we => '1',
		reg_we_in => reg_we_A,
		reg_dest_in => reg_dest_A,
		reg_data_in => ALU_out_A,
		mem_we_in => '0',
		branch_taken_in => branch_taken_A,
		v => v_W_ALU,
		reg_we_out => reg_we_W_ALU,
		reg_dest_out => reg_dest_W_ALU,
		reg_data_out => reg_data_W_ALU,
		mem_we_out => open,
		branch_taken_out => branch_taken_W_ALU
	);

	reg_status_W_ALU: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_ALU_reset,
		we => '1',
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A,
		inst_type_in => inst_type_A,
		pc_out => pc_W_ALU,
		priv_status_out => open,
		exc_out => exc_W_ALU,
		exc_code_out => exc_code_W_ALU,
		exc_data_out => exc_data_W_ALU,
		rob_idx_out => rob_idx_W_ALU,
		inst_type_out => inst_type_W_ALU
	);

	-------------------------------- Mul Pipeline -----------------------------------------

	mul_M1 <= to_std_logic(inst_type_A = INST_TYPE_MUL);

	Mul_pipeline_reset <= reset OR error_detected;

	Mul_pipeline: ALU_MUL_seg PORT MAP(
		clk => clk,
		reset => Mul_pipeline_reset,
		load => mul_M1,
		done_C => done_C,
		DA => reg_data1_A,
		DB => reg_data2_A,
		reg_dest_in => reg_dest_A,
		reg_we_in => reg_we_A,
		M2_mul => mul_M2,
		reg_dest_M2 => reg_dest_M2,
		M3_mul => mul_M3,
		reg_dest_M3 => reg_dest_M3,
		M4_mul => mul_M4,
		reg_dest_M4 => reg_dest_M4,
		M5_mul => mul_M5,
		reg_dest_out => reg_dest_M5,
		reg_we_out => reg_we_M5,
		Dout => mul_out_M5,
		-- Reg Status signals --
		pc_in => pc_A,
		priv_status_in => priv_status_A,
		exc_new => exc_A_E,
		exc_code_new => exc_code_A_E,
		exc_data_new => exc_data_A_E,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A,
		inst_type_in => inst_type_A,
		pc_out => pc_M5,
		priv_status_out => priv_status_M5,
		exc_out => exc_M5,
		exc_code_out => exc_code_M5,
		exc_data_out => exc_data_M5,
		rob_idx_out => rob_idx_M5,
		inst_type_out => inst_type_M5
	);

	reg_W_MUL_reset <= reset OR to_std_logic(inst_type_M5 /= INST_TYPE_MUL) OR NOT mul_M5 OR error_detected;

	reg_W_MUL : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_MUL_reset,
		we => '1',
		reg_we_in => reg_we_M5,
		reg_dest_in => reg_dest_M5,
		reg_data_in => mul_out_M5,
		mem_we_in => '0',
		branch_taken_in => '0',
		v => v_W_MUL,
		reg_we_out => reg_we_W_MUL,
		reg_dest_out => reg_dest_W_MUL,
		reg_data_out => reg_data_W_MUL,
		mem_we_out => open,
		branch_taken_out => open
	);

	reg_status_W_MUL: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_MUL_reset,
		we => '1',
		pc_in => pc_M5,
		priv_status_in => priv_status_M5,
		exc_new => '0',
		exc_code_new => (OTHERS => '0'),
		exc_data_new => (OTHERS => '0'),
		exc_old => exc_M5,
		exc_code_old => exc_code_M5,
		exc_data_old => exc_data_M5,
		rob_idx_in => rob_idx_M5,
		inst_type_in => inst_type_M5,
		pc_out => pc_W_MUL,
		priv_status_out => open,
		exc_out => exc_W_MUL,
		exc_code_out => exc_code_W_MUL,
		exc_data_out => exc_data_W_MUL,
		rob_idx_out => rob_idx_W_MUL,
		inst_type_out => inst_type_W_MUL
	);

	-------------------------------- Cache  ----------------------------------------------

	cache : cache_stage PORT MAP(
		clk => clk,
		reset => reset,
		priv_status => priv_status_C,
		addr => ALU_out_C,
		data_in => cache_data_in_C,
		data_out => reg_data_C,
		re => cache_re_C,
		we => cache_we_C,
		is_byte => byte_C,
		id => rob_idx_C,
		done => done_C,
		invalid_access => invalid_access_C,
		mem_req => mem_req_C,
		mem_addr => mem_addr_C,
		mem_we => mem_we_C,
		mem_done => mem_done_C,
		mem_data_in => mem_data_in_C,
		mem_data_out => mem_data_out_C,
		sb_store_id => sb_store_id_C,
		sb_store_commit => sb_store_commit_C,
		sb_squash => sb_squash_C,
		sb_error_detected => error_detected
	);

	reg_W_MEM_reset <= reset OR to_std_logic(inst_type_C /= INST_TYPE_MEM) OR NOT done_C OR error_detected;

	reg_W_MEM : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_MEM_reset,
		we => '1',
		reg_we_in => reg_we_C,
		reg_dest_in => reg_dest_C,
		reg_data_in => reg_data_C,
		mem_we_in => cache_we_C,
		branch_taken_in => '0',
		v => v_W_MEM,
		reg_we_out => reg_we_W_MEM,
		reg_dest_out => reg_dest_W_MEM,
		reg_data_out => reg_data_W_MEM,
		mem_we_out => mem_we_W_MEM,
		branch_taken_out => open
	);

	reg_status_W_MEM: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_MEM_reset,
		we => '1',
		pc_in => pc_C,
		priv_status_in => priv_status_C,
		exc_new => exc_C_E,
		exc_code_new => exc_code_C_E,
		exc_data_new => exc_data_C_E,
		exc_old => exc_C,
		exc_code_old => exc_code_C,
		exc_data_old => exc_data_C,
		rob_idx_in => rob_idx_C,
		inst_type_in => inst_type_C,
		pc_out => pc_W_MEM,
		priv_status_out => open,
		exc_out => exc_W_MEM,
		exc_code_out => exc_code_W_MEM,
		exc_data_out => exc_data_W_MEM,
		rob_idx_out => rob_idx_W_MEM,
		inst_type_out => inst_type_W_MEM
	);

	---------------------------- Reorder Buffer --------------------------------

	rob : reorder_buffer PORT MAP(
		clk => clk,
		reset => reset,
		-- Memory
		rob_we_1 => v_W_MEM,
		rob_w_pos_1 => rob_idx_W_MEM,
		reg_v_in_1 => reg_we_W_MEM,
		reg_in_1 => reg_dest_W_MEM,
		reg_data_in_1 => reg_data_W_MEM,
		exc_in_1 => exc_W_MEM,
		exc_code_in_1 => exc_code_W_MEM,
		exc_data_in_1 => exc_data_W_MEM,
		pc_in_1 => pc_W_MEM,
		inst_type_1 => INST_TYPE_MEM,
		store_1 => mem_we_W_MEM,
		-- Multiplication
		rob_we_2 => v_W_MUL,
		rob_w_pos_2 => rob_idx_W_MUL,
		reg_v_in_2 => reg_we_W_MUL,
		reg_in_2 => reg_dest_W_MUL,
		reg_data_in_2 => reg_data_W_MUL,
		exc_in_2 => exc_W_MUL,
		exc_code_in_2 => exc_code_W_MUL,
		exc_data_in_2 => exc_data_W_MUL,
		pc_in_2 => pc_W_MUL,
		inst_type_2 => INST_TYPE_MUL,
		-- ALU
		rob_we_3 => v_W_ALU,
		rob_w_pos_3 => rob_idx_W_ALU,
		reg_v_in_3 => reg_we_W_ALU,
		reg_in_3 => reg_dest_W_ALU,
		reg_data_in_3 => reg_data_W_ALU,
		exc_in_3 => exc_W_ALU,
		exc_code_in_3 => exc_code_W_ALU,
		exc_data_in_3 => exc_data_W_ALU,
		pc_in_3 => pc_W_ALU,
		inst_type_3 => INST_TYPE_ALU,
		branch_taken_3 => branch_taken_W_ALU,
		-- Output
		reg_v_out => reg_we_ROB,
		reg_out => reg_dest_ROB,
		reg_data_out => reg_data_ROB,
		exc_out => exc_ROB,
		exc_code_out => exc_code_ROB,
		exc_data_out => exc_data_ROB,
		pc_out => pc_ROB,
		valid_out => valid_ROB,
		-- Counter
		tail_we => rob_count_DU,
		rollback_tail => rob_rollback_DU,
		tail_out => rob_idx_F,
		-- Bypasses
		reg_src1_D_BP => reg_src1_D,
		reg_src1_D_v_BP => reg_src1_v_D,
		reg_src1_D_p_BP => reg_src1_D_p_ROB,
		reg_src1_D_inst_type_BP => reg_src1_D_inst_type_ROB,
		reg_src1_D_data_BP => reg_src1_D_data_ROB,
		reg_src2_D_BP => reg_src2_D,
		reg_src2_D_v_BP => reg_src2_v_D,
		reg_src2_D_p_BP => reg_src2_D_p_ROB,
		reg_src2_D_inst_type_BP => reg_src2_D_inst_type_ROB,
		reg_src2_D_data_BP => reg_src2_D_data_ROB,
		-- Store buffer
		sb_store_id => sb_store_id_C,
		sb_store_commit => sb_store_commit_C,
		sb_squash => sb_squash_C,
		-- Error control
		error_detected => error_detected,
		new_recovery_pc => new_recovery_pc,
		branch_was_taken => branch_was_taken
	);

	debug_dump_ROB <= '0';
	pc_out <= pc_ROB;

	reg_we_ROB_validated <= reg_we_ROB AND NOT error_detected;
	exc_ROB_validated <= exc_ROB AND NOT error_detected;


    -- Secondary redundant pipeline --
    -- This pipeline has the same execution flow as the original one. At the end, when an instruction is about to be commited, it will be compared with the first processor. --
    -- If they are not both equal, the main pipelines' ROB will issue a rollback. --
    -- This pipeline does not access memory or the register bank, it will not send petitions but still receive the data. --
    -- This pipeline also has no PC, fetch or decode stages, it just receives the instruction ready to go into the execution pipeline. --

    -- START 2nd pipeline --

    ----------------------------- Control -------------------------------


	exc_dup : exception_unit PORT MAP(
		invalid_access_F => invalid_access_F,
		mem_addr_F => pc_F,
		invalid_inst_D => invalid_inst_D,
		inst_D => inst_D,
		invalid_access_C => invalid_access_C_dup,
		mem_addr_C => ALU_out_C_dup,
		exc_F => exc_F_E_ghost,
		exc_code_F => exc_code_F_E_ghost,
		exc_data_F => exc_data_F_E_ghost,
		exc_D => exc_D_E_ghost,
		exc_code_D => exc_code_D_E_ghost,
		exc_data_D => exc_data_D_E_ghost,
		exc_A => exc_A_E_dup,
		exc_code_A => exc_code_A_E_dup,
		exc_data_A => exc_data_A_E_dup,
		exc_C => exc_C_E_dup,
		exc_code_C => exc_code_C_E_dup,
		exc_data_C => exc_data_C_E_dup
	);

	DU_dup : detention_unit PORT MAP(
		reset => reset,
		inst_type_D => inst_type_D,
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_dest_D => reg_dest_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		mem_we_D => mem_we_D,
		branch_taken_A => branch_taken_A_dup,
		mul_M1 => mul_M1_dup,
		mul_M2 => mul_M2_dup,
		reg_dest_M2 => reg_dest_M2_dup,
		mul_M3 => mul_M3_dup,
		reg_dest_M3 => reg_dest_M3_dup,
		mul_M4 => mul_M4_dup,
		reg_dest_M4 => reg_dest_M4_dup,
		mul_M5 => mul_M5_dup,
		reg_dest_M5 => reg_dest_M5_dup,
		inst_type_A => inst_type_A_dup,
		reg_dest_A => reg_dest_A_dup,
		reg_we_A => reg_we_A_dup,
		mem_read_A => mem_read_A,
		reg_dest_C => reg_dest_C_dup,
		mem_read_C => cache_re_C_dup,
		done_F => inst_v_F,
		done_C => done_C_dup,
		exc_D => exc_D,
		exc_A => exc_A,
		exc_C => exc_C,
		conflict => conflict_D_dup,
		reg_PC_reset => reset_PC_ghost,
		reg_F_D_reset => reg_F_D_reset_DU_ghost,
		reg_D_A_reset => reg_D_A_reset_DU_ghost,
		reg_A_C_reset => reg_A_C_reset_DU_dup,
		reg_PC_we => load_PC_ghost,
		reg_F_D_we => reg_F_D_we_ghost,
		reg_D_A_we => reg_D_A_we_ghost,
		reg_A_C_we => reg_A_C_we_dup,
		rob_count => rob_count_DU_dup,
		rob_rollback => rob_rollback_DU_dup
	);

	BP_dup : bypass_unit PORT MAP(
		reg_src1_D => reg_src1_D,
		reg_src2_D => reg_src2_D,
		reg_src1_v_D => reg_src1_v_D,
		reg_src2_v_D => reg_src2_v_D,
		inm_src2_v_D => inm_src2_v_D,
		reg_dest_A => reg_dest_A_dup,
		reg_we_A => reg_we_A_dup,
		reg_dest_C => reg_dest_C_dup,
		reg_we_C => reg_we_C_dup,
		reg_dest_M5 => reg_dest_M5_dup,
		reg_we_M5 => reg_we_M5_dup,
		reg_src1_D_p_ROB => reg_src1_D_p_ROB_dup,
		reg_src1_D_inst_type_ROB => reg_src1_D_inst_type_ROB_dup,
		reg_src2_D_p_ROB => reg_src2_D_p_ROB_dup,
		reg_src2_D_inst_type_ROB => reg_src2_D_inst_type_ROB_dup,
		mux_src1_D_BP => mux_src1_D_BP_ctrl_dup,
		mux_src2_D_BP => mux_src2_D_BP_ctrl_dup,
		mux_mem_data_D_BP => mux_mem_data_D_BP_ctrl_dup,
		mux_mem_data_A_BP => mux_mem_data_A_BP_ctrl_dup
	);

	--------------------------------- Execution ------------------------------------------

	-- Tamper the original decode signals and add some errors if the generator feels like it --
	branch_A_dup <= branch_A xor branch_A_err;
	jump_A_dup <= jump_A xor jump_A_err;
	reg_data1_A_dup(31) <= reg_data1_A(31) xor reg_data1_A_err;
	reg_data1_A_dup(30 DOWNTO 0) <= reg_data1_A(30 DOWNTO 0);
	pc_A_dup(31) <= pc_A(31) xor pc_A_err;
	pc_A_dup(30 DOWNTO 0) <= pc_A(30 DOWNTO 0);
	reg_data2_A_dup(31) <= reg_data2_A(31) xor reg_data2_A_err;
	reg_data2_A_dup(30 DOWNTO 0) <= reg_data2_A(30 DOWNTO 0);
	inm_ext_A_dup(31) <= inm_ext_A(31) xor inm_ext_A_err;
	inm_ext_A_dup(30 DOWNTO 0) <= inm_ext_A(30 DOWNTO 0);
	inm_src2_v_A_dup <= inm_src2_v_A xor inm_src2_v_A_err;
	branch_if_eq_A_dup <= branch_if_eq_A xor branch_if_eq_A_err;
	ALU_ctrl_A_dup(2) <= ALU_ctrl_A(2) xor ALU_ctrl_A_err;
	ALU_ctrl_A_dup(1 DOWNTO 0) <= ALU_ctrl_A(1 DOWNTO 0);
	mem_data_A_dup(31) <= mem_data_A(31) xor mem_data_A_err;
	mem_data_A_dup(30 DOWNTO 0) <= mem_data_A(30 DOWNTO 0);
	mem_we_A_dup <= mem_we_A xor mem_we_A_err;
	byte_A_dup <= byte_A xor byte_A_err;
	mem_read_A_dup <= mem_read_A xor mem_read_A;
	reg_we_A_dup <= reg_we_A xor reg_we_A_err;
	reg_dest_A_dup(4) <= reg_dest_A(4) xor reg_dest_A_err;
	reg_dest_A_dup(3 DOWNTO 0) <= reg_dest_A(3 DOWNTO 0);
	priv_status_A_dup <= priv_status_A xor priv_status_A_err;
	rob_idx_A_dup(3) <= rob_idx_A(3) xor rob_idx_A_err;
	rob_idx_A_dup(2 DOWNTO 0) <= rob_idx_A(2 DOWNTO 0);
	inst_type_A_dup(1) <= inst_type_A(1) xor inst_type_A_err;
	inst_type_A_dup(0) <= inst_type_A(0);
	iret_A_dup <= iret_A xor iret_A_err;



	jump_or_branch_A_dup <= branch_A_dup OR jump_A_dup;


	mux_src1_A_dup: mux2_32bits PORT MAP(
		DIn0 => reg_data1_A_dup,
		Din1 => pc_A_dup,
		ctrl => jump_or_branch_A_dup,
		Dout => ALU_data1_A_dup
	);


	mux_src2_A_dup: mux2_32bits PORT MAP(
		DIn0 => reg_data2_A_dup,
		Din1 => inm_ext_A_dup,
		ctrl => inm_src2_v_A_dup,
		Dout => ALU_data2_A_dup
	);


	-- Z = '1' when operands equal
	Z_dup <= to_std_logic(reg_data1_A_dup = reg_data2_A_dup);
	branch_taken_A_dup <= (to_std_logic(Z_dup = branch_if_eq_A_dup) AND branch_A_dup) OR jump_A_dup OR iret_A_dup;


	ALU_MIPs_dup: ALU PORT MAP(
		DA => ALU_data1_A_dup,
		DB => ALU_data2_A_dup,
		ALUctrl => ALU_ctrl_A_dup,
		Dout => ALU_out_A_dup
	);

	jump_addr_A_ghost <= ALU_out_A_dup;


	mux_mem_data_A_BP_dup : mux4_32bits PORT MAP(
		Din0 => mem_data_A_dup,
		Din1 => reg_data_C_dup,
		Din2 => (OTHERS => '0'),
		DIn3 => mul_out_M5_dup,
		ctrl => mux_mem_data_A_BP_ctrl_dup,
		Dout => mem_data_A_BP_dup
	);

	reg_A_C_reset_dup <= reg_A_C_reset_DU_dup OR exc_A_E OR error_detected;


	reg_A_C_dup : reg_AC PORT MAP(
		clk => clk,
		reset => reg_A_C_reset_dup,
		we => reg_A_C_we_dup,
		mem_we_in => mem_we_A_dup,
		byte_in => byte_A_dup,
		mem_read_in => mem_read_A_dup,
		reg_we_in => reg_we_A_dup,
		reg_dest_in => reg_dest_A_dup,
		ALU_out_in => ALU_out_A_dup,
		mem_data_in => mem_data_A_BP_dup,
		mem_we_out => cache_we_C_clean,
		byte_out => byte_C_clean,
		mem_read_out => cache_re_C_clean,
		reg_we_out => reg_we_C_clean,
		reg_dest_out => reg_dest_C_clean,
		ALU_out_out => ALU_out_C_clean,
		mem_data_out => cache_data_in_C_clean
	);


	reg_status_A_C_dup: reg_status PORT MAP(
		clk => clk,
		reset => reg_A_C_reset_DU_dup,
		we => reg_A_C_we_dup,
		pc_in => pc_A_dup,
		priv_status_in => priv_status_A_dup,
		exc_new => exc_A_E_dup,
		exc_code_new => exc_code_A_E_dup,
		exc_data_new => exc_data_A_E_dup,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A_dup,
		inst_type_in => inst_type_A_dup,
		pc_out => pc_C_clean,
		priv_status_out => priv_status_C_clean,
		exc_out => exc_C_dup,
		exc_code_out => exc_code_C_dup,
		exc_data_out => exc_data_C_dup,
		rob_idx_out => rob_idx_C_clean,
		inst_type_out => inst_type_C_clean
	);

        -- Inject errors to AC register outputs here --

	cache_we_C_dup <= cache_we_C_clean xor cache_we_C_err;
	cache_re_C_dup <= cache_re_C_clean xor cache_re_C_err;
	byte_C_dup <= byte_C_clean xor byte_C_err;
	reg_we_C_dup <= reg_we_C_clean xor reg_we_C_err;
	priv_status_C_dup <= priv_status_C_clean xor priv_status_C_err;
	inst_type_C_dup(1) <= inst_type_C_clean(1) xor inst_type_C_err;
	inst_type_C_dup(0) <= inst_type_C_clean(0);
	rob_idx_C_dup(3) <= rob_idx_C_clean(3) xor rob_idx_C_err;
	rob_idx_C_dup(2 DOWNTO 0) <= rob_idx_C_clean(2 DOWNTO 0);
	reg_dest_C_dup(4) <= reg_dest_C_clean(4) xor reg_dest_C_err;
	reg_dest_C_dup(3 DOWNTO 0) <= reg_dest_C_clean(3 DOWNTO 0);
	pc_C_dup(31) <= pc_C_clean(31) xor pc_C_err;
	pc_C_dup(30 DOWNTO 0) <= pc_C_clean(30 DOWNTO 0);
	ALU_out_C_dup(31) <= ALU_out_C_clean(31) xor ALU_out_C_err;
	ALU_out_C_dup(30 DOWNTO 0) <= ALU_out_C_clean(30 DOWNTO 0);
	cache_data_in_C_dup(31) <= cache_data_in_C_clean(31) xor cache_data_in_C_err;
	cache_data_in_C_dup(30 DOWNTO 0) <= cache_data_in_C_clean(30 DOWNTO 0);


	-------------------------------- ALU Pipeline -----------------------------------------

	-- We might get an exception from F. Therefor, we still don't know the type of instruction
	reg_W_ALU_reset_dup <= reset OR NOT (to_std_logic(inst_type_A_dup = INST_TYPE_ALU) OR (to_std_logic(inst_type_A_dup = INST_TYPE_NOP) AND exc_A)) OR error_detected;

	reg_W_ALU_dup : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_ALU_reset_dup,
		we => '1',
		reg_we_in => reg_we_A_dup,
		reg_dest_in => reg_dest_A_dup,
		reg_data_in => ALU_out_A_dup,
		mem_we_in => '0',
		branch_taken_in => branch_taken_A_dup,
		v => v_W_ALU_clean,
		reg_we_out => reg_we_W_ALU_clean,
		reg_dest_out => reg_dest_W_ALU_clean,
		reg_data_out => reg_data_W_ALU_clean,
		mem_we_out => open,
		branch_taken_out => branch_taken_W_ALU_clean
	);

	reg_status_W_ALU_dup: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_ALU_reset_dup,
		we => '1',
		pc_in => pc_A_dup,
		priv_status_in => priv_status_A_dup,
		exc_new => exc_A_E_dup,
		exc_code_new => exc_code_A_E_dup,
		exc_data_new => exc_data_A_E_dup,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A_dup,
		inst_type_in => inst_type_A_dup,
		pc_out => pc_W_ALU_clean,
		priv_status_out => open,
		exc_out => exc_W_ALU_dup,
		exc_code_out => exc_code_W_ALU_dup,
		exc_data_out => exc_data_W_ALU_dup,
		rob_idx_out => rob_idx_W_ALU_clean,
		inst_type_out => inst_type_W_ALU_clean
	);

	-- Errors from reg_W_ALU to ROB --
	v_W_ALU_dup <= v_W_ALU_clean xor v_W_ALU_err;
 	reg_we_W_ALU_dup <= reg_we_W_ALU_clean xor reg_we_W_ALU_err;
	reg_dest_W_ALU_dup(4) <= reg_dest_W_ALU_clean(4) xor reg_dest_W_ALU_err;
	reg_dest_W_ALU_dup(3 DOWNTO 0) <= reg_dest_W_ALU_clean(3 DOWNTO 0);
	reg_data_W_ALU_dup(31) <= reg_data_W_ALU_clean(31) xor reg_data_W_ALU_err;
	reg_data_W_ALU_dup(30 DOWNTO 0) <= reg_data_W_ALU_clean(30 DOWNTO 0);
	branch_taken_W_ALU_dup <= branch_taken_W_ALU_clean; ----> not muddled (for now)
	pc_W_ALU_dup(31) <= pc_W_ALU_clean(31) xor pc_W_ALU_err;
	pc_W_ALU_dup(30 DOWNTO 0) <= pc_W_ALU_clean(30 DOWNTO 0);
	rob_idx_W_ALU_dup(3) <= rob_idx_W_ALU_clean(3) xor rob_idx_W_ALU_err;
	rob_idx_W_ALU_dup(2 DOWNTO 0) <= rob_idx_W_ALU_clean(2 DOWNTO 0);
	inst_type_W_ALU_dup(1) <= inst_type_W_ALU_clean(1) xor inst_type_W_ALU_err;
	inst_type_W_ALU_dup(0) <= inst_type_W_ALU_clean(0);

	-------------------------------- Mul Pipeline -----------------------------------------

	mul_M1_dup <= to_std_logic(inst_type_A_dup = INST_TYPE_MUL);

	Mul_pipeline_reset_dup <= reset OR error_detected;

	Mul_pipeline_dup: ALU_MUL_seg PORT MAP(
		clk => clk,
		reset => Mul_pipeline_reset_dup,
		load => mul_M1_dup,
		done_C => done_C_dup,
		DA => reg_data1_A_dup,
		DB => reg_data2_A_dup,
		reg_dest_in => reg_dest_A_dup,
		reg_we_in => reg_we_A_dup,
		M2_mul => mul_M2_dup,
		reg_dest_M2 => reg_dest_M2_dup,
		M3_mul => mul_M3_dup,
		reg_dest_M3 => reg_dest_M3_dup,
		M4_mul => mul_M4_dup,
		reg_dest_M4 => reg_dest_M4_dup,
		M5_mul => mul_M5_clean,
		reg_dest_out => reg_dest_M5_clean,
		reg_we_out => reg_we_M5_clean,
		Dout => mul_out_M5_clean,
		-- Reg Status signals --
		pc_in => pc_A_dup,
		priv_status_in => priv_status_A_dup,
		exc_new => exc_A_E_dup,
		exc_code_new => exc_code_A_E_dup,
		exc_data_new => exc_data_A_E_dup,
		exc_old => exc_A,
		exc_code_old => exc_code_A,
		exc_data_old => exc_data_A,
		rob_idx_in => rob_idx_A_dup,
		inst_type_in => inst_type_A_dup,
		pc_out => pc_M5_clean,
		priv_status_out => priv_status_M5_clean,
		exc_out => exc_M5_dup,
		exc_code_out => exc_code_M5_dup,
		exc_data_out => exc_data_M5_dup,
		rob_idx_out => rob_idx_M5_clean,
		inst_type_out => inst_type_M5_clean
	);

	-- Inject errors to the output of the last MUL register, M5 --
	mul_M5_dup <= mul_M5_clean xor mul_M5_err; 
	mul_out_M5_dup(31) <= mul_out_M5_clean(31) xor mul_out_M5_err;
	mul_out_M5_dup(30 DOWNTO 0) <= mul_out_M5_clean(30 DOWNTO 0);
	reg_dest_M5_dup(4) <= reg_dest_M5_clean(4) xor reg_dest_M5_err;
	reg_dest_M5_dup(3 DOWNTO 0) <= reg_dest_M5_clean(3 DOWNTO 0); 
	reg_we_M5_dup <= reg_we_M5_clean xor reg_we_M5_err;
	pc_M5_dup(31) <= pc_M5_clean(31) xor pc_M5_err;
	pc_M5_dup(30 DOWNTO 0) <= pc_M5_clean(30 DOWNTO 0);
	priv_status_M5_dup <= priv_status_M5_clean xor priv_status_M5_err;
	rob_idx_M5_dup(3) <= rob_idx_M5_clean(3) xor rob_idx_M5_err;
	rob_idx_M5_dup(2 DOWNTO 0) <= rob_idx_M5_clean(2 DOWNTO 0);
	inst_type_M5_dup(1) <= inst_type_M5_clean(1) xor inst_type_M5_err;
	inst_type_M5_dup(0) <= inst_type_M5_clean(0);


	reg_W_MUL_reset_dup <= reset OR to_std_logic(inst_type_M5_dup /= INST_TYPE_MUL) OR NOT mul_M5_dup OR error_detected;

	reg_W_MUL_dup : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_MUL_reset_dup,
		we => '1',
		reg_we_in => reg_we_M5_dup,
		reg_dest_in => reg_dest_M5_dup,
		reg_data_in => mul_out_M5_dup,
		mem_we_in => '0',
		branch_taken_in => '0',
		v => v_W_MUL_clean,
		reg_we_out => reg_we_W_MUL_clean,
		reg_dest_out => reg_dest_W_MUL_clean,
		reg_data_out => reg_data_W_MUL_clean,
		mem_we_out => open,
		branch_taken_out => open
	);

	reg_status_W_MUL_dup: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_MUL_reset_dup,
		we => '1',
		pc_in => pc_M5_dup,
		priv_status_in => priv_status_M5_dup,
		exc_new => '0',
		exc_code_new => (OTHERS => '0'),
		exc_data_new => (OTHERS => '0'),
		exc_old => exc_M5_dup,
		exc_code_old => exc_code_M5_dup,
		exc_data_old => exc_data_M5_dup,
		rob_idx_in => rob_idx_M5_dup,
		inst_type_in => inst_type_M5_dup,
		pc_out => pc_W_MUL_clean,
		priv_status_out => open,
		exc_out => exc_W_MUL_dup,
		exc_code_out => exc_code_W_MUL_dup,
		exc_data_out => exc_data_W_MUL_dup,
		rob_idx_out => rob_idx_W_MUL_clean,
		inst_type_out => inst_type_W_MUL_clean
	);

	-- Errors from reg_W_MUL to ROB --
	v_W_MUL_dup <= v_W_MUL_clean xor v_W_MUL_err;
 	reg_we_W_MUL_dup <= reg_we_W_MUL_clean xor reg_we_W_MUL_err;
	reg_dest_W_MUL_dup(4) <= reg_dest_W_MUL_clean(4) xor reg_dest_W_MUL_err;
	reg_dest_W_MUL_dup(3 DOWNTO 0) <= reg_dest_W_MUL_clean(3 DOWNTO 0);
	reg_data_W_MUL_dup(31) <= reg_data_W_MUL_clean(31) xor reg_data_W_MUL_err;
	reg_data_W_MUL_dup(30 DOWNTO 0) <= reg_data_W_MUL_clean(30 DOWNTO 0);
	pc_W_MUL_dup(31) <= pc_W_MUL_clean(31) xor pc_W_MUL_err;
	pc_W_MUL_dup(30 DOWNTO 0) <= pc_W_MUL_clean(30 DOWNTO 0);
	rob_idx_W_MUL_dup(3) <= rob_idx_W_MUL_clean(3) xor rob_idx_W_MUL_err;
	rob_idx_W_MUL_dup(2 DOWNTO 0) <= rob_idx_W_MUL_clean(2 DOWNTO 0);
	inst_type_W_MUL_dup(1) <= inst_type_W_MUL_clean(1) xor inst_type_W_MUL_err;
	inst_type_W_MUL_dup(0) <= inst_type_W_MUL_clean(0);

	-------------------------------- Cache  ----------------------------------------------

	cache_dup : cache_stage PORT MAP(
		clk => clk,
		reset => reset,
		priv_status => priv_status_C_dup,
		addr => ALU_out_C_dup,
		data_in => cache_data_in_C_dup,
		data_out => reg_data_C_dup,
		re => cache_re_C_dup,
		we => cache_we_C_dup,
		is_byte => byte_C_dup,
		id => rob_idx_C_dup,
		done => done_C_dup,
		invalid_access => invalid_access_C_dup,
		mem_req => mem_req_C_ghost,
		mem_addr => mem_addr_C_ghost,
		mem_we => mem_we_C_ghost,
		mem_done => mem_done_C,
		mem_data_in => mem_data_in_C,
		mem_data_out => mem_data_out_C_ghost,
		sb_store_id => sb_store_id_C_dup,
		sb_store_commit => sb_store_commit_C_dup,
		sb_squash => sb_squash_C_dup,
		sb_error_detected => error_detected
	);

	reg_W_MEM_reset_dup <= reset OR to_std_logic(inst_type_C_dup /= INST_TYPE_MEM) OR NOT done_C_dup OR error_detected;

	reg_W_MEM_dup : reg_W PORT MAP (
		clk => clk,
		reset => reg_W_MEM_reset_dup,
		we => '1',
		reg_we_in => reg_we_C_dup,
		reg_dest_in => reg_dest_C_dup,
		reg_data_in => reg_data_C_dup,
		mem_we_in => cache_we_C_dup,
		branch_taken_in => '0',
		v => v_W_MEM_clean,
		reg_we_out => reg_we_W_MEM_clean,
		reg_dest_out => reg_dest_W_MEM_clean,
		reg_data_out => reg_data_W_MEM_clean,
		mem_we_out => mem_we_W_MEM_clean,
		branch_taken_out => open
	);

	reg_status_W_MEM_dup: reg_status PORT MAP(
		clk => clk,
		reset => reg_W_MEM_reset_dup,
		we => '1',
		pc_in => pc_C_dup,
		priv_status_in => priv_status_C_dup,
		exc_new => exc_C_E_dup,
		exc_code_new => exc_code_C_E_dup,
		exc_data_new => exc_data_C_E_dup,
		exc_old => exc_C_dup,
		exc_code_old => exc_code_C_dup,
		exc_data_old => exc_data_C_dup,
		rob_idx_in => rob_idx_C_dup,
		inst_type_in => inst_type_C_dup,
		pc_out => pc_W_MEM_clean,
		priv_status_out => open,
		exc_out => exc_W_MEM_dup,
		exc_code_out => exc_code_W_MEM_dup,
		exc_data_out => exc_data_W_MEM_dup,
		rob_idx_out => rob_idx_W_MEM_clean,
		inst_type_out => inst_type_W_MEM_clean
	);
    
    
    -- Errors from reg_W_MEM to ROB --
	v_W_MEM_dup <= v_W_MEM_clean xor v_W_MEM_err;
 	reg_we_W_MEM_dup <= reg_we_W_MEM_clean xor reg_we_W_MEM_err;
	reg_dest_W_MEM_dup(4) <= reg_dest_W_MEM_clean(4) xor reg_dest_W_MEM_err;
	reg_dest_W_MEM_dup(3 DOWNTO 0) <= reg_dest_W_MEM_clean(3 DOWNTO 0);
	reg_data_W_MEM_dup(31) <= reg_data_W_MEM_clean(31) xor reg_data_W_MEM_err;
	reg_data_W_MEM_dup(30 DOWNTO 0) <= reg_data_W_MEM_clean(30 DOWNTO 0);
    	mem_we_W_MEM_dup <= mem_we_W_MEM_clean xor mem_we_W_MEM_err;
	pc_W_MEM_dup(31) <= pc_W_MEM_clean(31) xor pc_W_MEM_err;
	pc_W_MEM_dup(30 DOWNTO 0) <= pc_W_MEM_clean(30 DOWNTO 0);
	rob_idx_W_MEM_dup(3) <= rob_idx_W_MEM_clean(3) xor rob_idx_W_MEM_err;
	rob_idx_W_MEM_dup(2 DOWNTO 0) <= rob_idx_W_MEM_clean(2 DOWNTO 0);
	inst_type_W_MEM_dup(1) <= inst_type_W_MEM_clean(1) xor inst_type_W_MEM_err;
	inst_type_W_MEM_dup(0) <= inst_type_W_MEM_clean(0);

	---------------------------- Reorder Buffer --------------------------------

	rob_dup : reorder_buffer PORT MAP(
		clk => clk,
		reset => reset,
		-- Memory
		rob_we_1 => v_W_MEM_dup,
		rob_w_pos_1 => rob_idx_W_MEM_dup,
		reg_v_in_1 => reg_we_W_MEM_dup,
		reg_in_1 => reg_dest_W_MEM_dup,
		reg_data_in_1 => reg_data_W_MEM_dup,
		exc_in_1 => exc_W_MEM_dup,
		exc_code_in_1 => exc_code_W_MEM_dup,
		exc_data_in_1 => exc_data_W_MEM_dup,
		pc_in_1 => pc_W_MEM_dup,
		inst_type_1 => INST_TYPE_MEM,
		store_1 => mem_we_W_MEM_dup,
		-- Multiplication
		rob_we_2 => v_W_MUL_dup,
		rob_w_pos_2 => rob_idx_W_MUL_dup,
		reg_v_in_2 => reg_we_W_MUL_dup,
		reg_in_2 => reg_dest_W_MUL_dup,
		reg_data_in_2 => reg_data_W_MUL_dup,
		exc_in_2 => exc_W_MUL_dup,
		exc_code_in_2 => exc_code_W_MUL_dup,
		exc_data_in_2 => exc_data_W_MUL_dup,
		pc_in_2 => pc_W_MUL_dup,
		inst_type_2 => INST_TYPE_MUL,
		-- ALU
		rob_we_3 => v_W_ALU_dup,
		rob_w_pos_3 => rob_idx_W_ALU_dup,
		reg_v_in_3 => reg_we_W_ALU_dup,
		reg_in_3 => reg_dest_W_ALU_dup,
		reg_data_in_3 => reg_data_W_ALU_dup,
		exc_in_3 => exc_W_ALU_dup,
		exc_code_in_3 => exc_code_W_ALU_dup,
		exc_data_in_3 => exc_data_W_ALU_dup,
		pc_in_3 => pc_W_ALU_dup,
		inst_type_3 => INST_TYPE_ALU,
		branch_taken_3 => branch_taken_W_ALU_dup,
		-- Output
		reg_v_out => reg_we_ROB_ghost,
		reg_out => reg_dest_ROB_ghost,
		reg_data_out => reg_data_ROB_ghost,
		exc_out => exc_ROB_ghost,
		exc_code_out => exc_code_ROB_ghost,
		exc_data_out => exc_data_ROB_ghost,
		pc_out => pc_ROB_ghost,
		valid_out => valid_ROB_ghost,
		-- Counter
		tail_we => rob_count_DU_dup,
		rollback_tail => rob_rollback_DU_dup,
		tail_out => rob_idx_F,
		-- Bypasses
		reg_src1_D_BP => reg_src1_D,
		reg_src1_D_v_BP => reg_src1_v_D,
		reg_src1_D_p_BP => reg_src1_D_p_ROB_dup,
		reg_src1_D_inst_type_BP => reg_src1_D_inst_type_ROB_dup,
		reg_src1_D_data_BP => reg_src1_D_data_ROB_dup,
		reg_src2_D_BP => reg_src2_D,
		reg_src2_D_v_BP => reg_src2_v_D,
		reg_src2_D_p_BP => reg_src2_D_p_ROB_dup,
		reg_src2_D_inst_type_BP => reg_src2_D_inst_type_ROB_dup,
		reg_src2_D_data_BP => reg_src2_D_data_ROB_dup,
		-- Store buffer
		sb_store_id => sb_store_id_C_dup,
		sb_store_commit => sb_store_commit_C_dup,
		sb_squash => sb_squash_C_dup,
		-- Error control
		error_detected => error_detected,
		new_recovery_pc => new_recovery_pc_ghost, -- should be compared
		branch_was_taken => branch_was_taken_ghost -- should be compared
	);

    -- END 2nd pipeline --

	comparator : output_comparator PORT MAP(
		-- Rob 1 input
		reg_v_1 => reg_we_ROB,
		reg_1 => reg_dest_ROB,
		reg_data_1 => reg_data_ROB,
		exc_1 => exc_ROB,
		exc_code_1 => exc_code_ROB,
		exc_data_1 => exc_data_ROB,
		pc_1 => pc_ROB,
		valid_1 => valid_ROB,
		-- Rob 2 input
		reg_v_2 => reg_we_ROB_ghost,
		reg_2 => reg_dest_ROB_ghost,
		reg_data_2 => reg_data_ROB_ghost,
		exc_2 => exc_ROB_ghost,
		exc_code_2 => exc_code_ROB_ghost,
		exc_data_2 => exc_data_ROB_ghost,
		pc_2 => pc_ROB_ghost,
		valid_2 => valid_ROB_ghost,
		-- ALU 1 input
		jump_addr_A_1 => jump_addr_A,
		branch_taken_A_1 => branch_taken_A,
		-- ALU 2 input
		jump_addr_A_2 => jump_addr_A_ghost,
		branch_taken_A_2 => branch_taken_A_dup,
		-- Cache 1 input
		mem_req_C_1 => mem_req_C,
		mem_we_C_1 => mem_we_C,
		mem_addr_C_1 => mem_addr_C,
		mem_data_out_C_1 => mem_data_out_C,
		-- Cache 2 input
		mem_req_C_2 => mem_req_C_ghost,
		mem_we_C_2 => mem_we_C_ghost,
		mem_addr_C_2 => mem_addr_C_ghost,
		mem_data_out_C_2 => mem_data_out_C_ghost,
		-- Segmentation regs 1 input
		reg_F_D_reset_DU_1 => reg_F_D_reset_DU,
		reg_D_A_reset_DU_1 => reg_D_A_reset_DU,
		reg_F_D_we_1 => reg_F_D_we,
		reg_D_A_we_1 => reg_D_A_we,
		-- Segmentation regs 2 input
		reg_F_D_reset_DU_2 => reg_F_D_reset_DU_ghost,
		reg_D_A_reset_DU_2 => reg_D_A_reset_DU_ghost,
		reg_F_D_we_2 => reg_F_D_we_ghost,
		reg_D_A_we_2 => reg_D_A_we_ghost,
		-- Stall unit 1 input
		load_PC_1 => load_PC,
		reset_PC_1 => reset_PC,
		-- Stall unit 2 input
		load_PC_2 => load_PC_ghost,
		reset_PC_2 => reset_PC_ghost,
		-- Exception unit 1 input
		exc_F_E_1 => exc_F_E,
		exc_D_E_1 => exc_D_E,
		exc_code_F_E_1 => exc_code_F_E,
		exc_code_D_E_1 => exc_code_D_E,
		exc_data_F_E_1 => exc_data_F_E,
		exc_data_D_E_1 => exc_data_D_E,
		-- Exception unit 2 input
		exc_F_E_2 => exc_F_E_ghost,
		exc_D_E_2 => exc_D_E_ghost,
		exc_code_F_E_2 => exc_code_F_E_ghost,
		exc_code_D_E_2 => exc_code_D_E_ghost,
		exc_data_F_E_2 => exc_data_F_E_ghost,
		exc_data_D_E_2 => exc_data_D_E_ghost,
		-- Output
		error_detected => error_detected
	);

	error_gen : error_generator PORT MAP(
		clk => clk,
		reset => reset,
		-- ALU stage --
		branch_A_err => branch_A_err,
		jump_A_err => jump_A_err,
		reg_data1_A_err => reg_data1_A_err,
		pc_A_err => pc_A_err,
		reg_data2_A_err => reg_data2_A_err,
		inm_ext_A_err => inm_ext_A_err,
		inm_src2_v_A_err => inm_src2_v_A_err,
		branch_if_eq_A_err => branch_if_eq_A_err,
		ALU_ctrl_A_err => ALU_ctrl_A_err,
		mem_data_A_err => mem_data_A_err,
		mem_we_A_err => mem_we_A_err,
		byte_A_err => byte_A_err,
		mem_read_A_err => mem_read_A_err,
		reg_we_A_err => reg_we_A_err,
		reg_dest_A_err => reg_dest_A_err,
		priv_status_A_err => priv_status_A_err,
		rob_idx_A_err => rob_idx_A_err,
		inst_type_A_err => inst_type_A_err,
		iret_A_err  => iret_A_err,

    		-- Cache stage --
    		cache_we_C_err => cache_we_C_err,
    		cache_re_C_err => cache_re_C_err,
    		byte_C_err => byte_C_err,
    		reg_we_C_err => reg_we_C_err,
    		priv_status_C_err => priv_status_C_err,
    		inst_type_C_err => inst_type_C_err,
    		rob_idx_C_err => rob_idx_C_err,
    		reg_dest_C_err => reg_dest_C_err,
    		pc_C_err => pc_C_err,
    		ALU_out_C_err => ALU_out_C_err,
    		cache_data_in_C_err => cache_data_in_C_err,

    		-- MUL stage --
    		mul_M5_err => mul_M5_err,
    		mul_out_M5_err => mul_out_M5_err,
    		reg_dest_M5_err => reg_dest_M5_err,
    		reg_we_M5_err => reg_we_M5_err,
    		pc_M5_err => pc_M5_err,
    		priv_status_M5_err => priv_status_M5_err,
    		rob_idx_M5_err => rob_idx_M5_err,
    		inst_type_M5_err => inst_type_M5_err,

    		-- Writeback stage --
    		-- MEM -- 
    		v_W_MEM_err => v_W_MEM_err,
    		reg_we_W_MEM_err => reg_we_W_MEM_err,
    		reg_dest_W_MEM_err => reg_dest_W_MEM_err,
    		reg_data_W_MEM_err => reg_data_W_MEM_err,
    		mem_we_W_MEM_err => mem_we_W_MEM_err,
    		pc_W_MEM_err => pc_W_MEM_err,
    		rob_idx_W_MEM_err => rob_idx_W_MEM_err,
    		inst_type_W_MEM_err => inst_type_W_MEM_err,
    		-- ALU --
    		v_W_ALU_err => v_W_ALU_err,
    		reg_we_W_ALU_err => reg_we_W_ALU_err,
    		reg_dest_W_ALU_err => reg_dest_W_ALU_err,
    		reg_data_W_ALU_err => reg_data_W_ALU_err,
    		pc_W_ALU_err => pc_W_ALU_err,
    		rob_idx_W_ALU_err => rob_idx_W_ALU_err,
    		inst_type_W_ALU_err=> inst_type_W_ALU_err,
    		-- MUL --
    		v_W_MUL_err => v_W_MUL_err,
    		reg_we_W_MUL_err => reg_we_W_MUL_err,
    		reg_dest_W_MUL_err => reg_dest_W_MUL_err,
    		reg_data_W_MUL_err => reg_data_W_MUL_err,
    		pc_W_MUL_err => pc_W_MUL_err,
    		rob_idx_W_MUL_err => rob_idx_W_MUL_err,
    		inst_type_W_MUL_err => inst_type_W_MUL_err
	); 

END structure;

