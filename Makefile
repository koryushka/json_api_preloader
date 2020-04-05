usage:
	@echo "Available targets:"
	@echo "  * lint                - Runs rubocop"
	@echo "  * test                - Runs tests"
	@echo "  * bundle              - Installs gems"

lint: ## Runs rubocop
	bundle exec rubocop
test: ## Runs tests
	bundle exec rspec	
bundle: ## Runs tests
	bundle install
