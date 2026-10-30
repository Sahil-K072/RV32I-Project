files := ./design_sources/alu.sv \
./design_sources/control_unit.sv \
./design_sources/csr_block.sv \
./design_sources/data_mem.sv \
./design_sources/definitions.sv \
./design_sources/hazard_unit.sv \
./design_sources/imm_extender.sv \
./design_sources/instruction_mem.sv \
./design_sources/mux_2to1.sv \
./design_sources/mux_3to1.sv \
./design_sources/mux_5to1.sv \
./design_sources/reg_file.sv \
./design_sources/top.sv \
./test/tb.sv \
./test/test.txt \
./test/testbench_machine_code.txt \

exec: compile 
	echo "-------------------"
	./obj_dir/Vtb

compile: $(files)
	verilator --binary -j 0 --trace --timing --Wno-fatal ./test/tb.sv ./design_sources/definitions.sv ./test/tb.sv -y ./design_sources/