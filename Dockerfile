FROM debian:buster AS build
WORKDIR /src
RUN \
    apt-get -qq update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y -qq install git g++ cmake ninja-build python3

RUN git clone https://github.com/llvm/llvm-project.git llvm && \
    cd llvm && git checkout e39d7884a1f5c5c7136ba2e493e9ac313ccc78ed && cd ..

RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/tmp/llvm -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;" -DLLVM_DISTRIBUTION_COMPONENTS="clang-format;clang-tidy" -G "Ninja" ../llvm/llvm && \
    cmake --build .

RUN cd build && \
    cmake --build . --target install-distribution

FROM debian:buster
COPY --from=build /tmp/llvm/ /usr/local/
VOLUME /src
WORKDIR /src
RUN apt-get -qq update && \                                                                                              
    export DEBIAN_FRONTEND=noninteractive && \                                                                           
    apt-get -y -qq install python3 && \
    apt-get -qq clean
