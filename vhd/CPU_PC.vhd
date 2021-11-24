library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;


entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,

        S_LUI,

        S_ADDI,
        S_ADD,

        S_ANDI,
        S_AND,
        S_ORI,
        S_OR,
        S_XORI,
        S_XOR,

        S_SUB,

        S_SLL,
        S_SRLI,
        S_SRL,
        S_SRAI,
        S_SRA,
        S_SLLI,

        S_AUIPC,

        S_BRANCH,
        S_SLT,
        S_SLTI,
        S_JAL,
        S_JALR,

        S_Pre_Pre_LOAD,
        S_Pre_LOAD,
        S_LW,
        S_LB,
        S_LBU,
        S_LH,
        S_LHU,

        S_Pre_STORE,
        S_SW,
        S_SB,
        S_SH,

        S_CSR,
        S_CSRI,
        S_MRET,
        S_INTERUPT
    );

    signal state_d, state_q : State_type;


begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.ALU_op            <= UNDEFINED;
        cmd.LOGICAL_op        <= UNDEFINED;
        cmd.ALU_Y_sel         <= UNDEFINED;

        cmd.SHIFTER_op        <= UNDEFINED;
        cmd.SHIFTER_Y_sel     <= UNDEFINED;

        cmd.RF_we             <= 'U';
        cmd.RF_SIZE_sel       <= UNDEFINED;
        cmd.RF_SIGN_enable    <= 'U';
        cmd.DATA_sel          <= UNDEFINED;

        cmd.PC_we             <= 'U';
        cmd.PC_sel            <= UNDEFINED;

        cmd.PC_X_sel          <= UNDEFINED;
        cmd.PC_Y_sel          <= UNDEFINED;

        cmd.TO_PC_Y_sel       <= UNDEFINED;

        cmd.AD_we             <= 'U';
        cmd.AD_Y_sel          <= UNDEFINED;

        cmd.IR_we             <= 'U';

        cmd.ADDR_sel          <= UNDEFINED;
        cmd.mem_we            <= 'U';
        cmd.mem_ce            <= 'U';

        cmd.cs.CSR_we            <= UNDEFINED;

        cmd.cs.TO_CSR_sel        <= UNDEFINED;
        cmd.cs.CSR_sel           <= UNDEFINED;
        cmd.cs.MEPC_sel          <= UNDEFINED;

        cmd.cs.MSTATUS_mie_set   <= 'U';
        cmd.cs.MSTATUS_mie_reset <= 'U';

        cmd.cs.CSR_WRITE_mode    <= UNDEFINED;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                -- interruption
                if status.IT then
                    state_d <= S_INTERUPT;
                else
                    -- IR <- mem_datain
                    cmd.IR_we <= '1';
                    state_d <= S_Decode;
                end if;

            when S_INTERUPT =>
                cmd.cs.MEPC_sel <= MEPC_from_pc;
                cmd.cs.CSR_we <= CSR_mepc;
                cmd.cs.CSR_write_mode <= WRITE_mode_simple;
                cmd.cs.MSTATUS_mie_reset <= '1';

                cmd.PC_sel <= PC_mtvec;
                cmd.PC_we <= '1';

                state_d <= S_Pre_Fetch;

            when S_Decode =>

                state_d <= S_Error;

                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';

                -- Décodage effectif des instructions

                if status.IR(6 downto 0) = "0110111" then
                    state_d <= S_LUI;

                elsif status.IR(6 downto 0) = "0010011" then
                    -- Op avec immediat

                    if status.IR(14 downto 12) = "000" then -- ADDI
                        state_d <= S_ADDI;
                    elsif status.IR(14 downto 12) = "111" then -- ANDI
                        state_d <= S_ANDI;
                    elsif status.IR(14 downto 12) = "110" then -- ORI
                        state_d <= S_ORI;
                    elsif status.IR(14 downto 12) = "100" then -- XORI
                        state_d <= S_XORI;
                    elsif status.IR(14 downto 12) = "101" then -- SRLI/SRAI
                        if status.IR(31 downto 25) = "0000000" then
                            state_d <= S_SRLI;
                        elsif status.IR(31 downto 25) = "0100000" then
                            state_d <= S_SRAI;
                        end if;
                    elsif status.IR(14 downto 12) = "001" then -- SLLI
                        state_d <= S_SLLI;
                    elsif status.IR(14 downto 13) = "01" then -- SLTI/SLTIU
                        cmd.PC_we <= '0';
                        state_d <= S_SLTI;
                    else
                        state_d <= S_Error;
                    end if;

                elsif status.IR(6 downto 0) = "0110011" then
                    -- Op avec 2 operand

                    if status.IR(14 downto 12) = "000" then -- ADD/SUB
                        if status.IR(31 downto 25) = "0000000" then
                            state_d <= S_ADD;
                        elsif status.IR(31 downto 25) = "0100000" then
                            state_d <= S_SUB;
                        end if;
                    elsif status.IR(14 downto 12) = "111" then -- AND
                        state_d <= S_AND;
                    elsif status.IR(14 downto 12) = "110" then -- OR
                        state_d <= S_OR;
                    elsif status.IR(14 downto 12) = "100" then -- XOR
                        state_d <= S_XOR;
                    elsif status.IR(14 downto 12) = "101" then -- SRL/SRA
                        if status.IR(31 downto 25) = "0000000" then
                            state_d <= S_SRL;
                        elsif status.IR(31 downto 25) = "0100000" then
                            state_d <= S_SRA;
                        end if;
                    elsif status.IR(14 downto 12) = "001" then -- SLL
                        state_d <= S_SLL;
                    elsif status.IR(14 downto 13) = "01" then -- SLT/SLTU
                        cmd.PC_we <= '0';
                        state_d <= S_SLT;
                    else
                        state_d <= S_Error;
                    end if;

                elsif status.IR(6 downto 0) = "0010111" then
                    -- AUIPC
                    cmd.PC_we <= '0';
                    state_d <= S_AUIPC;
                elsif status.IR(6 downto 0) = "1100011" then
                    -- Jumps
                    cmd.PC_we <= '0';
                    state_d <= S_BRANCH;
                elsif status.IR(6 downto 0) = "1101111" then
                    -- jal
                    cmd.PC_we <= '0';
                    state_d <= S_JAL;
                elsif status.IR(6 downto 0) = "1100111" then
                    -- jalr
                    cmd.PC_we <= '0';
                    state_d <= S_JALR;
                elsif status.IR(6 downto 0) = "0000011" then
                    -- lw, lb, lbu, lh, lhu
                    state_d <= S_Pre_Pre_LOAD;
                elsif status.IR(6 downto 0) = "0100011" then
                    -- sw, sb, sh
                    state_d <= S_Pre_STORE;elsif status.IR(6 downto 0) = "0100011" then
                    -- sw, sb, sh
                    state_d <= S_Pre_STORE;
                elsif status.IR(6 downto 0) = "1110011" then
                    -- csrrw
                    if status.IR(14) = '0' then
                        if status.IR(14 downto 12) = "000" then
                            state_d <= S_MRET;
                        else
                            state_d <= S_CSR;
                        end if;
                    else
                        state_d <= S_CSRI;
                    end if;
                else
                    state_d <= S_Error; -- Pour détecter les ratés du décodage
                end if;
                    

