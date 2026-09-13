# AWS Zero-Trust Encrypted Storage & Audit Pipeline

Automated Infrastructure as Code (IaC) repository built with Terraform to deploy an enterprise-grade, Zero-Trust S3 storage environment with Customer Managed KMS envelope encryption, multi-region CloudTrail auditing, and strict public block guardrails.

---

## Architecture Security Controls

| Domain | Control | Implementation |
| :--- | :--- | :--- |
| **Data at Rest** | KMS Envelope Encryption | Customer Managed Key (CMK) with automated rotation & S3 Bucket Key enabled |
| **Data in Transit** | TLS 1.2+ Enforcement | Explicit Bucket Policy `Deny` condition for unencrypted HTTP traffic |
| **Access Control** | Zero Public Access | S3 Block Public Access (all 4 guardrails enabled) |
| **Audit Logging** | Continuous Compliance | Multi-region CloudTrail log validation targeting dedicated audit bucket |

---

## Threat Model & Risk Mitigations

- **Threat:** Public Data Exposure via Misconfigured S3 ACLs  
  **Mitigation:** S3 Block Public Access explicitly denies `PutObjectAcl` calls at the account/bucket boundary.
- **Threat:** Eavesdropping / Man-in-the-Middle (MitM) Attacks  
  **Mitigation:** Bucket policy strictly requires `aws:SecureTransport = true` (HTTPS only).
- **Threat:** Unauthorized S3 Data Modification / Ransomware  
  **Mitigation:** Bucket versioning enabled with dedicated KMS key policy enforcement.

---

## Deployment Instructions

### Prerequisites
- [Terraform 1.5+](https://www.terraform.io/)
- [AWS CLI v2](https://aws.amazon.com/cli/)

### Quickstart