/**
 * Package: ctrl
 */
package ctrl;
    
    // Operand select
    typedef enum logic {
        RS1,
        PC
    } op1_sel_t;

    // Operand select
    typedef enum logic [2:0] {
        RS2,
        I_IMM,
        S_IMM,
        B_IMM,
        U_IMM,
        J_IMM,
        FOUR
    } op2_sel_t;
    
    typedef struct {
        logic invalid;
        logic bubble;
        logic kill;
        logic jump;
        op1_sel_t op1_sel;
        op2_sel_t op2_sel;
    } ctrl_t;

endpackage


