package example_process

import "core:fmt"
import "core:os"

/*
    Simple program to read stdin and repeat it back, effectively just a loop around:
    https://github.com/odin-lang/examples/blob/master/by_example/read_console_input/read_console_input.odin
    'quit' to return out
*/
main :: proc() {
    buf: [256]byte
    for {
        n, err := os.read(os.stdin, buf[:])
        if err != nil {
            fmt.eprintln("Error reading: ", err)
            return
        }
        str := string(buf[:n])
        if str == "quit\n" {
            fmt.println("quit received, exiting")
            return
        }
        fmt.println("Output: ", str)
    }
}