//go:build cgo
// +build cgo

package main

/*
#include <stdlib.h>
#include <stdio.h>

void f() {}
*/
import "C"

import (
	"fmt"
	"os"
)

func main() {
	C.f()

	fmt.Println("Temporary Directory:", os.TempDir())
}
