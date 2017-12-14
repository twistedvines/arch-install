.PHONY: test clean_scripts clean_boxes clean build_test_vm destroy_test_vm

test: build_test_vm prepare_environment
	./test/run_tests.sh
	make clean_scripts
	make clean_boxes
	make destroy_test_vm

destroy_test_vm:
	cd ./test && vagrant destroy -f

build_test_vm:
	./test/build_test_vm.sh

prepare_environment:
	./test/prepare_environment.sh

clean_scripts:
	rm -rf ./.cache/packer-archlinux/scripts/arch-install-scripts/*
clean_boxes:
	rm ./.cache/packer-archlinux/build/*
clean:
	rm -rf ./.cache/
