.DEFAULT_GOAL := test
.PHONY: test

test:
	cutest ./test/*.rb
