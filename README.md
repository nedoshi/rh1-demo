# Trusted Supply Chain Demo Scenarios

This directory contains three comprehensive demo scenarios showcasing different aspects of trusted supply chain security.

## Demo Overview

### Demo 1: "The Compromised Dependency Crisis"
**Duration**: 8-10 minutes  
**Focus**: Vulnerability detection, SBOM generation, VEX documentation, admission control

Simulates a realistic supply chain attack where a compromised dependency is detected and blocked before deployment.

**Key Features**:
- Automated SBOM generation with Trusted Profile Analyzer
- VEX documentation for vulnerability communication
- Admission webhook blocking vulnerable images
- Split-screen demonstration (vulnerable vs. remediated)

**Location**: `demo1-compromised-dependency/`

---

### Demo 2: "GenAI Model Poisoning Prevention"
**Duration**: 10-12 minutes  
**Focus**: AI model security, cryptographic signing, RBAC, runtime monitoring

Addresses AI security by demonstrating how to detect and prevent compromised models from being deployed.

**Key Features**:
- Model artifact cryptographic signing
- RBAC enforcement (data scientists vs. ML engineers)
- Runtime monitoring for anomalous behavior
- Real-time malicious prompt injection detection

**Location**: `demo2-genai-poisoning/`

---

### Demo 3: "Multi-Cloud Compliance Audit in 60 Seconds"
**Duration**: 5-7 minutes (including 60-second report generation)  
**Focus**: Compliance automation, multi-cloud aggregation, audit trail generation

Demonstrates how to generate a complete audit trail in under 60 seconds that would normally take days.

**Key Features**:
- Multi-cloud artifact aggregation (AWS, Azure, OpenShift)
- Complete SBOM lineage generation
- VEX statement collection
- NIST SSDF compliance verification
- Automated compliance report generation

**Location**: `demo3-compliance-audit/`

---

## Quick Start

### Prerequisites

All demos require:
- OpenShift 4.x cluster
- `oc` CLI installed and configured
- Cluster admin or sufficient permissions
- Required operators installed (see individual demo READMEs)

### Running Demos

Each demo has its own directory with a `run-demo.sh` script:

```bash
# Demo 1: Compromised Dependency
cd demo1-compromised-dependency
./scripts/run-demo.sh

# Demo 2: GenAI Model Poisoning
cd demo2-genai-poisoning
./scripts/run-demo.sh

# Demo 3: Compliance Audit
cd demo3-compliance-audit
./scripts/run-demo.sh
```

### Individual Steps

Each demo can also be run step-by-step:

```bash
# Example: Demo 1
cd demo1-compromised-dependency
./scripts/01-setup-vulnerable-app.sh
./scripts/02-build-and-scan.sh
./scripts/03-simulate-vulnerability.sh
./scripts/04-demonstrate-blocking.sh
./scripts/05-remediate-and-approve.sh
```

## Demo Structure

Each demo follows a consistent structure:

```
demoX-<name>/
├── README.md              # Demo documentation
├── scripts/               # Demo automation scripts
│   ├── run-demo.sh        # Main demo script
│   └── 0X-*.sh           # Individual step scripts
├── configs/               # Kubernetes configurations
├── app-source/           # Application source code (Demo 1)
├── models/               # Model artifacts (Demo 2)
├── dashboard/            # Dashboard configurations
├── monitoring/           # Monitoring setup (Demo 2)
├── security-assistant/    # Security assistant (Demo 2)
├── admission-webhook/    # Admission controller (Demo 1)
├── report-generator/     # Report generation (Demo 3)
└── multi-cloud/          # Multi-cloud connectors (Demo 3)
```

## Common Technologies

All demos utilize:
- **Trusted Artifact Signer (RHTAS)**: Cryptographic signing
- **Trusted Profile Analyzer**: SBOM generation
- **OpenShift Pipelines (Tekton)**: CI/CD automation
- **OpenShift GitOps (ArgoCD)**: GitOps workflows
- **Admission Controllers**: Policy enforcement
- **RBAC**: Role-based access control

## Demo Selection Guide

Choose a demo based on your audience:

- **Security Teams**: Demo 1 (vulnerability detection)
- **AI/ML Teams**: Demo 2 (model security)
- **Compliance/Audit Teams**: Demo 3 (compliance automation)
- **Executive/Management**: Demo 3 (quick ROI demonstration)

## Troubleshooting

### Common Issues

1. **Operators not ready**: Wait for operators to be fully installed
2. **Permission errors**: Ensure cluster-admin or sufficient permissions
3. **Image pull errors**: Check image pull secrets and SCC permissions
4. **Webhook not working**: Verify webhook service is running

### Getting Help

- Check individual demo README files for specific troubleshooting
- Review script output for error messages
- Check pod logs: `oc logs -n <namespace> <pod-name>`

## Next Steps

After running the demos:
1. Explore the dashboard UIs
2. Review generated reports and attestations
3. Customize configurations for your environment
4. Integrate with your existing workflows

---

**Note**: These demos are designed for demonstration purposes. For production use, additional security hardening, authentication, and monitoring should be implemented.


