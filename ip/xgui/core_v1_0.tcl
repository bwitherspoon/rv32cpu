# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {Parameters}]
  ipgui::add_param $IPINST -name "TEXT_FILE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DATA_FILE" -parent ${Page_0}


}

proc update_PARAM_VALUE.DATA_FILE { PARAM_VALUE.DATA_FILE } {
	# Procedure called to update DATA_FILE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DATA_FILE { PARAM_VALUE.DATA_FILE } {
	# Procedure called to validate DATA_FILE
	return true
}

proc update_PARAM_VALUE.TEXT_FILE { PARAM_VALUE.TEXT_FILE } {
	# Procedure called to update TEXT_FILE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TEXT_FILE { PARAM_VALUE.TEXT_FILE } {
	# Procedure called to validate TEXT_FILE
	return true
}


proc update_MODELPARAM_VALUE.TEXT_FILE { MODELPARAM_VALUE.TEXT_FILE PARAM_VALUE.TEXT_FILE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TEXT_FILE}] ${MODELPARAM_VALUE.TEXT_FILE}
}

proc update_MODELPARAM_VALUE.DATA_FILE { MODELPARAM_VALUE.DATA_FILE PARAM_VALUE.DATA_FILE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DATA_FILE}] ${MODELPARAM_VALUE.DATA_FILE}
}

