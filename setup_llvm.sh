# The location that contains the llvm and clang mirrors.
REPO_BASE=https://github.com/llvm-mirror
LLVM_REPO=${REPO_BASE}/llvm
CLANG_REPO=${REPO_BASE}/clang
# Where are we going to install LLVM?  The script will create an llvm and
# llvm-release subdirectory of this directory.
INSTALL_PREFIX=/auto/groups/acs-software/L25/
# Which git tag are we going to build?
RELEASE=release_50

git clone ${LLVM_REPO}
cd llvm
git checkout ${RELEASE}
cd tools
git clone ${CLANG_REPO}
cd clang
git checkout ${RELEASE}
cd ../..
mkdir Debug
cd Debug
cmake .. -G Ninja -DLLVM_ENABLE_RTTI=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}/llvm -DLLVM_BUILD_UTILS=ON -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=ON -DLLVM_INSTALL_UTILS=ON
ninja install
cd ..
mkdir Release
cd Release
cmake .. -G Ninja -DLLVM_ENABLE_RTTI=ON -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}/llvm-release -DLLVM_BUILD_UTILS=ON -DCMAKE_BUILD_TYPE=Release -DLLVM_INSTALL_UTILS=ON
ninja install
