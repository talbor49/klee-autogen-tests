CC=wllvm
CFLAGS = -lkleeRuntest -L $(LIBKLEE_PATH) -g3 -O0 -I ../../include
# This was the path in docker...
# Found by running find / -iname libkleeRuntest.so
LIBKLEE_PATH = /tmp/klee_build90stp_z3/lib/

SRCS = main.c mynet.c
BITCODE_FILES = main.bc mynet.bc

PROGRAM_NAME = program
COVERAGE_PROGRAM = $(PROGRAM_NAME)_coverage

.DEFAULT_GOAL=coverage

$(PROGRAM_NAME): $(SRCS)
	$(CC) $^ -o $@ $(CFLAGS)

# For some reason we can't run klee on program with -ftest-coverage
# becuase it can't resolve the llvm cov symbols
# So use another binary for tests, it works and it's better 
# Because we don't include coverage code in our symbolic execution
$(COVERAGE_PROGRAM): $(SRCS)
	$(CC) $^ -o $@ $(CFLAGS) -fprofile-arcs -ftest-coverage -fcoverage-mapping -fprofile-instr-generate

# To get 'extract-bc' you need to install 
$(PROGRAM_NAME).bc: $(PROGRAM_NAME)
	extract-bc $^

# From here: https://klee.github.io/tutorials/testing-coreutils/
generate_tests: $(PROGRAM_NAME).bc
	klee --libc=uclibc --posix-runtime $^

run_klee_tests: generate_tests $(COVERAGE_PROGRAM)
	counter=0; for fn in `ls klee-last/test*.ktest`; do counter=$$((counter+1)); LLVM_PROFILE_FILE="program_$$counter.profraw" KTEST_FILE="$$fn" ./program_coverage; done

coverage.html: run_klee_tests
	llvm-profdata merge -sparse program_*.profraw -o program.profdata
	llvm-cov show $(COVERAGE_PROGRAM) -instr-profile=program.profdata --format=html > $@
	llvm-cov report $(COVERAGE_PROGRAM) -instr-profile=program.profdata

coverage: coverage.html

.PHONY: generate_tests run_klee_tests coverage 

clean:
	@rm $(PROGRAM_NAME) *.profraw *.profdata .*.gcda .*.gcno .*.o .*.bc *.gcda *.gcno *.bc *.o $(COVERAGE_PROGRAM) coverage.html


