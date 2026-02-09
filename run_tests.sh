#!/bin/bash
# Test runner script for gz-sim10 package restructuring validation
# Usage: ./run_tests.sh [test_name]
#   test_name: fresh-server, upgrade-from-full, no-gui-deps,
#              backward-compat, side-by-side, all

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

run_test() {
  local test_name="$1"
  local dockerfile="Dockerfile.${test_name}"

  if [[ ! -f "$dockerfile" ]]; then
    log_error "Dockerfile not found: $dockerfile"
    return 1
  fi

  log_info "Running test: $test_name"
  log_info "Building from: $dockerfile"

  if docker build --no-cache -f "$dockerfile" -t "gz-sim10-test-${test_name}" .; then
    log_info "TEST PASSED: $test_name"
    return 0
  else
    log_error "TEST FAILED: $test_name"
    return 1
  fi
}

run_all_tests() {
  local failed=0
  local tests=(
    "fresh-server"
    "upgrade-from-full"
    "no-gui-deps"
    "backward-compat"
    "side-by-side"
    "libgz-sim10-dev"
    "gz-jetty"
  )

  log_info "Running all tests..."
  echo ""

  for test in "${tests[@]}"; do
    echo "========================================"
    if run_test "$test"; then
      echo ""
    else
      ((failed++))
      echo ""
    fi
  done

  echo "========================================"
  if [[ $failed -eq 0 ]]; then
    log_info "All tests passed!"
  else
    log_error "$failed test(s) failed"
    return 1
  fi
}

# Main
case "${1:-all}" in
all)
  run_all_tests
  ;;
fresh-server | upgrade-from-full | no-gui-deps | backward-compat | side-by-side | libgz-sim10-dev | gz-jetty)
  run_test "$1"
  ;;
*)
  echo "Usage: $0 [test_name]"
  echo "Available tests:"
  echo "  fresh-server       - Fresh server-only installation"
  echo "  upgrade-from-full  - Upgrade from full Gazebo Jetty"
  echo "  no-gui-deps        - Verify no GUI dependencies"
  echo "  backward-compat    - Backward compatibility test"
  echo "  side-by-side       - Size comparison"
  echo "  libgz-sim10-dev    - Test development package (with GUI)"
  echo "  gz-jetty           - Test user-facing metapackage (with GUI)"
  echo "  all                - Run all tests (default)"
  exit 1
  ;;
esac
