# If you have runtime memory issues, disable tcmalloc: add -DNO_TCMALLOC to the make line

ifeq ($(CPU_CORES),)
  CPU_CORES := $(shell nproc)
  ifeq ($(CPU_CORES),)
    CPU_CORES := 1
  endif
endif

PREFIX?=../publish

release:
	mkdir -p build/tests;
	mkdir -p build/dist;
	mkdir -p dist;
	cd build; cmake ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(PREFIX)/release
	$(MAKE) -C build

debug:
	mkdir -p dbuild/tests;
	mkdir -p dbuild/dist;
	mkdir -p dist;
	cd dbuild; cmake ../ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$(PREFIX)/debug
	$(MAKE) -C dbuild

test/unittest:
	mkdir -p build
	cd build && make UnitTests
	cd build && ctest --output-on-failure

test/regression:
	mkdir -p build/tests;
	cd build; ../tests/regression.tcl mt=0 show_diff

test: test/unittest test/regression

test-parallel: test/unittest
	mkdir -p build/tests; cd build; rm -rf test; mkdir test; cd test; ../../tests/cmake_gen.tcl; cmake .; time make -j $(CPU_CORES); cd ..; ../tests/regression.tcl diff_mode show_diff;

regression:
	mkdir -p build/tests; cd build; rm -rf test; mkdir test; cd test; ../../tests/cmake_gen.tcl; cmake .; time make -j $(CPU_CORES); cd ..; ../tests/regression.tcl diff_mode show_diff;

clean:
	rm -rf dist;
	if [ -d build ] ; then $(MAKE) -C build clean ; fi
	rm -rf build

install_debug:
	cd dbuild; make install

install_release:
	cd build; make install

test_install:
	cd tests/TestInstall ; rm -rf build; mkdir -p build; cd build; cmake ../ -DINSTALL_DIR=$(PREFIX); make ; ./test_hellosureworld --version

uninstall:
	rm -f  $(PREFIX)/bin/surelog
	rm -rf $(PREFIX)/lib/surelog
	rm -rf $(PREFIX)/include/surelog
