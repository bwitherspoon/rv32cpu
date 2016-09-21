  .text
  .global _start
_start:
  # Initialize global pointer
1:
  auipc gp, %pcrel_hi(_gp)
  addi  gp, gp, %pcrel_lo(1b)

  # Clear the BSS segment
  la      t0, _fbss
  la      t1, _end
1:
  sw      zero,0(t0)
  addi    t0, t0, 4
  bltu    t0, t1, 1b

  la      a0, __libc_fini_array
  call    atexit
  call    __libc_init_array

  lw      a0, 0(sp) # a0 = argc
  addi    a1, sp, 4 # a1 = argv
  li      a2, 0     # a2 = envp = NULL
  call    main
  tail    exit

  .global _init
  .global _fini
_init:
_fini:
  ret
