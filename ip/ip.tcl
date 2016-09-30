if {![file exists ./rtl]} {
    file mkdir ./rtl
}

foreach f [glob ../rtl/*.sv] {
    file copy -force $f ./rtl/
}

create_project -force core ./ -part xc7a35ticsg324-1L

add_files -norecurse [glob ./rtl/*.sv]
add_files -norecurse ./component.xml
set_property file_type IP-XACT [get_files ./component.xml]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

