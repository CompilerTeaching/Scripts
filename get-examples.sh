#!/bin/sh
DIR=`dirname $0`
LLVM_VERSION=3.9.0
if [ -z $LLVM_RELEASE_DIR ] ; then
	LLVM_RELEASE_DIR=$DIR/llvm-release
fi
if [ -z $LLVM_DEBUG_DIR ] ; then
	LLVM_DEBUG_DIR=$DIR/llvm
fi
check_llvm()
{
	if [ ! -f $1/bin/llvm-config ] ; then
		echo LLVM $2 build does not exist at $1
		echo Please set \$$3 to the path of an LLVM $2 build
		exit 1
	fi
	if [ `$1/bin/llvm-config --build-mode` != $2 ] ; then
		echo LLVM build in $1 is a `$1/bin/llvm-config --build-mode` build, not a $2 build.
		echo Please set \$$3 to the path of an LLVM $2 build
		exit 1
	fi
	if [ `$1/bin/llvm-config --version` != ${LLVM_VERSION} ] ; then
		echo LLVM build in $1 is version `$1/bin/llvm-config --version`, not version ${LLVM_VERSION}
		echo Please set \$$3 to the path of an LLVM $2 build
		exit 1
	fi
}
check_llvm $LLVM_RELEASE_DIR Release LLVM_RELEASE_DIR
check_llvm $LLVM_DEBUG_DIR Debug LLVM_DEBUG_DIR
message()
{
	echo --------------------------------------------------------------------------------
	echo $@
	echo --------------------------------------------------------------------------------
}
build()
{
	cd $1
	message Beginning debug build of $1
	mkdir Debug 
	cd Debug 
	cmake .. \
		-DCMAKE_C_COMPILER=$LLVM_RELEASE_DIR/bin/clang \
		-DCMAKE_CXX_COMPILER=$LLVM_RELEASE_DIR/bin/clang++ \
		-DCMAKE_CXX_FLAGS=-Wno-unknown-warning-option \
		-DCMAKE_BUILD_TYPE=Debug \
		-DLLVM_CONFIG=$LLVM_DEBUG_DIR/bin/llvm-config\
		$2 \
		-G Ninja
	ninja
	message Running test suite...
	ctest -j8 --output-on-failure
	cd ../
	message Finished debug build of $1
	mkdir Release
	cd Release
	message Beginning release build of $1
	cmake .. \
		-DCMAKE_C_COMPILER=$LLVM_RELEASE_DIR/bin/clang \
		-DCMAKE_CXX_COMPILER=$LLVM_RELEASE_DIR/bin/clang++ \
		-DCMAKE_CXX_FLAGS=-Wno-unknown-warning-option \
		-DCMAKE_BUILD_TYPE=Release\
		-DLLVM_CONFIG=$LLVM_RELEASE_DIR/bin/llvm-config\
		$2 \
		-G Ninja
	ninja
	cd ../..
	message Finished release build of $1
}
message Cloning SimplePass
git clone https://github.com/CompilerTeaching/SimplePass.git
build SimplePass
message Cloning CellularAutomata
git clone --recursive https://github.com/CompilerTeaching/CellularAutomata.git
build CellularAutomata -DENABLE_TESTS=ON
message Cloning MysoreScript
git clone --recursive https://github.com/CompilerTeaching/MysoreScript.git
build MysoreScript -DENABLE_TESTS=ON

echo 
echo 
echo 
echo --------------------------------------------------------------------------------
echo Finished downloading examples
echo '  * SimplePass: An example LLVM pass to extend'
echo '  * CellularAutomata: A simple parallel language'
echo '  * MysoreScript: A simple late-bound dynamic language'
echo 
echo All examples are built using cmake.
echo Each example directory contains a Debug subdirectory containing a debug build a
echo and a Release subdirectory containing a release build.  You can rebuild either
echo of these by typing ninja in the relevant directory.
echo 
echo Each example directory is a git clone.  You are strongly encouraged to use git 
echo to checkpoint your own work on these!
echo 
echo To get updates, such as fixes for bugs discovered as the course runs, run
echo git pull --rebase in one of the example directories.
echo --------------------------------------------------------------------------------
