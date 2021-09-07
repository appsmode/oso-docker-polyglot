# oso-docker-polyglot
## Background

[Oso](https://www.osohq.com/) is an exciting new Authorization framework built around logic programming in [Polar](https://docs.osohq.com/rust/learn/polar-foundations.html), and is released in several languages, currently supporting Go, Java, Node.js, Python, Rust and Ruby.

This repository includes the Dockerfile `oso-docker-polyglot-base.dockerfile` to build an environment to support all languages that Oso supports, based on the [Docker Rust official image](https://hub.docker.com/_/rust). That environment itself does not contain Oso itself, but can be the basis for other Dockerfiles to create an image with a specific development version of Oso, as shown in the minimalistic `oso-docker-polyglot.dockerfile`.

This image is currently highly experimental and has only been tested with the Oso REPLs. The builds are not meant to cover all use cases and platforms, the purpose of of the image is to have a combined environment for all supported languages. 

## Building the base Image (without Oso)
`docker build -t appsmode/oso-docker-polyglot-base -f oso-docker-polyglot-base.dockerfile .`

This image is also on Dockerhub, so you can reference or pull it
`docker pull appsmode/oso-docker-polyglot-base`

## Building a derived image with Oso based on the main branch
`docker build --no-cache -t appsmode/oso-docker-polyglot -f oso-docker-polyglot.dockerfile .`

## Starting a derived container and mounting a test directory
`docker run -it  --mount type=bind,source="$(pwd)"/examples/python,target=/root/tests --name oso-polyglot --rm appsmode/oso-docker-polyglot`

## Starting a base container and mounting a local Oso git directory
Assuming you start at the parent directory of the oso github repo

`docker run -it  --mount type=bind,source="$(pwd)"/oso,target=/root/git/oso --name oso-polyglot-local --rm appsmode/oso-docker-polyglot-base`

### Test across languages
The image includes a pytest script that validates assertion when initializing the Oso REPLs. Some of these assertions will currently fail as it is testing a [Feature Change for the POLAR_LOG environment](https://github.com/osohq/oso/issues/1121) that is currently in development.

Start a container with a test directory as described above, then run the test

```bash
cd tests
pytest
```
### Attach to a running container
```docker exec -it oso-polyglot bash -l```
## Convenience functions
A number of convenience functions are registered as shell functions in `.oso_functions.sh`.

Those include:

### Cloning
- `oso_clone`
- `oso_clone_shallow`

### Individual language builds
- `oso_repl_build_go`
- `oso_repl_build_java`
- `oso_repl_build_js`
- `oso_repl_build_python`
- `oso_repl_build_ruby`
- `oso_repl_build_rust`

### Combined builds
- `oso_build_repls`
- `oso_build_repls_from_branch repo_url branch_name`

### REPL invocations
- `oso_repl_go`
- `oso_repl_java`
- `oso_repl_js`
- `oso_repl_python`
- `oso_repl_ruby`
- `oso_repl_rust`



