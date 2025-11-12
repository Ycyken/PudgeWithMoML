.PHONY: build test coverage compile

build:
	dune build

test: build
	dune test

TEST_COV_D = /tmp/cov
COVERAGE_OPTS = --coverage-path $(TEST_COV_D) --expect bin/

.PHONY: test_coverage coverage
test_coverage: coverage
coverage:
	$(RM) -r $(TEST_COV_D)
	mkdir -p $(TEST_COV_D)
	BISECT_FILE=$(TEST_COV_D)/language dune runtest --no-print-directory \
		--instrument-with bisect_ppx --force
	bisect-ppx-report html $(COVERAGE_OPTS)
	bisect-ppx-report summary $(COVERAGE_OPTS)
	@echo "Use 'xdg-open _coverage/index.html' to see coverage report"

input ?=
opts ?=
LDFLAGS =

ifeq ($(FIXADDR),1)
  LDFLAGS += -no-pie -Wl,-Ttext=0x400000
endif

compile: 
	@riscv64-linux-gnu-gcc -S -march=rv64gc lib/runtime/runtime.c -o runtime.s
	@dune exec compiler -- $(if $(input),-fromfile=$(input)) $(opts) -o main.s

	@riscv64-linux-gnu-as -march=rv64gc main.s -o main.o
	@riscv64-linux-gnu-as -march=rv64gc runtime.s -o runtime.o
	@riscv64-linux-gnu-as -march=rv64gc lib/runtime/call_closure.s -o call_closure.o
	@riscv64-linux-gnu-as -march=rv64gc lib/runtime/load_gp.s -o load_gp.o

	@riscv64-linux-gnu-gcc $(LDFLAGS) -nostartfiles main.o runtime.o call_closure.o load_gp.o -o main.exe
