if {![file exists ./rtl]} {
    file mkdir ./rtl
}

if {![file exists ./axi4]} {
    file mkdir ./rtl/axi4
}

foreach f [glob ../rtl/*.sv] {
    file copy -force $f ./rtl/
}

foreach f [glob ../rtl/axi4/*.sv] {
    file copy -force $f ./rtl/axi4/
}

create_project -force core ./ -part xc7a35ticsg324-1L

add_files -norecurse [glob ./rtl/*.sv]
add_files -norecurse [glob ./rtl/axi4/*.sv]
add_files -norecurse ./component.xml
set_property file_type IP-XACT [get_files ./component.xml]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

