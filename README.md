# Gazebo Jetty Server-Only Package Split -- Test Suite

Docker-based test suite that validates the `gz-sim10` package restructuring, which splits the monolithic Gazebo package into a server-only variant (`gz-sim10-server`) and a full GUI variant (`gz-jetty`). All tests run against the OSRF prerelease repository on Ubuntu Noble.

## Prerequisites

- Docker
- (For `upgrade-from-full` only) The `ghcr.io/j-rivero/gazebo:jetty-full` base image

## Usage

```bash
# Run all tests
./run_tests.sh

# Run a single test
./run_tests.sh fresh-server
```

Each test is a Dockerfile that builds successfully only if all its verification steps pass. A failed `RUN` step causes the Docker build (and thus the test) to fail.

## Tests

| Test | Dockerfile | Description |
|---|---|---|
| `fresh-server` | `Dockerfile.fresh-server` | Fresh `gz-sim10-server` install on clean Ubuntu Noble. Verifies the server binary exists (`gz-sim-server`) and that no GUI packages (`libgz-sim10-gui`, `libgz-sim10-plugins-gui`) or Qt libraries are installed. |
| `upgrade-from-full` | `Dockerfile.upgrade-from-full` | Starts from a full Gazebo Jetty image, adds the prerelease repo, and runs `dist-upgrade`. Verifies the new GUI split packages (`libgz-sim10-gui`, `libgz-sim10-plugins-gui`) appear after upgrade and that `gz-sim10-server` is available. Logs package lists before and after the upgrade. |
| `no-gui-deps` | `Dockerfile.no-gui-deps` | Comprehensive dependency audit of `gz-sim10-server`. Scans all installed packages against a broad set of GUI patterns (Qt, `libgz-gui`, `libgz-sim*-gui`). On any match, traces reverse dependencies to identify the offending chain and fails the build. Also verifies specific Gazebo GUI packages are absent, checks installation size, and lists physics engine packages. |
| `backward-compat` | `Dockerfile.backward-compat` | Installs `gz-jetty` from scratch and verifies full GUI functionality is preserved: GUI packages present, server binary present, `gz sim --help` works, and `libgz-sim10-dev` is available. |
| `libgz-sim10-dev` | `Dockerfile.libgz-sim10-dev` | Installs `libgz-sim10-dev` and verifies that the development package includes headers (`/usr/include/gz/sim10`), pkg-config files, GUI components (`libgz-sim10-gui`, `libgz-sim10-plugins-gui`), and that the `gz` command works. |
| `side-by-side` | `Dockerfile.side-by-side` | Multi-stage build that installs `gz-sim10-server` and `gz-jetty` in separate stages, then reports total package counts, Gazebo-specific package counts, and disk usage for each. Used to quantify the size savings of the server-only variant. |
| `gz-jetty` | `Dockerfile.gz-jetty` | Installs the user-facing `gz-jetty` metapackage and verifies all expected components: GUI packages, core library, server binary, `gz sim` command, and `gz-sim10` related packages. |
