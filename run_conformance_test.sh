#!/bin/bash

# JAM Conformance Test Runner
# This script orchestrates running the conformance test between fuzzer and target

set -e  # Exit on error

# Configuration
SOCKET_PATH="/tmp/jam_conformance.sock"
NUM_BLOCKS=100
SEED=""
OUTPUT_FILE=""
VERBOSE_LEVEL=0
TRACE_LEVEL=""
DEBUG_CODEC=false
DEFAULT_QUIET_SCOPES="codec"
PARAM_SET="tiny"  # Default to tiny

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--params)
            PARAM_SET="$2"
            shift 2
            ;;
        -s|--socket)
            SOCKET_PATH="$2"
            shift 2
            ;;
        -b|--blocks)
            NUM_BLOCKS="$2"
            shift 2
            ;;
        -S|--seed)
            SEED="--seed $2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="--output $2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE_LEVEL=$((VERBOSE_LEVEL + 1))
            shift
            ;;
        -vv)
            VERBOSE_LEVEL=2
            shift
            ;;
        --debug-codec)
            DEBUG_CODEC=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -p, --params SET     Parameter set: tiny or full (default: tiny)"
            echo "  -s, --socket PATH    Unix socket path (default: /tmp/jam_conformance.sock)"
            echo "  -b, --blocks N       Number of blocks to process (default: 100)"
            echo "  -S, --seed N         Random seed for deterministic execution"
            echo "  -o, --output FILE    Output report file"
            echo "  -v, --verbose        Enable verbose output (use -vv for trace level)"
            echo "  --debug-codec        Include codec in debug output (normally suppressed)"
            echo "  -h, --help           Show this help message"
            echo ""
            echo "Verbose Levels:"
            echo "  (no -v)    Normal output"
            echo "  -v         Debug level tracing (moderate output, codec at info)"
            echo "  -vv        Trace level tracing (WARNING: very large output, codec at info)"
            echo ""
            echo "Note: By default, codec logging is kept at info level to reduce noise."
            echo "      Use --debug-codec to include full codec debugging."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set trace level based on verbose level
if [ $VERBOSE_LEVEL -eq 0 ]; then
    TRACE_LEVEL=""
elif [ $VERBOSE_LEVEL -eq 1 ]; then
    TRACE_LEVEL="--trace-all debug"
    if [ "$DEBUG_CODEC" = false ]; then
        TRACE_LEVEL="$TRACE_LEVEL --trace-quiet $DEFAULT_QUIET_SCOPES"
        echo "Verbose mode: DEBUG level (moderate output, codec at info)"
    else
        echo "Verbose mode: DEBUG level (including codec)"
    fi
elif [ $VERBOSE_LEVEL -ge 2 ]; then
    TRACE_LEVEL="--trace-all trace"
    if [ "$DEBUG_CODEC" = false ]; then
        TRACE_LEVEL="$TRACE_LEVEL --trace-quiet $DEFAULT_QUIET_SCOPES"
        echo "Verbose mode: TRACE level (WARNING: very large output, codec at info)"
    else
        echo "Verbose mode: TRACE level (WARNING: EXTREMELY large output, including codec)"
    fi
fi

# Set verbose flag for fuzzer
if [ $VERBOSE_LEVEL -gt 0 ]; then
    VERBOSE="--verbose"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}JAM Conformance Test Runner${NC}"
echo "============================"
echo "Parameter Set: $PARAM_SET"
echo "Socket: $SOCKET_PATH"
echo "Blocks: $NUM_BLOCKS"
echo ""

# Detect host architecture and OS
HOST_ARCH=$(uname -m)
HOST_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Normalize architecture names
case "${HOST_ARCH}" in
    x86_64) ARCH_NAME="x86_64" ;;
    arm64|aarch64) ARCH_NAME="aarch64" ;;
    *) ARCH_NAME="${HOST_ARCH}" ;;
esac

# Normalize OS names
case "${HOST_OS}" in
    linux) OS_NAME="linux" ;;
    darwin) OS_NAME="macos" ;;
    *) OS_NAME="${HOST_OS}" ;;
esac

EXPECTED_DIR="${OS_NAME}/${ARCH_NAME}"

