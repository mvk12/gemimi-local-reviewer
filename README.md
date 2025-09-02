# Gemini Local Reviewer

Pequeña utilidad en Bash para generar un prompt de revisión de código local a partir del diff de Git. Toma los cambios de tu rama actual contra una rama base (main/master o la que indiques), los inyecta en una plantilla Markdown y emite un prompt listo para pegar en tu modelo (p. ej., Gemini) para obtener una revisión precisa y enfocada solo en líneas cambiadas.

## ¿Qué hace?
- Detecta la rama base (o usas una por parámetro).
- Genera el `git diff` contra esa rama.
- Inyecta el diff y un contexto adicional opcional en una plantilla Markdown.
- Imprime el prompt final por stdout (no envía nada a ningún servicio externo).

Incluye dos plantillas:
- `review-prompt.md`: Genera el informe para pegar directamente en el modelo.
- `review-prompt-to-file.md`: Variante pensada para agentes que guardan el informe en un archivo temporal.

## Requisitos
- Git y Bash.
- Estar dentro de un repositorio Git con cambios.

## Uso rápido
```bash
./gemini-review.sh               # Detecta main/master automáticamente
./gemini-review.sh main          # Fuerza la rama base
./gemini-review.sh main "Prioriza seguridad y rendimiento"
```

Puedes redirigir la salida a un archivo si lo prefieres:
```bash
./gemini-review.sh main "Notas: mira endpoints de auth" > /tmp/prompt.md
```

## Notas
- El script no llama a ningún servicio remoto; solo construye el prompt localmente.
- Asegúrate de que `gemini-review.sh` tenga permisos de ejecución (`chmod +x`).
