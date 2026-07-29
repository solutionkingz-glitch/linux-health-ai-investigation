\# Linux Server Health Monitoring \& AI-Assisted Incident Response



A hands-on DevOps project that combines \*\*Linux health monitoring, Bash automation, Cron, AWS EC2, Amazon SNS, IAM, and Claude Code\*\* to detect, investigate, and verify Linux server incidents.



The project demonstrates a practical operational workflow:



\*\*Monitor → Detect → Investigate → Remediate → Verify\*\*



\---



\## 📌 Project Overview



A server can be online and still be unhealthy.



An EC2 instance may be reachable while:



\- Nginx is stopped

\- Port 80 is unavailable

\- The application is returning errors

\- CPU or memory resources are under pressure

\- Disk or inode usage is too high

\- System services have failed

\- Unexpected system errors appear in the logs

\- Suspicious SSH authentication activity occurs



To address this, I built a \*\*Linux Server Health Check\*\* Bash script that evaluates multiple aspects of an Ubuntu server and produces an overall health status:



```text

HEALTHY

WARNING

CRITICAL



\## 🏗️ Architecture



&#x20;                   AWS EC2

&#x20;                Ubuntu Server

&#x20;                     │

&#x20;                     ▼

&#x20;            Linux Health Check

&#x20;               Bash Script

&#x20;                     │

&#x20;         ┌───────────┴───────────┐

&#x20;         │                       │

&#x20;      Manual                   Cron

&#x20;      Check                  Every 5 min

&#x20;         │                       │

&#x20;         └───────────┬───────────┘

&#x20;                     ▼

&#x20;              Health Evaluation

&#x20;                     │

&#x20;         ┌───────────┼───────────┐

&#x20;         │           │           │

&#x20;      HEALTHY      WARNING    CRITICAL

&#x20;                     │           │

&#x20;                     └─────┬─────┘

&#x20;                           ▼

&#x20;                     Amazon SNS

&#x20;                           │

&#x20;                           ▼

&#x20;                      Email Alert

&#x20;                           │

&#x20;                           ▼

&#x20;                   Incident Investigation

&#x20;                           │

&#x20;                           ▼

&#x20;                      Claude Code

&#x20;                           │

&#x20;             Gather → Analyse → Recommend

&#x20;                           │

&#x20;                           ▼

&#x20;                         Verify

&#x20;                           │

&#x20;                           ▼

&#x20;                    Incident Resolved

