.PHONY: up down restart ps

COMPOSE_DIRS := $(shell find . -maxdepth 1 -type d ! -name .)
S = $(shell printf '%*s\n' 30 '' | tr ' ' '-')

up:
	@for d in $(COMPOSE_DIRS); do \
		echo "$S";\
		echo "Starting: $$d"; \
		echo "$S";\
		(cd $$d && docker compose up -d) || echo "Failed: $$d"; \
	done

down:
	@for d in $(COMPOSE_DIRS); do \
		echo "$S";\
		echo "Stopping: $$d"; \
		echo "$S";\
		(cd $$d && docker compose down); \
	done

restart: down up

ps:
	@docker compose ls
