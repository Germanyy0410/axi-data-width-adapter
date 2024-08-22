TEST_MODULE?=upsizer

all: make_dir run_sim

make_dir:
	@if not exist "$(TEST_MODULE)" mkdir "$(TEST_MODULE)"

run_sim:
	qrun -64 -verbose -lint=default -parallel -vlog.sv -vopt.access=rw+/. -f rtl.f -f tb.f -top $(TEST_MODULE)_tb -outdir $(TEST_MODULE) -l $(TEST_MODULE)/qrun.log -designfile $(TEST_MODULE)/$(TEST_MODULE).bin -qwavedb=+memory=all+signal+class+wavefile=$(TEST_MODULE)/$(TEST_MODULE).db
