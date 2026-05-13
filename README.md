# Network Automation Articles

Companion code and assets for my technical articles on **Cisco data center networking**, **Ansible automation**, and **AI applied to networks**.

Each folder corresponds to one published article and contains a working, runnable example you can adapt to your environment. Every playbook here is idempotent by design — you can run them twice on the same input and the second run reports `changed=0`.

## 📚 Articles

| # | Title | Folder | Pillar | Medium |
|---|---|---|---|---|
| 01 | Idempotencia en Ansible: del CSV al fabric ACI con EPGs, BDs y Static Bindings | [`01-csv-aci-idempotencia/`](./01-csv-aci-idempotencia/) | Automation + ACI | *Coming soon* |

> **Series in progress** — *Idempotencia en Ansible & ACI* (3 posts):
> 1. ✅ Provisioning from CSV (this repo: `01-csv-aci-idempotencia/`)
> 2. ⏳ Pre-change validation with `check_mode` and CI gates
> 3. ⏳ Troubleshooting the 5 most common failure modes

## 🚀 How to use the code

Each article folder has its own `README.md` with prerequisites, environment variables, and run instructions. General pattern:

```bash
cd <article-folder>/
cat README.md          # read article-specific instructions
export APIC_HOST=...   # set environment variables as documented
ansible-playbook <playbook>.yml --check --diff   # dry run first
ansible-playbook <playbook>.yml                  # real run
```

The code is intentionally simple and self-contained so you can copy-adapt it into your own automation projects. If you build something on top of it, I'd love to hear about it.

## 🧱 Repository conventions

- One folder per article, prefixed with the article number (`01-`, `02-`, ...).
- All playbooks are **idempotent**. If a second run on the same input reports any change, that's a bug.
- Credentials are **never** committed — they're always read from environment variables.
- Each folder includes sample outputs in `outputs/` so you can see what to expect before running anything.

## 👤 About

Javier Soto Zúñiga — Consulting Engineer at Cisco, focused on data center networks, automation, and applied data science.

- 🌐 **Website:** [jasotozuniga.cl](https://jasotozuniga.cl)
- ✍️ **Medium:** [medium.com/@javiers](https://medium.com/@javiers) *(actualizar handle real)*
- 💼 **LinkedIn:** [linkedin.com/in/javiersotozuniga](https://linkedin.com/in/javiersotozuniga) *(actualizar handle real)*

## 📄 License

MIT — see [LICENSE](./LICENSE). Use, fork, adapt, share. Attribution appreciated but not required.
