# Inception of Things - Root Makefile

.PHONY: help fclean clean-p1 clean-p2 clean-p3

.DEFAULT_GOAL := help

help:
	@echo "\033[1;36m=== Inception of Things - Root ===\033[0m"
	@echo ""
	@echo "\033[1;33mCleanup commands:\033[0m"
	@echo "  \033[1;32mmake fclean\033[0m     - Clean all parts (p1, p2, p3)"
	@echo "  \033[1;32mmake clean-p1\033[0m   - Clean part 1"
	@echo "  \033[1;32mmake clean-p2\033[0m   - Clean part 2"
	@echo "  \033[1;32mmake clean-p3\033[0m   - Clean part 3"
	@echo ""

# ============================================================================
# INDIVIDUAL CLEANUP COMMANDS
# ============================================================================

clean-p1:
	@echo "\033[1;36m=== Cleaning Part 1 ===\033[0m"
	@cd p1 && make fclean
	@echo "\033[1;32m✓ Part 1 cleaned\033[0m"

clean-p2:
	@echo "\033[1;36m=== Cleaning Part 2 ===\033[0m"
	@cd p2 && make fclean
	@echo "\033[1;32m✓ Part 2 cleaned\033[0m"

clean-p3:
	@echo "\033[1;36m=== Cleaning Part 3 ===\033[0m"
	@cd p3 && make fclean
	@echo "\033[1;32m✓ Part 3 cleaned\033[0m"


clean-bonus:
	@echo "\033[1;36m=== Cleaning Bonus ===\033[0m"
	@cd bonus && make fclean
	@echo "\033[1;32m✓ Bonus cleaned\033[0m"

# ============================================================================
# FULL CLEANUP
# ============================================================================

fclean: clean-p1 clean-p2 clean-p3
	@echo ""
	@echo "\033[1;36m=== All Parts Cleaned Successfully ===\033[0m"
	@echo ""

