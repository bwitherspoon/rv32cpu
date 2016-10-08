/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Package: axi4
 *
 * A package for ARM AMBA AXI4 definitions.
 */
package axi4;

    typedef enum logic [2:0] {
        AXI4,
        ACE,
        ACE_LITE
    } prot_t;

    typedef enum logic [1:0] {
        OKAY,
        EXOKAY,
        SLVERR,
        DECERR
    } resp_t;

endpackage : axi4


