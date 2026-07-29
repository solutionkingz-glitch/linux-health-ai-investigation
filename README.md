# Linux Server Health Monitoring & AI-Assisted Incident Response

A hands-on DevOps project that combines **Linux health monitoring, Bash automation, Cron, AWS EC2, Amazon SNS, IAM, and Claude Code** to detect, investigate, remediate, and verify Linux server incidents.

The project demonstrates a practical operational workflow:

**Monitor → Detect → Alert → Investigate → Analyse → Remediate → Verify**

---

## 📌 Project Overview

A server can be online and still be unhealthy.

An EC2 instance may remain reachable while:

* Nginx is stopped
* Port 80 is unavailable
* HTTP requests are failing
* CPU load is elevated
* Memory usage is high
* Disk or inode usage is too high
* System services have failed
* Unexpected system errors appear in the logs
* Failed SSH authentication attempts require investigation

To address this, I built a **Linux Server Health Check** Bash script that evaluates multiple aspects of an Ubuntu server and classifies its overall condition as:

```text
HEALTHY
WARNING
CRITICAL
```

The project then connects this monitoring workflow with **Cron for scheduled execution**, **Amazon SNS for alerting**, and **Claude Code for AI-assisted incident investigation**.

---

##  Architecture

```text
                         AWS EC2
                       Ubuntu Server
                            │
                            ▼
                  Linux Health Check
                     Bash Script
                            │
                ┌───────────┴───────────┐
                │                       │
             Manual                   Cron
             Check                  Every 5 min
                │                       │
                └───────────┬───────────┘
                            ▼
                     Health Evaluation
                            │
              ┌─────────────┼─────────────┐
              │             │             │
           HEALTHY       WARNING       CRITICAL
                            │             │
                            └──────┬──────┘
                                   ▼
                              Amazon SNS
                                   │
                                   ▼
                              Email Alert
                                   │
                                   ▼
                        Incident Investigation
                                   │
                                   ▼
                              Claude Code
                                   │
                         Gather → Analyse
                                   │
                              Recommend
                                   │
                                   ▼
                              Remediate
                                   │
                                   ▼
                               Verify
                                   │
                                   ▼
                          Incident Resolved
```

---

##  Health Monitoring

The Bash health-check script performs multiple server health checks, including:

* Nginx service status
* Port 80 availability
* HTTP response status
* CPU load
* Memory usage
* Disk usage
* Inode usage
* Failed system services
* Recent system errors
* Failed SSH login attempts

The script assigns an overall health state using explicit exit codes:

```text
HEALTHY = 0
WARNING = 1
CRITICAL = 2
```

This allows the script to be used both manually and as part of an automated monitoring workflow.

---

##  Automated Monitoring with Cron

The health-check script is scheduled using **Cron** to run automatically every five minutes.

This provides continuous monitoring without requiring an engineer to execute the script manually.

The workflow is:

```text
Cron
  ↓
Health Check Script
  ↓
Evaluate Server
  ↓
HEALTHY / WARNING / CRITICAL
  ↓
Log Result
  ↓
Alert When Intervention Is Required
```

Health-check results are written to log files for later investigation and troubleshooting.

---

##  Alerting with Amazon SNS

The project uses **Amazon SNS** to deliver notifications when significant health conditions require attention.

The operational flow is:

```text
Server Health Check
        ↓
   Health Status
        ↓
    SNS Alert
        ↓
   Email Notification
        ↓
Incident Investigation
```

This demonstrates how Linux server monitoring can be integrated with AWS notification infrastructure.

---

##  AI-Assisted Incident Investigation

A key part of this project is the use of **Claude Code** as an incident investigation assistant.

The investigation workflow is structured around:

```text
Gather → Analyse → Recommend → Verify
```

Claude Code assists with:

1. Gathering relevant system information
2. Analysing observed symptoms
3. Identifying the most likely root cause
4. Recommending diagnostic commands
5. Supporting the troubleshooting process
6. Reviewing evidence after remediation

The workflow is **AI-assisted rather than fully autonomous**. The engineer remains responsible for validating the findings and executing corrective actions.

---

##  Incident Scenario

To test the monitoring and investigation workflow, an Nginx failure was simulated.

The health check detected a critical condition involving:

* Nginx not running
* Port 80 not listening
* HTTP health check returning failure
* Other system resources remaining healthy

This evidence indicated that the problem was primarily related to the Nginx service rather than a broader server resource failure.

Claude Code analysed the evidence and identified the most likely root cause as the Nginx service being stopped.

It then recommended a structured diagnostic sequence, including:

```bash
systemctl status nginx
ps aux | grep nginx
sudo tail -n 50 /var/log/nginx/error.log
sudo journalctl -u nginx
sudo nginx -t
which nginx
```

These commands provide evidence for determining whether the issue is related to the service state, running processes, configuration, logs, or the Nginx installation.

