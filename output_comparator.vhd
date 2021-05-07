library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity output_comparator is
	Port(
		-- Main rob input
		reg_v_1    	: IN STD_LOGIC;
		reg_1      	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_1 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_1      	: IN STD_LOGIC;
		exc_code_1 	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_1 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_1       	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		valid_1		: IN STD_LOGIC;
        sb_store_commit_1 : IN STD_LOGIC;
		-- Dup rob input
		reg_v_2    	: IN STD_LOGIC;
		reg_2      	: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		reg_data_2 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_2      	: IN STD_LOGIC;
		exc_code_2 	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_2 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_2       	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		valid_2		: IN STD_LOGIC;
        sb_store_commit_2 : IN STD_LOGIC;
		
		-- ALU 1 input
		jump_addr_A_1 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		branch_taken_A_1 : IN STD_LOGIC;
		-- ALU 2 input
		jump_addr_A_2 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		branch_taken_A_2 : IN STD_LOGIC;

		-- Cache 1 input
		mem_req_C_1 		: IN STD_LOGIC;
		mem_we_C_1		: IN STD_LOGIC;
		mem_addr_C_1 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out_C_1	: IN STD_LOGIC_VECTOR(127 DOWNTO 0);
		-- Cache 2 input
		mem_req_C_2 		: IN STD_LOGIC;
		mem_we_C_2 		: IN STD_LOGIC;
		mem_addr_C_2 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		mem_data_out_C_2 	: IN STD_LOGIC_VECTOR(127 DOWNTO 0);

		-- Segmentation regs 1 input
		reg_F_D_reset_DU_1	: IN STD_LOGIC;
		reg_D_A_reset_DU_1	: IN STD_LOGIC;
		reg_F_D_we_1		: IN STD_LOGIC;
		reg_D_A_we_1		: IN STD_LOGIC;
		-- Segmentation regs 2 input
		reg_F_D_reset_DU_2	: IN STD_LOGIC;
		reg_D_A_reset_DU_2	: IN STD_LOGIC;
		reg_F_D_we_2		: IN STD_LOGIC;
		reg_D_A_we_2		: IN STD_LOGIC;

		-- Stall unit 1 input
		load_PC_1	: IN STD_LOGIC;
		reset_PC_1	: IN STD_LOGIC;
		-- Stall unit 2 input
		load_PC_2	: IN STD_LOGIC;
		reset_PC_2	: IN STD_LOGIC;

		-- Exception unit 1 input
		exc_F_E_1	: IN STD_LOGIC;
		exc_D_E_1	: IN STD_LOGIC;
		exc_code_F_E_1	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_code_D_E_1	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_F_E_1 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_data_D_E_1 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- Exception unit 2 input
		exc_F_E_2	: IN STD_LOGIC;
		exc_D_E_2	: IN STD_LOGIC;
		exc_code_F_E_2	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_code_D_E_2	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		exc_data_F_E_2 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		exc_data_D_E_2 	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	
		-- Output
		error_detected 	: OUT STD_LOGIC;
        ROB_error_out : OUT STD_LOGIC;
        is_store    : OUT STD_LOGIC
        --commit_verified : OUT STD_LOGIC

	);
end output_comparator;

architecture structure of output_comparator is

	SIGNAL reg_v_equal 		: STD_LOGIC;
	SIGNAL reg_equal 		: STD_LOGIC;
	SIGNAL reg_data_equal 		: STD_LOGIC;
	SIGNAL exc_equal 		: STD_LOGIC;
	SIGNAL exc_code_equal 		: STD_LOGIC;
	SIGNAL exc_data_equal 		: STD_LOGIC;
	SIGNAL pc_equal 		: STD_LOGIC;
	SIGNAL valid_equal		: STD_LOGIC;
    SIGNAL sb_store_commit_equal : STD_LOGIC;
	SIGNAL ROB_equal		: STD_LOGIC;
	SIGNAL ROB_error		: STD_LOGIC;
    SIGNAL MEM_error        : STD_LOGIC;
	SIGNAL jump_addr_A_equal 	: STD_LOGIC;
	SIGNAL branch_taken_A_equal	: STD_LOGIC;
	SIGNAL mem_req_C_equal 		: STD_LOGIC;
	SIGNAL mem_we_C_equal 		: STD_LOGIC;
	SIGNAL mem_addr_C_equal 	: STD_LOGIC;
	SIGNAL mem_data_out_C_equal 	: STD_LOGIC;
	SIGNAL reg_F_D_reset_DU_equal 	: STD_LOGIC;
	SIGNAL reg_D_A_reset_DU_equal 	: STD_LOGIC;
	SIGNAL reg_F_D_we_equal 	: STD_LOGIC;
	SIGNAL reg_D_A_we_equal 	: STD_LOGIC;
	SIGNAL load_PC_equal 		: STD_LOGIC;
	SIGNAL reset_PC_equal 		: STD_LOGIC;
	SIGNAL exc_F_E_equal 		: STD_LOGIC;
	SIGNAL exc_D_E_equal 		: STD_LOGIC;
	SIGNAL exc_code_F_E_equal 	: STD_LOGIC;
	SIGNAL exc_code_D_E_equal 	: STD_LOGIC;
	SIGNAL exc_data_F_E_equal 	: STD_LOGIC;
	SIGNAL exc_data_D_E_equal 	: STD_LOGIC;


