LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

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

	CONSTANT min_error_cycles : integer := 3;
	CONSTANT max_error_cycles : integer := 6;
	CONSTANT number_of_signals : integer := 19;

	SIGNAL error_clock : integer;
	SIGNAL tick_number : integer;
	SIGNAL signal_number : integer;
	SIGNAL inject_error : STD_LOGIC;


BEGIN

	genRandInt : PROCESS(clk)
	    VARIABLE seed1, seed2 : integer := 42;
	    IMPURE FUNCTION rand_int(min_val, max_val : integer) return integer is
		variable r : real;
	    BEGIN
		uniform(seed1, seed2, r);
		return integer(round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
	    END FUNCTION;
	BEGIN

	-- We need to do something here with the random numbers--
	    IF rising_edge(clk) THEN
		-- If RESET, generate a new countdown value and decide which signal will get the error
		IF reset = '1' THEN
		    error_clock <= 0;
		    tick_number <= rand_int(min_error_cycles, max_error_cycles);
		    signal_number <= rand_int(0, number_of_signals-1);
		    inject_error <= '0';
		-- Before reaching the final countdown value, inject an error in the chosen signal
		ELSIF error_clock = tick_number - 1 THEN
		    inject_error <= '1';
		    error_clock <= error_clock + 1;
		-- After an error is generated, generate a new countdown value and decide which signal will get the next error
		ELSIF error_clock = tick_number THEN
		    error_clock <= 0;
		    tick_number <= rand_int(min_error_cycles, max_error_cycles);
		    signal_number <= rand_int(0, number_of_signals-1);
		    inject_error <= '0';
		-- Increase the counter this cycle, nothing else happens
		ELSE
		    error_clock <= error_clock + 1;
		    inject_error <= '0';
		END IF;
	    END IF;


	END PROCESS genRandInt;


	D_inst_type_err <= '1' WHEN inject_error = '1' AND signal_number = 0 else '0';
	D_op_code_err <= '1' WHEN inject_error = '1' AND signal_number = 1 else '0';
	D_reg_src1_err <= '1' WHEN inject_error = '1' AND signal_number = 2 else '0';
	D_reg_src2_err <= '1' WHEN inject_error = '1' AND signal_number = 3 else '0';
	D_reg_dest_err <= '1' WHEN inject_error = '1' AND signal_number = 4 else '0';
	D_inm_ext_err <= '1' WHEN inject_error = '1' AND signal_number = 5 else '0';
	D_ALU_ctrl_err <= '1' WHEN inject_error = '1' AND signal_number = 6 else '0';
	D_branch_err <= '1' WHEN inject_error = '1' AND signal_number = 7 else '0';
	D_branch_if_eq_err <= '1' WHEN inject_error = '1' AND signal_number = 8 else '0';
	D_jump_err <= '1' WHEN inject_error = '1' AND signal_number = 9 else '0';
	D_reg_src1_v_err <= '1' WHEN inject_error = '1' AND signal_number = 10 else '0';
	D_reg_src2_v_err <= '1' WHEN inject_error = '1' AND signal_number = 11 else '0';
	D_inm_src2_v_err <= '1' WHEN inject_error = '1' AND signal_number = 12 else '0';
	D_mem_write_err <= '1' WHEN inject_error = '1' AND signal_number = 13 else '0';
	D_byte_err <= '1' WHEN inject_error = '1' AND signal_number = 14 else '0';
	D_mem_read_err <= '1' WHEN inject_error = '1' AND signal_number = 15 else '0';
	D_reg_we_err <= '1' WHEN inject_error = '1' AND signal_number = 16 else '0';
	D_iret_err <= '1' WHEN inject_error = '1' AND signal_number = 17 else '0';
	D_invalid_inst_err <= '1' WHEN inject_error = '1' AND signal_number = 18 else '0';


END structure;