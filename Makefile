usage:
	@echo "Available targets:"
	@echo "  * linter              - Runs rubocop"
	@echo "  * test                - Runs tests"
	@echo "  * bundle              - Installs gems"

linter: ## Runs rubocop
	bundle exec rubocop
test: ## Runs tests
	bundle exec rspec	
bundle: ## Runs tests
	bundle install
