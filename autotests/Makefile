T := $(sort $(wildcard t-*.sh))

test: $(T)

$(T):
	@echo "*** $@ ***"; ./$@

.PHONY: test $(T)