---------- Instructions avec immediat de type U ----------
            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

---------- Instructions arithmétiques et logiques ----------
            when S_ADDI =>
                -- rd <- Imm + rs1
                cmd.ALU_op <= ALU_plus;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ADD =>
                -- rs <- rs1 + rs2
                cmd.ALU_op <= ALU_plus;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ANDI =>
                -- rd <- Imm & rs1
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_AND =>
                -- rs <- rs1 & rs2
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_ORI =>
                -- rd <- Imm | rs1
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_OR =>
                -- rd <- rs1 | rs2
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
        
            when S_XORI =>
                -- rd <- Imm ^ rs1
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_XOR =>
                -- rd <- rs1 ^ rs2
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_logical;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            
            when S_SUB =>
                -- rs <- rs1 - rs2
                cmd.ALU_op <= ALU_minus;
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_alu;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SRLI =>
                -- rd <- rs1 >> shamt
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
        
            when S_SRL =>
                -- rd <- rs1 >> rs2
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            
            when S_SRAI =>
                -- rd <- rs1 >>> shamt
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SRA =>
                -- rd <- rs1 >>> rs2
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SLLI =>
                -- rd <- rs1 << shamt
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_SLL =>
                -- rd <- rs1 << rs2
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_shifter;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;

            when S_AUIPC =>
                -- rs <- ImmU + pc
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- PC += 4
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;


