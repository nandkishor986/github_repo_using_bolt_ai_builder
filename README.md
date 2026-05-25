# VM Health Check Script

A lightweight and efficient shell script designed to monitor the health of Ubuntu virtual machines by analyzing critical system resources in real-time.

## Overview

This project delivers a robust health monitoring solution for Ubuntu VMs, providing instant visibility into system performance. The script intelligently evaluates CPU, memory, and disk utilization against configurable thresholds, delivering clear, actionable health status reports.

Built with simplicity and reliability in mind, this tool requires no external dependencies and runs seamlessly on any standard Ubuntu installation. It's perfect for system administrators, DevOps engineers, and anyone managing virtual machine infrastructure.

## Key Achievements

### Streamlined Development with Bolt.new

This entire project was conceptualized and developed using **bolt.new**, an exceptional AI-powered development platform. The experience demonstrated bolt.new's capability to:

- Rapidly prototype and iterate on system-level tools
- Generate production-ready shell scripts with proper error handling
- Provide intelligent suggestions for optimization and best practices
- Accelerate the entire development lifecycle from concept to deployment

The result is a polished, production-grade monitoring script that would traditionally take hours to develop, completed in a fraction of that time thanks to bolt.new's sophisticated AI assistance.

### Production-Grade Code Quality

Every line of code was crafted with real-world usage in mind:

- **Robust threshold logic** prevents false alarms while catching genuine issues
- **Precise CPU calculation** using dual-read methodology for accuracy
- **Memory-aware design** handles both modern and legacy Ubuntu systems
- **Clean exit codes** enable seamless integration with automation tools

### Comprehensive Documentation

The script includes thorough inline documentation and this README, ensuring maintainability and ease of understanding for future developers or system administrators.

## Features

### Real-Time Resource Monitoring

- **CPU Usage**: Calculates actual CPU utilization by comparing system statistics over time, providing accurate readings that avoid the pitfalls of single-point sampling
- **Memory Usage**: Intelligently queries available memory, accounting for buffers and cache to reflect true system availability
- **Disk Usage**: Monitors root filesystem utilization, the most critical metric for VM stability

### Flexible Reporting Modes

- **Standard mode**: Quick health check with binary status output (Healthy/Not Healthy)
- **Explain mode**: Detailed breakdown showing exact resource percentages, threshold violations, and actionable recommendations

### Threshold-Based Health Assessment

Default threshold of 60% ensures the VM has adequate headroom for:

- Traffic spikes and load variations
- Background maintenance operations
- Unexpected resource demands
- Graceful degradation scenarios

## Installation

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/vm-health-check.git
   cd vm-health-check
   ```

2. Make the script executable:
   ```bash
   chmod +x vm-health-check.sh
   ```

3. Run your first health check:
   ```bash
   ./vm-health-check.sh
   ```

### System Requirements

- Ubuntu 16.04 LTS or later (should work on most Debian-based systems)
- Bash shell (version 4.0 or higher recommended)
- Standard system utilities (awk, grep, df) - pre-installed on Ubuntu

## Usage

### Basic Health Check

```bash
./vm-health-check.sh
```

Returns exit code 0 if healthy, exit code 1 if unhealthy. Perfect for cron jobs and automation pipelines.

### Detailed Health Report

```bash
./vm-health-check.sh explain
```

Provides comprehensive output including:

- Current resource utilization percentages
- Which resources exceed thresholds
- Specific remediation recommendations
- Clear visual indicators for problem areas

### Integration Examples

**Cron Job for Regular Monitoring:**
```bash
*/15 * * * * /path/to/vm-health-check.sh || echo "VM health check failed" | mail -s "VM Alert" admin@example.com
```

**CI/CD Pipeline Integration:**
```bash
./vm-health-check.sh && echo "Deployment environment healthy" || exit 1
```

**Monitoring System Integration:**
```bash
while true; do
    ./vm-health-check.sh
    sleep 300
done
```

## Configuration

### Adjusting Thresholds

Open `vm-health-check.sh` and modify the `THRESHOLD` variable at the top of the script:

```bash
THRESHOLD=60  # Default value
```

Recommended values:

- **40-50%**: Strict monitoring for critical production systems
- **60-70%**: Balanced approach for standard workloads
- **75-85%**: Relaxed thresholds for burst-tolerant applications

### Modifying Behavior

The script is designed for easy customization:

- Change monitored filesystem by editing the `df /` command
- Add additional metrics by following the existing pattern
- Customize output format to match your monitoring infrastructure

## Understanding the Metrics

### CPU Usage Calculation

The script employs a sophisticated dual-read approach:

1. Reads `/proc/stat` for initial CPU metrics
2. Waits 0.5 seconds
3. Reads `/proc/stat` again
4. Calculates the actual CPU time spent working vs. idling

This method provides far more accurate results than single-point sampling, as it captures genuine CPU activity over a time window rather than instantaneous state.

### Memory Usage Interpretation

The script uses `MemAvailable` when present (modern Ubuntu kernels), which correctly accounts for:

- Free memory
- Reclaimable buffer/cache
- Memory available without swap

For older systems, it falls back to calculating available memory from multiple `/proc/meminfo` fields, ensuring compatibility across Ubuntu versions.

### Disk Usage Criticality

Root filesystem monitoring captures the most vital storage metric, as exhaustion leads to:

- Inability to write logs
- Service failures
- System instability
- Potential data corruption

## Best Practices

### Monitoring Schedule

- **Development VMs**: Check every 30-60 minutes
- **Production Servers**: Check every 5-15 minutes
- **Critical Infrastructure**: Check every 1-5 minutes with alert routing

### Alert Thresholds

Consider multi-tier thresholds:

- **Warning (50%)**: Log and monitor, no alerts
- **Critical (70%)**: Send notifications to operations team
- **Emergency (85%)**: Automatic escalation and remediation attempts

### Combination with Other Tools

This script excels as part of a larger monitoring strategy:

- Combine with log aggregation (ELK stack, Splunk)
- Feed metrics into time-series databases (Prometheus, InfluxDB)
- Trigger alerts through notification systems (PagerDuty, Slack)

## Contributing

Contributions are welcome! Areas for enhancement:

- Network connectivity checks
- Process-specific monitoring
- Historical data persistence
- Integration with popular monitoring APIs
- Support for additional Linux distributions

Please submit pull requests or open issues for any improvements.

## License

This project is open source and available under the MIT License. Feel free to use, modify, and distribute as needed.

## Acknowledgments

Developed with the assistance of **bolt.new** - demonstrating how AI-powered development tools can accelerate and enhance traditional system administration tasks while maintaining code quality and best practices.

## Support

For questions, issues, or feature requests:

- Open a GitHub issue
- Review the inline code documentation
- Check the script's explain mode output for troubleshooting

---

**Note**: This script performs read-only operations and does not modify system state. It's safe to run at any frequency without side effects.
