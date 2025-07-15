TEST_MODULE?=upsizer

all: make_dir run_sim

make_dir:
	@if not exist "$(TEST_MODULE)" mkdir "$(TEST_MODULE)"

run_sim:
	qrun -64 -verbose -lint=default -parallel -vlog.sv -vopt.access=rw+/. -f rtl.f -f tb.f -top $(TEST_MODULE)_tb -outdir $(TEST_MODULE) -l $(TEST_MODULE)/qrun.log -designfile $(TEST_MODULE)/$(TEST_MODULE).bin -qwavedb=+memory=all+signal+class+wavefile=$(TEST_MODULE)/$(TEST_MODULE).db

reload_sim: run_sim
	@echo "Reloading simulation in Visualizer without closing..."
	@powershell.exe -Command "& { Reload-Visualizer -BinFile $(TEST_MODULE)/$(TEST_MODULE).bin -WaveFile $(TEST_MODULE)/$(TEST_MODULE).db }"

clean:
	@if exist "$(TEST_MODULE)" rmdir /s /q "$(TEST_MODULE)"
	@if exist ".visualizer/" rmdir /s /q ".visualizer/"
	@if exist "signals.do" del "signals.do"
	@if exist "sysinfo.log" del "sysinfo.log"
	@if exist "visualizer.log" del "visualizer.log"
	@if exist "visualizerSave.ses" del "visualizerSave.ses"
	@if exist "Wave0Reload.do" del "Wave0Reload.do"
