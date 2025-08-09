# JamZig⚡ Conformance Test Binaries

This repository contains the latest JamZig⚡ conformance testing binaries for validating protocol implementations.

## Build Information

- **JamZig⚡ Code GIT_SHA:** `f9bdf31`
- **Graypaper Version:** `v0.6.7`
- **Build Date:** `2025-08-09T10:26:37Z`

## Contents

This repository includes binaries for two parameter sets:

- **`tiny/`** - Built with TINY_PARAMS for quick testing and development
- **`full/`** - Built with FULL_PARAMS for production conformance testing

Each parameter set includes binaries for:
- Linux x86_64
- Linux aarch64
- macOS aarch64

## Fuzzer

The "fuzzer" has been added as a simple test to verify that the "target" is
functional. This fuzzer cannot be used to verify compliance with any standards
or requirements.

## Running Conformance Tests
### Quick Start

From the root directory, run:

```bash
./run_conformance_test.sh
```

This will automatically:
1. Detect your platform
2. Start the conformance target server
3. Run the fuzzer against it
4. Generate a conformance report

### Advanced Usage Examples

```bash
# Run with verbose output (debug level for key scopes)
./run_conformance_test.sh -v

# Run with trace level for key scopes
./run_conformance_test.sh -vv

# Run with debug level for all scopes
./run_conformance_test.sh -vvv

# Run with trace level for all scopes (WARNING: very large output)
./run_conformance_test.sh -vvvv

# Run with trace level and codec debugging (WARNING: extremely large output)
./run_conformance_test.sh -vvvvv

# Run with full parameters and custom settings
./run_conformance_test.sh -p full -b 500 -S 12345 -o report.json -v
```

### Manual Execution

You can also run the components separately:

1. **Start the target server:**
   ```bash
   # For tiny params on Linux x86_64
   ./tiny/linux/x86_64/jam_conformance_target --socket /tmp/jam_conformance.sock

   # For full params on macOS aarch64
   ./full/macos/aarch64/jam_conformance_target --socket /tmp/jam_conformance.sock

   # With verbose output (debug level for key scopes)
   ./tiny/linux/x86_64/jam_conformance_target --socket /tmp/jam_conformance.sock -v

   # With trace level output (very verbose)
   ./tiny/linux/x86_64/jam_conformance_target --socket /tmp/jam_conformance.sock -v -v -v -v

   # Exit after client disconnects (useful for single-run tests)
   ./tiny/linux/x86_64/jam_conformance_target --socket /tmp/jam_conformance.sock --exit-on-disconnect
   ```

2. **Run the fuzzer:**
   ```bash
   # Basic run with 100 blocks
   ./tiny/linux/x86_64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --blocks 100

   # With specific seed for reproducible testing
   ./full/macos/aarch64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --seed 12345 --blocks 500

   # Save report to file
   ./tiny/linux/x86_64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --output report.json

   # With verbose output
   ./tiny/linux/x86_64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --verbose
   ```

### Command Line Options

**Test Runner Script Options (`run_conformance_test.sh`):**
- `-p, --params SET` - Parameter set: tiny or full (default: tiny)
- `-s, --socket PATH` - Unix socket path (default: /tmp/jam_conformance.sock)
- `-b, --blocks N` - Number of blocks to process (default: 100)
- `-S, --seed N` - Random seed for deterministic execution
- `-o, --output FILE` - Output report file
- `-v, --verbose` - Enable verbose output (can be repeated up to 5 times)
- `-h, --help` - Show help message

**Verbose Levels:**
- No `-v` flag: Normal output
- `-v`: Debug level for key scopes (fuzz_protocol, conformance components)
- `-vv`: Trace level for key scopes
- `-vvv`: Debug level for all scopes
- `-vvvv`: Trace level for all scopes (WARNING: very large output)
- `-vvvvv`: Trace level with codec debugging (WARNING: extremely large output)

**Target Server Options:**
- `-h, --help` - Display help and exit
- `-s, --socket <path>` - Unix socket path to listen on (default: /tmp/jam_conformance.sock)
- `-v, --verbose` - Enable verbose output (can be repeated up to 5 times)
- `--exit-on-disconnect` - Exit server when client disconnects (default: keep listening)
- `--dump-params` - Dump JAM protocol parameters and exit
- `--format <format>` - Output format for parameter dump: json or text (default: text)

**Fuzzer Options:**
- `-h, --help` - Display help and exit
- `-v, --verbose` - Enable verbose output (can be repeated up to 5 times)
- `-s, --socket <path>` - Unix socket path to connect to (default: /tmp/jam_conformance.sock)
- `-S, --seed <number>` - Random seed for deterministic execution (default: timestamp)
- `-b, --blocks <number>` - Number of blocks to process (default: 100)
- `-o, --output <file>` - Output report file (optional, prints to stdout if not specified)
- `--dump-params` - Dump JAM protocol parameters and exit
- `--format <format>` - Output format for parameter dump: json or text (default: text)
- `--trace-dir <dir>` - Directory containing W3F format traces to replay

## Parameter Sets

The protocol parameters for each set are available in:
- `tiny/params.json` - Parameters used for tiny builds
- `full/params.json` - Parameters used for full builds

These files contain all JAM protocol constants with their graypaper symbols (e.g., "E" for epoch_length, "C" for core_count).

## Repository Structure

```
├── README.md               # This file
├── RELEASE_INFO.json       # Build metadata
├── run_conformance_test.sh # Main test runner script
├── tiny/                   # Binaries built with TINY_PARAMS
│   ├── params.json         # Protocol parameters
│   ├── linux/
│   │   ├── x86_64/
│   │   └── aarch64/
│   └── macos/
│       └── aarch64/
└── full/                   # Binaries built with FULL_PARAMS
    ├── params.json         # Protocol parameters
    ├── linux/
    │   ├── x86_64/
    │   └── aarch64/
    └── macos/
        └── aarch64/
```

## Build Process

The release binaries are built using:
- **Zig cross-compilation** for multi-platform support
- **GNU parallel** for efficient parallel builds (50% CPU utilization with memory and load safeguards)
- **Optimization level**: ReleaseFast for maximum performance
- **Total configurations**: 6 (3 platforms × 2 parameter sets)

The build process includes:
1. Parallel compilation of all platform/parameter combinations
2. Automatic parameter extraction to JSON format
3. Release packaging with metadata
4. Git commit with traceability information

## Support

For issues or questions about the conformance test suite, please contact the JamZig⚡ team or file an issue in the repository.
