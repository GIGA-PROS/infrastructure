# Makefile

REPO_URL=https://github.com/mettle/sendportal.git
BRANCH=v2.0.0
TARGET_DIR=sendportal

clone:
	git clone --depth 1 --branch $(BRANCH) $(REPO_URL) $(TARGET_DIR)
	docker-compose up --build
