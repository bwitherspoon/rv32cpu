create_project rv32cpu xpr -part xc7a35ticsg324-1L
add_files rtl/
add_files -fileset sim_1 -norecurse sim/testbench.sv
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
