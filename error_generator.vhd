LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.math_real.all;

ENTITY error_generator IS 
	PORT(clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		
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
		iret_A_err : OUT STD_LOGIC


	);
END error_generator;

ARCHITECTURE structure OF error_generator IS

	-- Min and max_error_cycles bound the number of cycles until the next error.
	CONSTANT min_error_cycles : integer := 60;
	CONSTANT max_error_cycles : integer := 80;

	-- Number of signals where an error can be injected
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


	branch_A_err <= '1' WHEN inject_error = '1' AND signal_number = 0 else '0';
	jump_A_err <= '1' WHEN inject_error = '1' AND signal_number = 1 else '0';
	reg_data1_A_err <= '1' WHEN inject_error = '1' AND signal_number = 2 else '0';
	pc_A_err <= '1' WHEN inject_error = '1' AND signal_number = 3 else '0';
	reg_data2_A_err <= '1' WHEN inject_error = '1' AND signal_number = 4 else '0';
	inm_ext_A_err <= '1' WHEN inject_error = '1' AND signal_number = 5 else '0';
	inm_src2_v_A_err <= '1' WHEN inject_error = '1' AND signal_number = 6 else '0';
	branch_if_eq_A_err <= '1' WHEN inject_error = '1' AND signal_number = 7 else '0';
	ALU_ctrl_A_err <= '1' WHEN inject_error = '1' AND signal_number = 8 else '0';
	mem_data_A_err <= '1' WHEN inject_error = '1' AND signal_number = 9 else '0';
	mem_we_A_err <= '1' WHEN inject_error = '1' AND signal_number = 10 else '0';
	byte_A_err <= '1' WHEN inject_error = '1' AND signal_number = 11 else '0';
	mem_read_A_err <= '1' WHEN inject_error = '1' AND signal_number = 12 else '0';
	reg_we_A_err <= '1' WHEN inject_error = '1' AND signal_number = 13 else '0';
	reg_dest_A_err <= '1' WHEN inject_error = '1' AND signal_number = 14 else '0';
	priv_status_A_err <= '1' WHEN inject_error = '1' AND signal_number = 15 else '0';
	rob_idx_A_err <= '1' WHEN inject_error = '1' AND signal_number = 16 else '0';
	inst_type_A_err <= '1' WHEN inject_error = '1' AND signal_number = 17 else '0';
	iret_A_err <= '1' WHEN inject_error = '1' AND signal_number = 18 else '0';


END structure;