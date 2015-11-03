/**
 * Package: control
 */
package control;

    import aluop::aluop_t;

    // Operand select
    typedef enum logic {
        RS1,
        PC,
        X = 'x
    } op1_sel_t;

    // Operand select
    typedef enum logic [2:0] {
        RS2,
        I_IMM,
        S_IMM,
        B_IMM,
        U_IMM,
        J_IMM,
        FOUR,
        XXX = 'x
    } op2_sel_t;

    typedef struct {
        logic invalid;
        logic bubble;
        logic jump;
        logic load;
        logic store;
        logic register;
        aluop_t operation;
        op1_sel_t op1_sel;
        op2_sel_t op2_sel;
    } ctrl_t;

    localparam ctrl_t INVALID = '{
        invalid:   '1,
        bubble:    '0,
        jump:      '1,
        load:      '0,
        store:     '0,
        register:  '0,
        operation: aluop::XXX,
        op1_sel:   X,
        op2_sel:   XXX
    };
    localparam ctrl_t ADDI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::ADD,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t SLTI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::SLT,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t SLTIU = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::SLTU,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t ANDI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::AND,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t ORI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::OR,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t XORI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::XOR,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t SLLI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::SLL,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t SRLI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::SRL,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t SRAI = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::SRA,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t AUIPC = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '0,
        register:  '1,
        operation: aluop::ADD,
        op1_sel:   PC,
        op2_sel:   U_IMM
    };
    localparam ctrl_t LW = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '1,
        store:     '0,
        register:  '1,
        operation: aluop::ADD,
        op1_sel:   RS1,
        op2_sel:   I_IMM
    };
    localparam ctrl_t SW = '{
        invalid:   '0,
        bubble:    '0,
        jump:      '0,
        load:      '0,
        store:     '1,
        register:  '0,
        operation: aluop::ADD,
        op1_sel:   RS1,
        op2_sel:   S_IMM
    };

endpackage
