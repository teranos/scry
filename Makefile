.PHONY: install clean

PREFIX ?= $(HOME)/.qntx
BUILD_DIR = build
# A QNTX source tree: CMake compiles plugin/grpc/protocol from it (see README, Build).
QNTX_SRC ?= $(error QNTX_SRC is not set: make install QNTX_SRC=<QNTX checkout>)

# Restart — tell running QNTX to hot-restart scry. The node's port is BACKEND_PORT, else 8770.
define restart-plugin
	@PORT=$${BACKEND_PORT:-8770}; \
	 curl -sf -X POST http://127.0.0.1:$$PORT/api/plugins/scry/restart > /dev/null 2>&1 \
		&& echo "  ↻ scry restarted — live at http://127.0.0.1:$$PORT" \
		|| echo "  ⊘ no QNTX answered at http://127.0.0.1:$$PORT — the binary is installed, not running"
endef

install: ## Build, install, and restart scry plugin
	@echo "Building qntx-scry-plugin..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && cmake .. -DCMAKE_BUILD_TYPE=Release -DQNTX_SRC=$(QNTX_SRC)
	@cd $(BUILD_DIR) && cmake --build . --parallel 5
	@mkdir -p $(PREFIX)/plugins
	@cp $(BUILD_DIR)/qntx-scry-plugin $(PREFIX)/plugins/qntx-scry-plugin
	@chmod +x $(PREFIX)/plugins/qntx-scry-plugin
	@if [ -f $(BUILD_DIR)/default.metallib ]; then \
		cp $(BUILD_DIR)/default.metallib $(PREFIX)/plugins/default.metallib; \
		echo "✓ default.metallib → $(PREFIX)/plugins/default.metallib"; \
	fi
	@echo "✓ qntx-scry-plugin → $(PREFIX)/plugins/qntx-scry-plugin"
	$(call restart-plugin)

clean: ## Clean build artifacts
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean"
