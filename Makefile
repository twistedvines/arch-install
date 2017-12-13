.PHONY: test clean_scripts clean_boxes clean

test: build_test_vm

build_test_vm:
	./test/build_test_vm.sh
	make clean_scripts

clean_scripts:
	rm -rf ./.cache/packer-archlinux/scripts/arch-install-scripts/*
clean_boxes:
	rm ./.cache/packer-archlinux/build/*
clean:
	rm -rf ./.cache/
