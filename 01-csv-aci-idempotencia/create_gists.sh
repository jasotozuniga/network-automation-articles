#!/usr/bin/env bash
# create_gists.sh
# Crea los 15 GitHub Gists necesarios para embeber en el post de Medium,
# usando los archivos de este mismo folder como fuente.
#
# Requisitos: gh CLI instalado y autenticado (gh auth status)
# Uso:        ./create_gists.sh   (desde dentro de 01-csv-aci-idempotencia/)
# Output:     gist_urls.txt con las 15 URLs en el orden en que aparecen en el artículo.

set -euo pipefail

cd "$(dirname "$0")"

# --- Sanity checks ---
if ! command -v gh &> /dev/null; then
  echo "❌ gh CLI no encontrado. Instalalo desde: https://cli.github.com/" >&2
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "❌ gh no está autenticado. Ejecuta: gh auth login" >&2
  exit 1
fi

# --- Confirmación ---
echo "⚠️  Este script va a crear 15 PUBLIC Gists en tu cuenta de GitHub."
echo "    Corre solo una vez por artículo (re-ejecutarlo crea duplicados)."
echo ""
read -r -p "¿Continuar? [y/N] " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Cancelado."
  exit 0
fi

OUTPUT="gist_urls.txt"
> "$OUTPUT"

create_gist() {
  local file="$1"
  local desc="$2"
  if [[ ! -f "$file" ]]; then
    echo "❌ Archivo no encontrado: $file" >&2
    exit 1
  fi
  echo "→ Creando gist para $file ..."
  local url
  url=$(gh gist create "$file" --public --desc "$desc" | tail -1)
  printf "%-42s  %s\n" "$file" "$url" | tee -a "$OUTPUT"
}

echo ""
echo "🚀 Creando 15 gists para Article 01 ..."
echo ""

# Orden = orden en que aparecen en el artículo publicado
create_gist "requirements.yml"                  "Article 01 — Ansible collections for ACI automation"
create_gist "ansible.cfg"                       "Article 01 — Minimal ansible.cfg for working against APIC"
create_gist "aci_objects.csv"                   "Article 01 — Source-of-truth CSV: BDs, EPGs, Static Bindings"
create_gist "provision_aci.yml"                 "Article 01 — Idempotent playbook: CSV → ACI (BD + EPG + Binding)"
create_gist "outputs/run1.txt"                  "Article 01 — First run output (changed=4)"
create_gist "outputs/run2.txt"                  "Article 01 — Second run output, same CSV (changed=0)"
create_gist "outputs/run3.txt"                  "Article 01 — Third run output with one new binding (changed=1)"
create_gist "outputs/check-diff.txt"            "Article 01 — Output of ansible-playbook --check --diff"
create_gist "outputs/verbose-rest-calls.txt"    "Article 01 — REST calls observed with -vv"
create_gist "diagrams/rest-idempotent-flow.txt" "Article 01 — Idempotency flow diagram (GET → diff → POST)"
create_gist "outputs/audit-log-diff.txt"        "Article 01 — APIC audit log: idempotent vs non-idempotent"
create_gist "outputs/error-vpc-one-leaf.txt"    "Article 01 — Module error when vpc binding has only one leaf"
create_gist "aci_rest_validation.yml"           "Article 01 — Post-deploy validation snippet using aci_rest"
create_gist "outputs/validation-output.txt"     "Article 01 — Expected output of the post-deploy validation"
create_gist ".pre-commit-config.yaml"           "Article 01 — Pre-commit hook to gate CSV changes"

echo ""
echo "✅ Listo. Las 15 URLs quedaron guardadas en: $OUTPUT"
echo ""
echo "📋 Resumen:"
echo ""
cat "$OUTPUT"
