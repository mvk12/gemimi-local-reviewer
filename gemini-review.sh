#!/bin/bash
set -e

# --- Configuration ---
# Path to the prompt template file.
PROMPT_TEMPLATE_PATH="./review-prompt.md"

# --- Script Logic ---
echo "🤖 Iniciando generador de prompt para revisión local..." >&2

# 1. Determinar la rama base.
# Usa el primer argumento si se proporciona, si no, intenta detectar 'main' o 'master'.
BASE_BRANCH=$1
if [ -z "$BASE_BRANCH" ]; then
  echo "No se especificó una rama base. Detectando automáticamente..." >&2
  if git show-branch main >/dev/null 2>&1; then
    BASE_BRANCH="main"
  elif git show-branch master >/dev/null 2>&1; then
    BASE_BRANCH="master"
  else
    echo "❌ Error: No se pudo encontrar la rama 'main' o 'master'. Por favor, especifica una rama base como argumento." >&2
    echo "Uso: $0 <rama-base>" >&2
    exit 1
  fi
fi
echo "Rama base para la comparación: $BASE_BRANCH" >&2

# 2. Generar el diff.
echo "Generando diff contra '$BASE_BRANCH'..." >&2
# Usamos --no-color para asegurar que el diff sea texto plano.
DIFF_CONTENT=$(git diff --no-color "$BASE_BRANCH"...HEAD)

if [ -z "$DIFF_CONTENT" ]; then
  echo "✅ No hay cambios detectados entre HEAD y '$BASE_BRANCH'. No hay nada que revisar." >&2
  exit 0
fi

# 3. Leer la plantilla del prompt.
if [ ! -f "$PROMPT_TEMPLATE_PATH" ]; then
    echo "❌ Error: La plantilla de prompt no se encontró en '$PROMPT_TEMPLATE_PATH'" >&2
    exit 1
fi
PROMPT_TEMPLATE=$(cat "$PROMPT_TEMPLATE_PATH")

# 4. Inyectar el diff y el contexto adicional en la plantilla.
# Usamos una sustitución de string segura en bash para evitar problemas con caracteres especiales.
# Primero, reemplazamos el marcador de posición del diff.
PROMPT_WITH_DIFF="${PROMPT_TEMPLATE//'{{DIFF_CONTENT}}'/"$DIFF_CONTENT"}"

# Luego, el contexto adicional (argumento opcional $2).
ADDITIONAL_CONTEXT=${2:-"No se proporcionó contexto adicional."}
FINAL_PROMPT="${PROMPT_WITH_DIFF//'{{ADDITIONAL_CONTEXT}}'/"$ADDITIONAL_CONTEXT"}"

# 5. Imprimir el prompt final a la salida estándar.
echo "✅ Prompt generado exitosamente. Enviando a stdout." >&2
echo "$FINAL_PROMPT"
