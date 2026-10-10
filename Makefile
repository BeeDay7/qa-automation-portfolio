.PHONY: help install install-dev fixtures fixtures-bg stop test test-ui test-sec test-api lint format type evidence clean

PY ?= python
VENV_BIN := .venv/Scripts
VENV_BIN_UNIX := .venv/bin

help:
	@echo "install       Create venv and install runtime deps"
	@echo "install-dev   Install runtime + dev deps"
	@echo "fixtures      Run fixture servers in foreground"
	@echo "fixtures-bg   Run fixture servers in background"
	@echo "stop          Stop background fixtures"
	@echo "test          Run all Robot suites"
	@echo "test-ui       UI suite only"
	@echo "test-sec      Security-controls suite only"
	@echo "test-api      API suite only"
	@echo "lint          Run ruff"
	@echo "format        Run ruff format"
	@echo "type          Run mypy"
	@echo "evidence      Wipe evidence/ and regenerate everything"
	@echo "clean         Remove caches and evidence"

install:
	$(PY) -m venv .venv
	$(VENV_BIN)/python -m pip install --upgrade pip || $(VENV_BIN_UNIX)/python -m pip install --upgrade pip
	$(VENV_BIN)/pip install -r requirements.txt -e . || $(VENV_BIN_UNIX)/pip install -r requirements.txt -e .

install-dev:
	$(PY) -m venv .venv
	$(VENV_BIN)/python -m pip install --upgrade pip || $(VENV_BIN_UNIX)/python -m pip install --upgrade pip
	$(VENV_BIN)/pip install -r requirements-dev.txt -e ".[dev]" || $(VENV_BIN_UNIX)/pip install -r requirements-dev.txt -e ".[dev]"

fixtures:
	$(PY) scripts/serve_fixtures.py

fixtures-bg:
	$(PY) scripts/serve_fixtures.py --background

stop:
	$(PY) scripts/serve_fixtures.py --stop

test: test-ui test-sec test-api

test-ui:
	robot --outputdir evidence/ui tests/ui

test-sec:
	robot --outputdir evidence/security tests/security

test-api:
	robot --outputdir evidence/api tests/api

lint:
	ruff check src tests scripts

format:
	ruff format src tests scripts

type:
	mypy src

evidence: clean
	mkdir evidence 2>NUL || true
	$(MAKE) test
	@echo "Evidence written to ./evidence"

clean:
	rm -rf evidence .pytest_cache .mypy_cache .ruff_cache || rmdir /S /Q evidence .pytest_cache .mypy_cache .ruff_cache 2>NUL
