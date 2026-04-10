MIGRATIONS_DIR := ./migrations
STEPS ?= 1

.PHONY: migrate-up migrate-down migrate-force

migrate-up:
	@test -n "$(DATABASE_URL)" || (echo "DATABASE_URL is required" && exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" up

migrate-down:
	@test -n "$(DATABASE_URL)" || (echo "DATABASE_URL is required" && exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" down $(STEPS)

migrate-force:
	@test -n "$(DATABASE_URL)" || (echo "DATABASE_URL is required" && exit 1)
	@test -n "$(VERSION)" || (echo "VERSION is required" && exit 1)
	migrate -path $(MIGRATIONS_DIR) -database "$(DATABASE_URL)" force $(VERSION)
