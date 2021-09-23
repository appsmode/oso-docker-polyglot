#!/bin/bash
oso_clone() {
    cd ~/git
    git clone https://github.com/osohq/oso
    cd oso
}
oso_clone_shallow() {
    cd ~/git
    git clone https://github.com/osohq/oso --depth 1
    cd oso
}
oso_repl_build_go() {
    (
        cd ${OSO_GIT_HOME}/languages/go
        make copy_lib
        go build cmd/oso/oso.go
    )
}
oso_repl_build_java() {
    (
        cd ${OSO_GIT_HOME}/languages/java
        make rust
        make package
    )
}
oso_repl_build_js() {
    (   cd ${OSO_GIT_HOME}/polar-wasm-api
        make build
        cd ${OSO_GIT_HOME}/languages/js
        make build
        yarn global add file:$PWD
    )
}
oso_repl_build_python() {
    (
        cd ${OSO_GIT_HOME}
        make python-build
    )
}
oso_repl_build_ruby() {
    (
        cd ${OSO_GIT_HOME}/languages/ruby
        make install
    )
}
oso_repl_build_rust() {
    (
        cd ${OSO_GIT_HOME}
        cargo build
        cargo build --features=cli
    )
}
oso_build_repls() {
    oso_repl_build_rust
    oso_repl_build_go
    oso_repl_build_java
    oso_repl_build_js
    oso_repl_build_python
    oso_repl_build_ruby
}
oso_clone_build_repls() {
    oso_clone
    oso_repl_build_rust
    oso_repl_build_go
    oso_repl_build_java
    oso_repl_build_js
    oso_repl_build_python
    oso_repl_build_ruby
}
oso_build_repls_from_branch() {
    cd ~/git
    git clone $1
    cd oso
    git checkout $2
    oso_build_repls
}
oso_repl_go() {
    (
        cd ${OSO_GIT_HOME}/languages/go
        ./oso
    )
}
oso_repl_java() {
    (
        cd ${OSO_GIT_HOME}/languages/java
        make repl
    )
}
oso_repl_js() {
    /usr/bin/oso
}
oso_repl_python() {
    (
        cd ${OSO_GIT_HOME}/languages/python
        python -m oso
    )
}
oso_repl_ruby() {
    (
        cd ${OSO_GIT_HOME}/languages/ruby
        bundle exec oso
    )
}
oso_repl_rust() {
    (
        cd ${OSO_GIT_HOME}
        cargo run --features=cli
    )
}
