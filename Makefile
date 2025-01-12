.PHONY: build_example_process test clean

build_example_process:
	@echo "Building example_process..."
	odin build ./example_process/example_process.odin -file

test: build_example_process
	odin run .

clean:
	@echo "cleaning up"
	rm -f odin_process_example
	rm -f example_process.bin
	