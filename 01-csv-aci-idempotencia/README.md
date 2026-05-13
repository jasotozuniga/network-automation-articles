# 01 — Idempotencia en Ansible: del CSV al fabric ACI

Companion code for the Medium article:
**Idempotencia en Ansible: del CSV al fabric ACI con EPGs, Bridge Domains y Static Bindings**.

📖 [Read the article on Medium](TBD) — *link will be added after publication*
🌐 [More articles at jasotozuniga.cl](https://jasotozuniga.cl)

---

## What this code does

Provisions **Bridge Domains, EPGs, and Static Bindings** in a Cisco ACI fabric from a CSV source-of-truth, with full idempotency. Running the playbook twice with the same CSV produces zero changes on the fabric — the second run reports `changed=0`.

This is the foundation for the rest of the *Idempotencia en Ansible & ACI* series:

1. ✅ **Provisioning from CSV** (this folder)
2. ⏳ Pre-change validation with `check_mode` and CI gates
3. ⏳ Troubleshooting the 5 most common failure modes

---

## Requirements

- **Ansible Core** ≥ 2.13
- **Python** ≥ 3.9
- A **Cisco ACI fabric** (or lab) running APIC ≥ 4.x
- The `cisco.aci` and `community.general` collections

Install collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

---

## Environment variables

The playbook reads APIC credentials from the environment to keep secrets out of Git:

```bash
export APIC_HOST="apic.lab.example.com"
export APIC_USER="admin"
export APIC_PASS="changeme"
```

> **Never commit credentials.** The `.gitignore` already excludes the obvious files, but verify before pushing.

---

## Run it

```bash
# Dry run — shows what would change without touching the fabric
ansible-playbook provision_aci.yml --check --diff

# Real run
ansible-playbook provision_aci.yml

# Verbose mode — see the REST calls the module makes
ansible-playbook provision_aci.yml -vv
```

Expected behavior:

- **First run** (empty tenant): `changed=4`
- **Second run** (same CSV): `changed=0` ✅
- **Third run** (CSV with one new binding): `changed=1` — exactly the delta

See [`outputs/`](./outputs/) for full sample outputs.

---

## File structure

```
01-csv-aci-idempotencia/
├── README.md                       # This file
├── requirements.yml                # Ansible collections needed
├── ansible.cfg                     # Minimal config for working against APIC
├── aci_objects.csv                 # Source of truth: tenants, BDs, EPGs, bindings
├── provision_aci.yml               # Main playbook (BD + Subnet + EPG + Binding)
├── aci_rest_validation.yml         # Post-deploy validation snippet
├── .pre-commit-config.yaml         # Pre-commit hook to gate CSV changes
├── outputs/                        # Sample outputs referenced in the article
│   ├── run1.txt                    # First run output
│   ├── run2.txt                    # Second run (changed=0)
│   ├── run3.txt                    # Third run with one new binding
│   ├── check-diff.txt              # `--check --diff` preview
│   ├── verbose-rest-calls.txt      # `-vv` showing REST GETs and POSTs
│   ├── audit-log-diff.txt          # APIC audit log comparison
│   ├── error-vpc-one-leaf.txt      # Module error when vpc has one leaf
│   └── validation-output.txt       # Output of the post-deploy validation
└── diagrams/
    └── rest-idempotent-flow.txt    # ASCII diagram of GET → diff → POST flow
```

---

## The CSV — input format

12 columns. Each row represents **one static binding**; BDs and EPGs are deduplicated by the playbook before being created.

| Column | Description | Example |
|---|---|---|
| `tenant` | ACI tenant | `PRD-FIN` |
| `vrf` | VRF inside the tenant | `VRF-PRD` |
| `bd_name` | Bridge Domain name | `BD-DB-PROD` |
| `bd_subnet` | BD gateway + mask | `10.10.10.1/24` |
| `app_profile` | Application Profile | `AP-DB` |
| `epg_name` | EPG name | `EPG-DB-PROD` |
| `encap` | VLAN encap | `vlan-100` |
| `pod_id` | ACI pod ID | `1` |
| `leafs` | Leaf(s); use `-` for vPC pair | `101-102` |
| `interface` | Port or Interface Policy Group | `IPG-vPC-DB-01` or `eth1/15` |
| `interface_type` | `vpc` / `switch_port` / `port_channel` | `vpc` |
| `mode` | `access` / `trunk` / `native` | `trunk` |

### Extending the CSV

The most commonly added columns in production:

- `scope` (private/public/shared) of the BD
- `arp_flooding`, `unicast_routing`, `mac_address`
- `description`, `physical_domain`
- `deploy_immediacy` (per-binding)

Adding any of them is mechanical: add the column to the CSV and the corresponding parameter to the relevant task in `provision_aci.yml`.

---

## How idempotency works under the hood

Each `cisco.aci.aci_*` module does a `GET` to the object's DN in the APIC **before** any `POST`. It compares the returned attributes against your task parameters:

- If they match → no POST is sent. Reports `changed=False`.
- If they differ → POST sent only with the attributes to modify.

See [`diagrams/rest-idempotent-flow.txt`](./diagrams/rest-idempotent-flow.txt) for the full flow.

The same pattern applies to `fvBD`, `fvAEPg`, and `fvRsPathAtt` (the MO of a static binding). The only thing that changes is the DN queried.

---

## Trade-offs to be aware of

1. **One-way sync.** The CSV declares what *must exist*, not what *must not exist*. Removing a row does not delete the object from APIC. Bidirectional sync requires a different pattern (covered in a future post).
2. **Performance.** Each task is one or two HTTP calls in series. Fine for 50–100 objects, painful for 5,000+. For larger fabrics, look into `async` + `poll` + batching.
3. **Module coverage ~95%.** For the rare cases the dedicated modules don't cover, you'll fall back to `cisco.aci.aci_rest` and manage idempotency yourself with `status: created,modified`.

---

## License

MIT — see [`../LICENSE`](../LICENSE).
