MOCHA=./node_modules/.bin/mocha
COFFEE=./node_modules/.bin/coffee
MOCHA_FMT?=spec
MOCHA_OPTS=--compilers coffee:coffee-script/register --globals document,window,Bling,$$,_ -R ${MOCHA_FMT} -s 500 --bail

all: lib/objectpool.js
	@echo Files up-to-date: $<

test: all test/objectpool.coffee ${MOCHA} ${COFFEE}
	@${MOCHA} ${MOCHA_OPTS} test/objectpool.coffee

lib/%.js: src/%.coffee
	@echo Compiling $<...
	@mkdir -p lib
	@sed -e 's/# .*$$//' $< | cpp -Isrc -I. -w | coffee -sc > $@

${COFFEE}:
	npm install coffee-script

${MOCHA}:
	npm install mocha

.PHONY: all test clean
