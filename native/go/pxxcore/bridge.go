package pxxcore

import (
	"errors"
	"sync"
)

var (
	mu      sync.Mutex
	running bool
)

// Start launches Mihomo with a prepared YAML config and a platform-owned TUN fd.
// The final implementation should embed or link Mihomo and pass tunFd into the
// platform adapter required by Android VpnService or iOS NetworkExtension.
func Start(configPath string, tunFd int) error {
	if configPath == "" {
		return errors.New("configPath is required")
	}

	mu.Lock()
	defer mu.Unlock()

	if running {
		return nil
	}

	// TODO: wire Mihomo's executor here after the mobile core package is vendored.
	running = true
	return nil
}

// Stop shuts down the Mihomo runtime.
func Stop() {
	mu.Lock()
	defer mu.Unlock()
	running = false
}

func IsRunning() bool {
	mu.Lock()
	defer mu.Unlock()
	return running
}
