package main

import os "core:os/os2"
import    "core:fmt"

main :: proc() {
	if err := run(); err != nil {
		os.print_error(os.stderr, err, "failed to execute run")
	}
}

run :: proc() -> (err: os.Error) {
	stdout_read, stdout_write := os.pipe() or_return
	defer os.close(stdout_write)
	
	stdin_read, stdin_write := os.pipe() or_return
	defer os.close(stdin_read)

	p: os.Process; {
		defer os.close(stdout_write)
		p = os.process_start({
            working_dir = "./",
			command = {"example_process.bin"},
			stdout  = stdout_write,
			stdin   = stdin_read,
		}) or_return
	}
	
	message := "quit\n"
	message_bytes := transmute([]u8)message
	_, err = os.write(stdin_write, message_bytes)
	if err != nil {
		fmt.eprintln("Writing error: ", err)
		return err
	}
	os.close(stdin_write) or_return

	output := os.read_entire_file(stdout_read, context.temp_allocator) or_return

	_ = os.process_wait(p) or_return

	fmt.print(string(output))
	return
}
