T := $(sort $(wildcard t-*.sh))

test: $(T)
	@if [ -e failed-tests ]; then \
		echo; \
		echo TEST FAILURES:; \
		echo; \
		cat failed-tests; \
		exit 1; \
	fi

remove-failed-tests:
	-rm failed-tests

$(T): remove-failed-tests
	@echo "*** $@ ***"; ./$@

clean: remove-failed-tests
	-rm -r lab

distclean: clean

all:
install:
uninstall:
release:

.PHONY: test remove-failed-tests all install uninstall release distclean $(T)