---------- Instructions de saut et comparaisons ----------
            when S_BRANCH =>
                -- jcond
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                -- if jcond => pc = pc + immediat
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                if status.JCOND then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;

            when S_JAL =>
                -- rd = pc
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- pc = pc + immJ
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_from_pc;
                cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;

                state_d <= S_Pre_Fetch;

            when S_JALR =>
                -- rd = pc
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- pc = immI + rs1
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_from_alu;
                cmd.ALU_op <= ALU_plus;
                cmd.ALU_Y_sel <= ALU_Y_immI;

                state_d <= S_Pre_Fetch;

            when S_SLT =>
                -- jcond
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                -- rd <- rs1 comp rs2
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                -- incr PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

            when S_SLTI =>
                -- jcond
                cmd.ALU_Y_sel <= ALU_Y_immI;
                -- rd <- rs1 comp rs2
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_slt;
                -- incr PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;

---------- Instructions de chargement à partir de la mémoire ----------
            when S_Pre_Pre_LOAD =>
                -- AD = rs1 + immI
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_Pre_LOAD;

            when S_Pre_LOAD =>
                cmd.AD_we <= '0';
                cmd.mem_we <= '0';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;

                if status.IR(14 downto 12) = "010" then
                    state_d <= S_LW;
                elsif status.IR(14 downto 12) = "000" then
                    state_d <= S_LB;
                elsif status.IR(14 downto 12) = "100" then
                    state_d <= S_LBU;
                elsif status.IR(14 downto 12) = "001" then
                    state_d <= S_LH;
                elsif status.IR(14 downto 12) = "101" then
                    state_d <= S_LHU;
                end if;

            when S_LW =>
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';

                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

            when S_LB =>
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';

                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

            when S_LBU =>
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';

                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

            when S_LH =>
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';

                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

            when S_LHU =>
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_we <= '1';

                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d <= S_Fetch;

---------- Instructions de sauvegarde en mémoire ----------
            
            when S_Pre_STORE =>
                -- AD = rs1 + immI
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                if status.IR(14 downto 12) = "000" then
                    state_d <= S_SB;
                elsif status.IR(14 downto 12) = "001" then
                    state_d <= S_SH;
                else
                    state_d <= S_SW;
                end if;

            when S_SW =>
                cmd.AD_we <= '0';
                cmd.mem_we <= '1';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;

                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_word;

                state_d <= S_Pre_Fetch;

            when S_SB =>
                cmd.AD_we <= '0';
                cmd.mem_we <= '1';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;

                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_byte;

                state_d <= S_Pre_Fetch;

            when S_SH =>
                cmd.AD_we <= '0';
                cmd.mem_we <= '1';
                cmd.mem_ce <= '1';
                cmd.ADDR_sel <= ADDR_from_ad;

                cmd.RF_SIGN_enable <= '1';
                cmd.RF_SIZE_sel <= RF_SIZE_half;

                state_d <= S_Pre_Fetch;

---------- Instructions d'accès aux CSR ----------
            when S_CSR =>
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;

                if status.IR(14 downto 12) = "001" then
                    -- csrrw
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                elsif status.IR(14 downto 12) = "010" then
                    -- csrrs
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                elsif status.IR(14 downto 12) = "011" then
                    -- csrrc
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                end if;

                if status.IR(31 downto 20) = x"300" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = x"304" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = x"305" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = x"341" then
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                elsif status.IR(31 downto 20) = x"342" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                elsif status.IR(31 downto 20) = x"344" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                end if;

                state_d <= S_Pre_Fetch;

            when S_CSRI =>
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;

                if status.IR(14 downto 12) = "101" then
                    -- csrrwi
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                elsif status.IR(14 downto 12) = "110" then
                    -- csrrsi
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                elsif status.IR(14 downto 12) = "111" then
                    -- csrrci
                    cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                end if;

                if status.IR(31 downto 20) = x"300" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = x"304" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = x"305" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = x"341" then
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                elsif status.IR(31 downto 20) = x"342" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                elsif status.IR(31 downto 20) = x"344" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                end if;

                state_d <= S_Pre_Fetch;

            when S_MRET =>
                cmd.PC_sel <= PC_from_mepc;
                cmd.PC_we <= '1';
                
                cmd.cs.MSTATUS_mie_set <= '1';

                state_d <= S_Pre_Fetch;

            when others => null;
        end case;

    end process FSM_comb;

end architecture;
