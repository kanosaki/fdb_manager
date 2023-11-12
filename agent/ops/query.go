package ops

import (
	"context"
	"fmt"
	"net"
	"strconv"
)

type QueryProcessParam struct {
	// ProcessID is "ip:port" of the process in the FoundationDB
	ProcessIDs []string `form:"process_ids"`
}

type ProcessInfo struct {
	ProcessID string   `json:"process_id"`
	Note      string   `json:"note"`
	Hostname  string   `json:"hostname"`
	Port      int      `json:"port"`
	Hostnames []string `json:"hostnames"`
}

func QueryProcess(ctx context.Context, param *QueryProcessParam) ([]ProcessInfo, error) {
	var ret []ProcessInfo
	for _, processID := range param.ProcessIDs {
		ipAddr, portStr, err := net.SplitHostPort(processID)
		if err != nil {
			return nil, fmt.Errorf("invalid process id format: %w", err)
		}
		port, err := strconv.Atoi(portStr)
		if err != nil {
			return nil, fmt.Errorf("invalid port: %w", err)
		}
		hosts, err := net.LookupAddr(ipAddr)
		if err != nil {
			return nil, fmt.Errorf("failed to lookup hostname: %w", err)
		}
		if len(hosts) == 0 {
			return nil, fmt.Errorf("no hostname found")
		}
		ret = append(ret, ProcessInfo{
			ProcessID: processID,
			Hostname:  hosts[0],
			Port:      port,
			Hostnames: hosts,
		})
	}
	return ret, nil
}
