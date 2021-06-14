LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY pc IS
    PORT (clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        addr_jump : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        branch_taken : IN STD_LOGIC;
        exception_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        exception : IN STD_LOGIC;
        iret : IN STD_LOGIC;
        load_PC : IN STD_LOGIC;
        pc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	-- Error control
	error_detected : IN STD_LOGIC;
	recovery_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	new_recovery_pc : IN STD_LOGIC;
	branch_was_taken : IN STD_LOGIC;
    is_store: IN STD_LOGIC;
    rob_error: IN STD_LOGIC
    );
END pc;

ARCHITECTURE structure OF pc IS
    CONSTANT addr_boot : STD_LOGIC_VECTOR := x"00001000";
    CONSTANT addr_sys : STD_LOGIC_VECTOR := x"00002000";

    SIGNAL pc_int : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_exc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL latest_executed_inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL recover_next : STD_LOGIC;
BEGIN
    p : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                pc_int <= addr_boot;
                pc_exc <= addr_boot;

            ELSIF error_detected = '1' THEN
            --pc_int <= recovery_pc; -- does not work if the error occurs out of the ROB commit phase
            --pc_int <= latest_executed_inst + 4; -- does not work if the latest instruction was a jump that succeeded
                IF new_recovery_pc = '1' AND rob_error = '0' THEN
                    -- If the instruction being executed is a jump, reexecute it. 
                    -- Also reexecute it if it is a STORE, because STOREs are not commited to the SB if
                    -- there is an error in the same cycle.
                    IF branch_was_taken = '1' OR is_store = '1' THEN
                        pc_int <= recovery_pc;
                    ELSE
                        pc_int <= recovery_pc + 4;
                    END IF;
                ELSIF recover_next = '1' THEN
                    pc_int <= latest_executed_inst + 4;
                ELSE
                    pc_int <= latest_executed_inst;
                END IF;
            ELSE
                pc_int <= pc_next;

                IF exception = '1' THEN
                    pc_exc <= exception_addr;
                END IF;
            END IF;
            
            IF new_recovery_pc = '1' AND rob_error = '0' THEN
                latest_executed_inst <= recovery_pc;
                IF branch_was_taken = '1' THEN
                    recover_next <= '0';
                ELSE
                    recover_next <= '1';
                END IF;
            END IF;

        END IF;
    END PROCESS p;

    -- When iret = 1, branch_taken is also 1
    pc_next <= addr_sys WHEN exception = '1'
                ELSE pc_exc WHEN iret = '1'
                ELSE addr_jump WHEN branch_taken = '1'
                ELSE pc_int + 4 WHEN load_PC = '1'
                ELSE pc_int;

    pc <= pc_int;
END structure;
