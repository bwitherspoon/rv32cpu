/**
 * Package: control
 */
package ctrl;

    import aluop::aluop_t;

    // Program counter select
    typedef enum logic [1:0] {
        PC_TARGET,
        PC_TRAP,
        PC_NEXT
    } pc_sel_t;

    // Operand select
    typedef enum logic {
        OP1_RS1,
        OP1_PC,
        OP1_DONTCARE = 'x
    } op1_sel_t;

    // Operand select
    typedef enum logic [2:0] {
        OP2_RS2,
        OP2_I_IMM,
        OP2_S_IMM,
        OP2_B_IMM,
        OP2_U_IMM,
        OP2_J_IMM,
        OP2_DONTCARE = 'x
    } op2_sel_t;

    // Execute stage output select
    typedef enum logic {
        OUT_ALU,
        OUT_PC_PLUS4,
        OUT_DONTCARE = 'x
    } out_sel_t;

    // Memeory stage output select
    typedef enum logic {
        DAT_ALU,
        DAT_MEM,
        DAT_DONTCARE = 'x
    } dat_sel_t;

    typedef struct {
        logic load;
        logic store;
        logic write;
        aluop_t funct;
        pc_sel_t pc_sel;
        op1_sel_t op1_sel;
        op2_sel_t op2_sel;
        dat_sel_t dat_sel;
    } ctrl_t;

    localparam ctrl_t INVALID = '{
        load:    'x,
        store:   '0,
        write:   '0,
        funct:   aluop::XXX,
        pc_sel:  PC_TRAP,
        op1_sel: OP1_DONTCARE,
        op2_sel: OP2_DONTCARE,
        dat_sel: DAT_DONTCARE
    };
    localparam ctrl_t NOP = '{
        load:    '0,
        store:   '0,
        write:   '0,
        funct:   aluop::XXX,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_DONTCARE,
        op2_sel: OP2_DONTCARE,
        dat_sel: DAT_DONTCARE
    };
    localparam ctrl_t ADDI = '{
        load:    '0,
        store:   '0,
        write:   '1,
        funct:   aluop::ADD,
        pc_sel:  PC_NEXT,
        op1_sel: OP1_RS1,
        op2_sel: OP2_I_IMM,
        dat_sel: DAT_ALU
    };
endpackage
