//go:build !cgo
// +build !cgo

package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("Temporary Directory:", os.TempDir())
}
