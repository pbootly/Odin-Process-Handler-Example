package main

import os "core:os/os2"
import    "core:fmt"

SubProcess :: struct {
	process: os.Process,
	pipes: ProcessPipes
}

ProcessPipes :: struct {
	stdout_read: ^os.File,
	stdout_write: ^os.File,
	stdin_read: ^os.File,
	stdin_write: ^os.File,
}

main :: proc() {
	p, err := start_process("example_process.bin");
	
	if err != nil {
		os.print_error(os.stderr, err, "failed to execute process")
	}
	
	defer os.close(p.pipes.stdout_write)
	defer os.close(p.pipes.stdin_read)

	// TODO: read back response without needing write closure (app ending on quit working)
	//message_process("hello\n", p.pipes)
	message_process("quit\n", p.pipes)
	os.close(p.pipes.stdin_write)
	
	output, _ := os.read_entire_file(p.pipes.stdout_read, context.temp_allocator)

	_,_= os.process_wait(p.process)
	fmt.print(string(output))
	return
		
}

message_process :: proc(msg: string, pipes: ProcessPipes) {
	message := transmute([]u8)msg
	_, err := os.write(pipes.stdin_write, message)
	if err != nil {
		fmt.eprintln("Process write error: ", err)
	}
}

start_process :: proc(process_name: string) -> (subprocess: SubProcess, err: os.Error) {

	stdout_read, stdout_write := os.pipe() or_return
	stdin_read, stdin_write := os.pipe() or_return
	p: os.Process; {
		defer os.close(stdout_write)
		p = os.process_start({
            working_dir = "./",
			command = {"example_process.bin"},
			stdout  = stdout_write,
			stdin   = stdin_read,
		}) or_return
	}
	sp := SubProcess {
		process = p,
		pipes = ProcessPipes {
			stdout_read = stdout_read,
			stdout_write = stdout_write,
			stdin_read = stdin_read,
			stdin_write = stdin_write,
		}
	}

	return sp, nil
}