# Function to find executables
find_executables() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local current_dir="$(pwd)"
    
    # Check if we're in the repository root
    if [ -d "tiny" ] && [ -d "full" ]; then
        echo -e "${YELLOW}Detected repository root${NC}"
        echo -e "${YELLOW}Using parameter set: $PARAM_SET${NC}"
        echo -e "${YELLOW}Auto-navigating to: ${PARAM_SET}/${OS_NAME}/${ARCH_NAME}${NC}"
        
        # Check if the architecture directory exists
        if [ -d "${PARAM_SET}/${OS_NAME}/${ARCH_NAME}" ]; then
            TARGET_BIN="${PARAM_SET}/${OS_NAME}/${ARCH_NAME}/jam_conformance_target"
            FUZZER_BIN="${PARAM_SET}/${OS_NAME}/${ARCH_NAME}/jam_conformance_fuzzer"
            
            if [ -f "$TARGET_BIN" ] && [ -f "$FUZZER_BIN" ]; then
                echo -e "${GREEN}Found executables for ${PARAM_SET} params${NC}"
                return 0
            else
                echo -e "${RED}Error: Executables not found in ${PARAM_SET}/${OS_NAME}/${ARCH_NAME}${NC}"
                return 1
            fi
        else
            echo -e "${RED}Error: Architecture directory '${PARAM_SET}/${OS_NAME}/${ARCH_NAME}' not found${NC}"
            echo ""
            echo "This release does not include binaries for your platform."
            echo "Available architectures:"
            if [ -d "${PARAM_SET}/linux" ]; then
                echo "  - linux/$(ls ${PARAM_SET}/linux 2>/dev/null | tr '\n' ' ')"
            fi
            if [ -d "${PARAM_SET}/macos" ]; then
                echo "  - macos/$(ls ${PARAM_SET}/macos 2>/dev/null | tr '\n' ' ')"
            fi
            exit 1
        fi
    fi
    
    # Check if we're in a param set subdirectory (tiny/ or full/)
    if [[ "$current_dir" =~ /(tiny|full)$ ]]; then
        local detected_param_set=$(basename "$current_dir")
        echo -e "${YELLOW}Detected parameter set directory: $detected_param_set${NC}"
        PARAM_SET="$detected_param_set"
        echo -e "${YELLOW}Auto-navigating to architecture: ${OS_NAME}/${ARCH_NAME}${NC}"
        
        # Check if the architecture directory exists
        if [ -d "${OS_NAME}/${ARCH_NAME}" ]; then
            cd "${OS_NAME}/${ARCH_NAME}"
            echo -e "${GREEN}Changed to architecture directory: $(pwd)${NC}"
        else
            echo -e "${RED}Error: Architecture directory '${OS_NAME}/${ARCH_NAME}' not found${NC}"
            echo ""
            echo "This release does not include binaries for your platform."
            echo "Available architectures in this directory:"
            if [ -d "linux" ]; then
                echo "  - linux/$(ls linux 2>/dev/null | tr '\n' ' ')"
            fi
            if [ -d "macos" ]; then
                echo "  - macos/$(ls macos 2>/dev/null | tr '\n' ' ')"
            fi
            exit 1
        fi
    fi
    
    # Search paths in order
    local search_paths=(
        "$script_dir"                    # Same directory as script
        "./zig-out/bin"                  # Development build directory
        "."                              # Current directory
    )
    
    for path in "${search_paths[@]}"; do
        if [ -f "$path/jam_conformance_target" ] && [ -f "$path/jam_conformance_fuzzer" ]; then
            TARGET_BIN="$path/jam_conformance_target"
            FUZZER_BIN="$path/jam_conformance_fuzzer"
            echo "Found executables in: $path"
            return 0
        fi
    done
    
    return 1
}

# Try to find executables
if ! find_executables; then
    echo -e "${RED}Error: Could not find jam_conformance_target and jam_conformance_fuzzer${NC}"
    
    # Check if we're in a repository with tiny/full directories
    if [ -d "tiny" ] || [ -d "full" ]; then
        echo ""
        echo -e "${YELLOW}Available parameter sets:${NC}"
        [ -d "tiny" ] && echo "  - tiny"
        [ -d "full" ] && echo "  - full"
        echo ""
        echo -e "${GREEN}Your host architecture: ${OS_NAME}/${ARCH_NAME}${NC}"
        echo ""
        echo "The binaries for your architecture were not found."
        echo "Please check that the release includes binaries for your platform."
    else
        echo ""
        echo "Please ensure the executables are built:"
        echo "  - For development: zig build conformance_fuzzer conformance_target"
        echo "  - For releases: Run from the repository root"
    fi
    exit 1
fi

# Clean up any existing socket
rm -f "$SOCKET_PATH"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Cleaning up..."
    if [ ! -z "$TARGET_PID" ]; then
        kill $TARGET_PID 2>/dev/null || true
        wait $TARGET_PID 2>/dev/null || true
    fi
    rm -f "$SOCKET_PATH"
}

# Set up trap to cleanup on exit
trap cleanup EXIT INT TERM

# Start the target server in background
echo "Starting target server..."
 
$TARGET_BIN $TRACE_LEVEL --socket "$SOCKET_PATH" &
TARGET_PID=$!

# Wait for target to be ready
echo "Waiting for target to be ready..."
for i in {1..50}; do
    if [ -S "$SOCKET_PATH" ]; then
        echo -e "${GREEN}Target server ready${NC}"
        break
    fi
    if ! kill -0 $TARGET_PID 2>/dev/null; then
        echo -e "${RED}Target server failed to start${NC}"
        exit 1
    fi
    sleep 0.1
done

if [ ! -S "$SOCKET_PATH" ]; then
    echo -e "${RED}Timeout waiting for target server${NC}"
    exit 1
fi

# Small additional delay to ensure server is fully ready
sleep 0.5

# Run the fuzzer
echo ""
echo "Running conformance fuzzer..."
echo "----------------------------"

$FUZZER_BIN \
    --socket "$SOCKET_PATH" \
    --blocks "$NUM_BLOCKS" \
    $SEED \
    $OUTPUT_FILE \
    $VERBOSE

FUZZER_EXIT_CODE=$?

# Report results
echo ""
echo "----------------------------"
if [ $FUZZER_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Conformance test PASSED${NC}"
    exit 0
else
    echo -e "${RED}✗ Conformance test FAILED${NC}"
    exit $FUZZER_EXIT_CODE
fi