begin

	-- ROB comparison

	reg_v_equal <= '1' when reg_v_1 = reg_v_2 else '0';
	reg_equal <= '1' when reg_1 = reg_2 else '0';
	reg_data_equal <= '1' when reg_data_1 = reg_data_2 else '0';
	exc_equal <= '1' when exc_1 = exc_2 else '0';
	exc_code_equal <= '1' when exc_code_1 = exc_code_2 else '0';
	exc_data_equal <= '1' when exc_data_1 = exc_data_2 else '0';
	pc_equal <= '1' when pc_1 = pc_2 else '0';
	valid_equal <= '1' when valid_1 = valid_2 else '0';
    sb_store_commit_equal <= '1' when sb_store_commit_1 = sb_store_commit_2 else '0';


    -- Only check for equal ROB result if the output intends to be valid
	ROB_equal <= reg_v_equal AND reg_equal AND reg_data_equal AND exc_equal AND exc_code_equal AND exc_data_equal AND pc_equal AND sb_store_commit_equal;

	ROB_error <= NOT valid_equal OR (valid_equal AND valid_1 AND NOT ROB_equal);
    ROB_error_out <= ROB_error;
    
    --commit_verified <= NOT ROB_error AND mem_we_C_equal;

	-- ALU comparison

	jump_addr_A_equal <= '1' when jump_addr_A_1 = jump_addr_A_2 else '0';
	branch_taken_A_equal <= '1' when branch_taken_A_1 = branch_taken_A_2 else '0';

	-- Cache comparison

	mem_req_C_equal <= '1' when mem_req_C_1 = mem_req_C_2 else '0'; 		
	mem_we_C_equal <= '1' when mem_we_C_1 = mem_we_C_2 else '0'; 		
	mem_addr_C_equal <= '1' when mem_addr_C_1 = mem_addr_C_2 else '0'; 	
	mem_data_out_C_equal <= '1' when mem_data_out_C_1 = mem_data_out_C_2 else '0';
    
    -- Only check for equal MEM values if a request is intended by both pipelines
    
    MEM_error <= NOT mem_req_C_equal -- Error if only one pipeline has a request
                OR (mem_req_C_equal AND mem_req_C_1 AND (mem_we_C_equal AND mem_we_C_1) AND NOT (mem_addr_C_equal AND mem_data_out_C_equal)) -- Error if both pipelines request a store with different data/addr
                OR (mem_req_C_equal AND mem_req_C_1 AND (mem_we_C_equal AND NOT mem_we_C_1) AND NOT mem_addr_C_equal) -- Error if both pipelines request a load with different addr
                OR (mem_req_C_equal AND mem_req_C_1 AND NOT mem_we_C_equal); -- Error if one pipeline request a store and the other a load

    is_store <= sb_store_commit_1 OR sb_store_commit_2;

	-- Segmentation regs comparison

	reg_F_D_reset_DU_equal <= '1' when reg_F_D_reset_DU_1 = reg_F_D_reset_DU_2 else '0'; 	
	reg_D_A_reset_DU_equal <= '1' when reg_D_A_reset_DU_1 = reg_D_A_reset_DU_2 else '0'; 	
	reg_F_D_we_equal <= '1' when reg_F_D_we_1 = reg_F_D_we_2 else '0'; 	
	reg_D_A_we_equal <= '1' when reg_D_A_we_1 = reg_D_A_we_2 else '0'; 	

	-- Stall unit comparison

	load_PC_equal <= '1' when load_PC_1 = load_PC_2 else '0'; 		
	reset_PC_equal <= '1' when reset_PC_1 = reset_PC_2 else '0'; 	

	-- Exception unit comparison
	
	exc_F_E_equal <= '1' when exc_F_E_1 = exc_F_E_2 else '0'; 		
	exc_D_E_equal <= '1' when exc_D_E_1 = exc_D_E_2 else '0'; 		
	exc_code_F_E_equal <= '1' when exc_code_F_E_1 = exc_code_F_E_2 else '0'; 	
	exc_code_D_E_equal <= '1' when exc_code_D_E_1 = exc_code_D_E_2 else '0'; 	
	exc_data_F_E_equal <= '1' when exc_data_F_E_1 = exc_data_F_E_2 else '0'; 	
	exc_data_D_E_equal <= '1' when exc_data_D_E_1 = exc_data_D_E_2 else '0'; 	

	-- Check if all tested signals are equal. If one is different, we have detected an error.
	error_detected <= ROB_error OR MEM_error OR NOT ( jump_addr_A_equal AND branch_taken_A_equal 
				AND reg_F_D_reset_DU_equal AND reg_D_A_reset_DU_equal AND reg_F_D_we_equal AND reg_D_A_we_equal
				AND load_PC_equal AND reset_PC_equal AND exc_F_E_equal AND exc_D_E_equal AND exc_code_F_E_equal
				AND exc_code_D_E_equal AND exc_data_F_E_equal AND exc_data_D_E_equal
				);
	
end structure;
