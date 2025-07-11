# JamZig⚡ Conformance Test Binaries

This repository contains the latest JamZig⚡ conformance testing binaries for validating protocol implementations.

## Build Information

- **Git SHA:** `6bb74b3`
- **Build Date:** `2025-07-11T21:57:58Z`

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

### Manual Execution

You can also run the components separately:

1. **Start the target server:**
   ```bash
   # For tiny params on Linux x86_64
   ./tiny/linux/x86_64/jam_conformance_target --socket /tmp/jam_conformance.sock

   # For full params on macOS aarch64
   ./full/macos/aarch64/jam_conformance_target --socket /tmp/jam_conformance.sock
   ```

2. **Run the fuzzer:**
   ```bash
   # Basic run with 100 blocks
   ./tiny/linux/x86_64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --blocks 100

   # With specific seed for reproducible testing
   ./full/macos/aarch64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --seed 12345 --blocks 500

   # Save report to file
   ./tiny/linux/x86_64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --output report.json
   ```

### Command Line Options

**Target Server Options:**
- `--socket <path>` - Unix socket path (default: /tmp/jam_conformance.sock)
- `--port <number>` - TCP port for network mode (optional)
- `--verbose` - Enable verbose logging
- `--trace-scope <scope>` - Enable tracing for specific scopes

**Fuzzer Options:**
- `--socket <path>` - Unix socket path to connect to
- `--seed <number>` - Random seed for deterministic execution
- `--blocks <number>` - Number of blocks to process (default: 100)
- `--output <file>` - Output report file (JSON format)
- `--verbose` - Enable verbose output

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

## Support

For issues or questions about the conformance test suite, please contact the JamZig⚡ team or file an issue in the repository.
