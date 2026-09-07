#!/usr/bin/env bash
set -euo pipefail

# To be executed once per academic year to create the GitHub repository and enable GitHub Pages.
# The first time that gh is used for this kind of operations, run:
#   gh auth refresh -s workflow
# The first time that gh is ever used, run:
#   gh auth login --scopes workflow

ACADEMIC_YEAR=2627
# Poner SUFFIX a vacío para crear la versión oficial, o "-v1", "-v2", etc. para crear versiones de prueba
#SUFFIX="-v1"
SUFFIX=
REPO_NAME="plni-${ACADEMIC_YEAR}${SUFFIX}"

# Inicializar repositorio git si no existe
if [ ! -d ".git" ]; then
  git init
  git checkout -b main
fi

# .gitignore (ya debe existir, pero lo garantizamos)
if [ ! -f ".gitignore" ]; then
  cat > .gitignore <<'EOF'
/_site/
/.quarto/
*.pyc
__pycache__/
EOF
fi

# Primer commit
git add .
git commit -m "Primer commit: sitio PLNI ${ACADEMIC_YEAR}"

# Detectar usuario de GitHub
GITHUB_USER=$(gh api user --jq '.login')
echo "Usuario GitHub detectado: ${GITHUB_USER}"

# Crear repositorio en GitHub y hacer push de main
gh repo create "${GITHUB_USER}/${REPO_NAME}" \
  --public \
  --source=. \
  --remote=origin \
  --push

# Crear rama gh-pages vacía con un placeholder
git checkout --orphan gh-pages
git reset --hard
echo '<html><body><p>Cargando sitio... vuelve en unos minutos.</p></body></html>' > index.html
git add index.html
git commit -m "gh-pages: placeholder inicial"
git push origin gh-pages

# Habilitar GitHub Pages apuntando a gh-pages /
echo '{"source":{"branch":"gh-pages","path":"/"}}' | \
  gh api --method POST "repos/${GITHUB_USER}/${REPO_NAME}/pages" --input - \
  || echo "AVISO: La API de Pages puede tardar unos segundos; comprueba manualmente si falla."
  
# Volver a main
git checkout main

# Resumen final
echo ""
echo "============================================================"
echo "  Repositorio : https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo "  GitHub Pages: https://${GITHUB_USER}.github.io/${REPO_NAME}/"
echo "============================================================"
echo ""
echo "El sitio estará disponible en unos minutos tras el primer"
echo "workflow de GitHub Actions (push a main ya realizado)."

