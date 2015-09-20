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
.PHONY: test remove-failed-tests $(T)