---

##  Remediation

After confirming that Nginx was stopped, the service was restarted using:

```bash
sudo systemctl restart nginx
```

The server was then checked again to confirm that Nginx had recovered and that the HTTP health check was functioning normally.

The important operational principle demonstrated here is:

**Don't assume the fix worked — verify it.**

---

## ✅ Verification

After remediation, the health-check workflow was used to verify recovery.

The incident lifecycle was:

```text
CRITICAL
   ↓
Investigate
   ↓
Identify Nginx failure
   ↓
Restart Nginx
   ↓
Run Health Check
   ↓
HEALTHY
```

This closes the incident-response cycle by confirming that the corrective action actually restored service health.

---

##  Investigation Evidence

The repository contains a curated set of screenshots documenting the implementation, monitoring states, alerting, and AI-assisted investigation.

The evidence is available in the [`screenshots/`](screenshots/) directory.

| Evidence                      | Demonstrates                          |
| ----------------------------- | ------------------------------------- |
| Healthy baseline              | Normal server condition               |
| Warning state                 | Health-check warning classification   |
| Critical incident             | Nginx failure detection               |
| Claude investigation workflow | Gather → Analyse → Recommend → Verify |
| Claude root-cause analysis    | AI-assisted incident analysis         |
| Diagnostic recommendations    | Structured troubleshooting sequence   |
| SNS alert                     | AWS notification workflow             |
| Cron schedule                 | Automated monitoring                  |
| Health-check script           | Bash monitoring implementation        |
| Health-check results          | Monitoring output                     |
| Validation                    | Post-remediation verification         |

---

##  Technologies Used

| Technology       | Purpose                                   |
| ---------------- | ----------------------------------------- |
| **AWS EC2**      | Linux server infrastructure               |
| **Ubuntu Linux** | Server operating system                   |
| **Bash**         | Health-check automation                   |
| **Cron**         | Scheduled monitoring                      |
| **Nginx**        | Web server monitored by the health checks |
| **Amazon SNS**   | Alerting and email notification           |
| **AWS IAM**      | AWS access control                        |
| **Claude Code**  | AI-assisted incident investigation        |
| **Git & GitHub** | Version control and project documentation |

---

##  DevOps Skills Demonstrated

This project demonstrates practical experience with:

* Linux system administration
* Bash scripting and automation
* Linux service management
* Process troubleshooting
* Network and HTTP health checks
* Log investigation
* Cron scheduling
* AWS EC2 operations
* Amazon SNS alerting
* IAM fundamentals
* Incident detection
* Incident response
* Root-cause analysis
* AI-assisted troubleshooting
* Service remediation
* Post-remediation verification
* Git version control
* Technical documentation

---

##  End-to-End Incident Response Workflow

```text
                  ┌──────────────┐
                  │  Linux EC2   │
                  │    Server    │
                  └──────┬───────┘
                         │
                         ▼
                ┌─────────────────┐
                │ Bash Health     │
                │ Check           │
                └────────┬────────┘
                         │
                         ▼
                 ┌───────────────┐
                 │ Health Status │
                 └───────┬───────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
           HEALTHY    WARNING    CRITICAL
                                    │
                                    ▼
                              ┌───────────┐
                              │    SNS    │
                              │   Alert   │
                              └─────┬─────┘
                                    │
                                    ▼
                              Investigation
                                    │
                                    ▼
                              Claude Code
                                    │
                         Gather → Analyse
                                    │
                                Recommend
                                    │
                                    ▼
                               Remediate
                                    │
                                    ▼
                                 Verify
                                    │
                                    ▼
                              RESOLVED
```

---

## 📁 Repository Structure

```text
linux-health-ai-investigation/
│
├── CLAUDE.md
├── linux-health-check.sh
├── README.md
│
└── screenshots/
    ├── 01-healthy-baseline.png
    ├── 02-warning-state.png
    ├── 03-critical-incident.png
    ├── 04-claude-investigation-workflow.png
    ├── 05-claude-root-cause-analysis.png
    ├── 06-claude-diagnostic-recommendations.png
    ├── 07-sns-alert.png
    ├── 08-cron-scheduled-check.png
    ├── 09-health-check-script.png
    ├── 10-health-check-results.png
    ├── 11-health-check-validation.png
    └── README.md
```

---

##  Key Takeaway

This project demonstrates more than simply writing a Bash script.

It shows how a DevOps engineer can combine **Linux monitoring, automation, cloud services, alerting, structured troubleshooting, AI-assisted investigation, remediation, and verification** into a practical incident-response workflow.

The objective is not simply to detect that something is wrong, but to establish a repeatable process for understanding:

**What failed → Why it failed → How to fix it → How to verify the recovery**

This approach reflects the operational mindset required for reliable DevOps and cloud infrastructure management.
