#-- QUICK GUIDE--
# make install       create venv + install deps
# make env           create .env from .env.example (if missing)
# make check-key     confirm TAVILY_API_KEY is detected
# make run-search    run tutorial_1/search_basic.py
# make run-extract
# make run-crawl
# make freeze        update requirements.txt from current venv
# make clean         remove __pycache__ etc.
# make nuke          delete .venv


.DEFAULT_GOAL := help
SHELL := /bin/bash

VENV := .venv
PY := $(VENV)/bin/python
PIP := $(PY) -m pip

## --------------------------------------------------------------------------------
## Helper targets
## --------------------------------------------------------------------------------

help: ## Show this help
	@echo "Make targets:"
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk -F':.*?## ' '{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

$(VENV)/bin/python:
	@echo ">> Creating virtual environment in $(VENV)"
	@python -m venv $(VENV)
	@$(PIP) install --upgrade pip

venv: $(VENV)/bin/python ## Create .venv and upgrade pip

install: venv ## Install project dependencies
	@echo ">> Installing requirements"
	@$(PIP) install -r requirements.txt

freeze: venv ## Freeze current environment to requirements.txt
	@$(PY) -m pip freeze > requirements.txt
	@echo ">> Wrote requirements.txt"

env: ## Ensure .env exists at repo root (won't overwrite existing)
	@if [ ! -f .env ]; then \
		if [ -f .env.example ]; then \
			cp .env.example .env && echo ">> Created .env from .env.example (edit it to add your real key)"; \
		else \
			echo "TAVILY_API_KEY=tvly-your-key-here" > .env.example && cp .env.example .env && \
			echo ">> Created .env and .env.example; edit .env to add your real key"; \
		fi \
	else \
		echo ">> .env already exists"; \
	fi

check-key: venv ## Print whether TAVILY_API_KEY is available via .env
	@$(PY) -c 'import os; from dotenv import load_dotenv, find_dotenv; load_dotenv(find_dotenv()); \
print("TAVILY_API_KEY is set" if os.getenv("TAVILY_API_KEY") else "TAVILY_API_KEY is MISSING in .env")'

## --------------------------------------------------------------------------------
## Run examples
## --------------------------------------------------------------------------------

run-search: install env ## Run tutorial_1/search_basic.py
	@$(PY) tutorial_1/search_basic.py

run-extract: install env ## Run tutorial_1/extract_basic.py
	@$(PY) tutorial_1/extract_basic.py

run-crawl: install env ## Run tutorial_1/crawl_basic.py
	@$(PY) tutorial_1/crawl_basic.py

## --------------------------------------------------------------------------------
## Maintenance
## --------------------------------------------------------------------------------

clean: ## Remove caches (keeps venv)
	@find . -type d -name "__pycache__" -prune -exec rm -rf {} \; 2>/dev/null || true
	@rm -rf .pytest_cache .mypy_cache 2>/dev/null || true
	@echo ">> Cleaned caches"

nuke: ## Remove venv entirely (you'll need to re-run `make install` after)
	@rm -rf $(VENV)
	@echo ">> Removed $(VENV)"

