package main

import os "core:os/os2"
import    "core:fmt"
import io "core:io"
import "core:bufio"

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
	defer os.close(p.pipes.stdin_write)
	
	messages := [3]string{"hellope", "subprocess", "here"}

	for msg in messages {
		message_process(msg, p.pipes)
		response := read_line(p.pipes.stdout_read)
		fmt.print(response)
	}
	message_process("quit\n", p.pipes)
	response := read_line(p.pipes.stdout_read)
	fmt.print("Final response: ", response)
	_,_= os.process_wait(p.process)
	return
}

read_line :: proc(pipe: ^os.File) -> string {
	r: bufio.Reader
	buffer: [1024]byte
	bufio.reader_init_with_buf(&r, pipe.stream, buffer[:])
	defer bufio.reader_destroy(&r)
	
	msg, err := bufio.reader_read_string(&r, '\n', context.allocator)
	if err != nil {
		os.print_error(os.stderr, err, "failed to read from pipe")
	}
	return msg
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
			command = {process_name},
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