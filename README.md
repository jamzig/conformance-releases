# JamZig Conformance Releases

## About JamZig

JamZig is a Zig implementation of the JAM (Join-Accumulate Machine) protocol, designed for high-performance blockchain consensus and computation.

- **Website:** [jamzig.dev](https://jamzig.dev)
- **Twitter:** [@jamzig_dev](https://x.com/jamzig_dev)
- **Main Repository:** [JamZig on GitHub](https://github.com/jamzig/jamzig)

## Purpose of Conformance Releases

The JAM protocol requires precise implementation across different clients to ensure network consensus. These conformance releases serve multiple critical purposes:

1. **Protocol Validation**: Enable different JAM implementations to validate their behavior against a reference implementation
2. **Cross-Platform Testing**: Provide pre-built binaries for multiple platforms to facilitate testing without compilation
3. **Regression Detection**: Track protocol compliance across different versions and detect regressions
4. **Interoperability**: Ensure different JAM implementations can interact correctly

## Directory Structure

```
jamzig-conformance-releases/
├── README.md                   # This file
├── releases/
│   ├── latest/                # Symlink to most recent release
│   └── YYYYMMDDHHMM_GITSHA/  # Individual releases (e.g., 202507030146_1865594)
│       ├── README.md          # Release-specific documentation
│       ├── RELEASE_INFO.json  # Metadata about the release
│       ├── run_conformance_test.sh  # Main test runner script
│       ├── tiny/              # Tiny parameter set builds
│       │   ├── params.json    # JAM protocol parameters used
│       │   ├── linux/
│       │   │   ├── x86_64/   # Linux x86_64 binaries
│       │   │   └── aarch64/  # Linux ARM64 binaries
│       │   └── macos/
│       │       └── aarch64/  # macOS ARM64 binaries
│       └── full/              # Full parameter set builds
│           ├── params.json    # JAM protocol parameters used
│           ├── linux/
│           │   ├── x86_64/
│           │   └── aarch64/
│           └── macos/
│               └── aarch64/
```

### Binary Components

Each platform directory contains:
- `jam_conformance_target` - The server that implements JAM protocol state transitions
- `jam_conformance_fuzzer` - The client that generates test blocks and validates responses
- `run_conformance_test.sh` - Symlink to the main test runner

### Parameter Sets

- **Tiny**: Reduced parameters for quick testing and development (faster block times, smaller validator sets)
- **Full**: Production parameters matching the JAM graypaper specifications

## Using the Releases

### Quick Start

1. Download or clone this repository
2. Navigate to the latest release: `cd releases/latest`
3. Run the conformance test: `./run_conformance_test.sh`

The script will automatically detect your platform and run the appropriate binaries.

### Manual Testing

For more control, you can run the components separately:

```bash
# Start the target server
./tiny/linux/x86_64/jam_conformance_target --socket /tmp/jam_conformance.sock

# In another terminal, run the fuzzer
./tiny/linux/x86_64/jam_conformance_fuzzer --socket /tmp/jam_conformance.sock --blocks 100
```

## Release Process

New releases are created automatically when changes are made to the JamZig implementation:

1. **Build Phase**: The release script builds binaries for all supported platforms using Zig's cross-compilation
2. **Parallel Compilation**: GNU parallel is used to build multiple configurations simultaneously
3. **Parameter Export**: Protocol parameters are extracted and saved as JSON
4. **Release Package**: All artifacts are organized into the directory structure shown above
5. **Git Commit**: The release is committed to this repository with metadata

### Release Naming

Releases follow the format: `YYYYMMDDHHMM_GITSHA`
- Date/time for chronological ordering
- Git SHA for traceability to source code

## Conformance Testing Protocol

The conformance test uses a client-server model over Unix sockets:

[FUZZ PROTOCOL](https://github.com/davxy/jam-stuff/blob/main/fuzz-proto/README.md)

## Contributing

To contribute to JamZig or report conformance issues:

1. Visit the main [JamZig repository](https://github.com/jamzig/jamzig)
2. Check existing issues or create new ones
3. Follow the project on [Twitter](https://x.com/jamzig_dev) for updates

## License

JamZig is open-source software. See the main repository for license details.

---

For technical details about the JAM protocol, refer to the [JAM Graypaper](https://graypaper.com).
