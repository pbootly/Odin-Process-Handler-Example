# Odin-Process-Handler-Example

Simple example of using Odin to spawn a sub process (in this case another odin app), take a handle of stdin and stdout for the subprocess in order to be able to communicate with it.

Written naively in an effort to play with file handlers and buffered readers.

## Brain dump - notes for future me
> message_process :: proc(msg: string, pipes: ProcessPipes) {...}

Handles writing a message to subprocesses stdin [transmuting](https://odin-lang.org/docs/overview/#transmute-operator) the string to a []u8 before writing.

> read_line :: proc(pipe: ^os.File) -> string {...}

Uses a buffered reader similar to the [latter example](https://odin-lang.org/news/read-a-file-line-by-line/) from this article. Using a context.allocator as the message could go over the buffer, so we might need to join together.

> start_process :: proc(process_name: string) -> (subprocess: SubProcess, err: os.Error) {...}

Relies on os2's `os.process_start` to spawn the process and return the required pipes to communicate properly.

## Testing
Testing done with `Makefile` to run both processes
```odin
make test
Building example_process...
odin build ./example_process/example_process.odin -file
odin run .
Output:  hellope
Output:  subprocess
Output:  here
Final response:  quit received, exiting
```