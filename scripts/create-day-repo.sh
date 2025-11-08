#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/TEMPLATES/DayRepo_Scaffold"
README_TEMPLATE="$TEMPLATE_DIR/README.md"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/create-day-repo.sh <day-number> <slug> "<project title>" "<blog title>" "<blog url>" "<tech stack>" "<tagline>"

Example:
  ./scripts/create-day-repo.sh 06 Resilience4j "Circuit Breaker Playground" \
    "Circuit Breakers in Spring Boot: How Resilience4j Protects Your APIs From Cascading Failures" \
    "https://enouveau.io/blog/2025/11/06/resilience4j-under-the-hood.html" \
    "Spring Boot, Resilience4j, Micrometer" \
    "Resilience patterns for unstable dependencies"

Notes:
  - <slug> should be URL-friendly (no spaces, use PascalCase or kebab-case).
  - The script creates a directory named 30DiasJava-DayXX-<slug>.
  - You can customise the generated README afterwards.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 7 ]]; then
  echo "❌ Missing arguments."
  usage
  exit 1
fi

DAY_NUMBER="$1"
SLUG="$2"
PROJECT_TITLE="$3"
BLOG_TITLE="$4"
BLOG_URL="$5"
TECH_STACK="$6"
TAGLINE="$7"

if [[ ! "$DAY_NUMBER" =~ ^[0-9]{2}$ ]]; then
  echo "❌ Day number must be two digits (e.g., 05, 14)."
  exit 1
fi

REPO_NAME="30DiasJava-Day${DAY_NUMBER}-${SLUG}"
TARGET_DIR="$ROOT_DIR/$REPO_NAME"

if [[ -d "$TARGET_DIR" ]]; then
  echo "⚠️  Directory $REPO_NAME already exists. Aborting to prevent overwriting."
  exit 1
fi

echo "📦 Creating scaffold for $REPO_NAME"
mkdir -p "$TARGET_DIR"

# Copy template files (excluding README placeholder to customise below)
find "$TEMPLATE_DIR" -mindepth 1 -type f ! -name 'README.md' -print0 | while IFS= read -r -d '' file; do
  relative_path="${file#$TEMPLATE_DIR/}"
  target_path="$TARGET_DIR/$relative_path"
  mkdir -p "$(dirname "$target_path")"
  cp "$file" "$target_path"
done

if [[ ! -f "$README_TEMPLATE" ]]; then
  echo "❌ README template not found at $README_TEMPLATE"
  exit 1
fi

REFERENCES_LIST="- Spring Cloud Config Docs\n- Resilience4j Docs\n- Prometheus Docs"

sed \
  -e "s/{{DAY_NUMBER}}/$DAY_NUMBER/g" \
  -e "s/{{PROJECT_TITLE}}/$PROJECT_TITLE/g" \
  -e "s/{{BLOG_TITLE}}/$BLOG_TITLE/g" \
  -e "s|{{BLOG_URL}}|$BLOG_URL|g" \
  -e "s/{{TECH_STACK}}/$TECH_STACK/g" \
  -e "s/{{REPO_NAME}}/$REPO_NAME/g" \
  -e "s|{{REPO_GIT_URL}}|https://github.com/adelmonsouza/$REPO_NAME.git|g" \
  -e "s/{{TAGLINE}}/$TAGLINE/g" \
  -e "s/{{PROBLEM_STATEMENT}}/Describe the core problem this project solves./g" \
  -e "s/{{HIGHLIGHT_1}}/Key architectural decision #1./g" \
  -e "s/{{HIGHLIGHT_2}}/Key architectural decision #2./g" \
  -e "s/{{HIGHLIGHT_3}}/Key architectural decision #3./g" \
  -e "s/{{REFERENCES_LIST}}/$REFERENCES_LIST/g" \
  "$README_TEMPLATE" > "$TARGET_DIR/README.md"

cat <<EOF > "$TARGET_DIR/.gitignore"
# Build artifacts
/target/
/out/

# IDE files
.idea/
.project
.classpath
.settings/
.vscode/

# OS files
.DS_Store
EOF

echo "✅ Scaffold created in $REPO_NAME"
echo "➡️  Next steps:"
echo "    1. cd $REPO_NAME"
echo "    2. Customise README (problem statement, highlights, commands)"
echo "    3. Create project structure (src/, docker/, etc.)"
echo "    4. Initialise git repo and push to GitHub: git init && git remote add origin git@github.com:adelmonsouza/$REPO_NAME.git"

