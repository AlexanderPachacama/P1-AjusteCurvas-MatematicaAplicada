# Progreso 1 – Ajuste de superficies con `fit` (MATLAB)

**Matemática Aplicada para Ingenieros – MATZ0375 (UDLA)**
Profesor: Alexis F. Tinoco-S · Integrantes: Alexander Pachacama, Kevin Coello

Live Script que resuelve todo lo que pide el Progreso 1:

| Ítem | Qué hace el script |
|---|---|
| 1 | Gráfico 3D de los 800 datos (500 ms a 1,6 kHz) con título, ejes y barra de color en ±5 V |
| 2 | Valores de sensor1 y sensor2 donde está el máximo y el mínimo del desempeño (datos brutos) |
| 3 | Prueba todos los modelos de `fit` (poly11…poly55, interpolantes, smoothingspline, lowess, loess) y elige el mejor con validación cruzada 80/20 |
| 4 | Figura con la superficie elegida y figura con superficie + datos originales |
| 5 | Extremos de la superficie, comparación con el ítem 2 y respuestas a las preguntas a, b y c |

## Cómo usarlo

1. Clonar este repositorio en MATLAB: pestaña **Home → New → Git Clone** (o en la ventana de comandos `gitclone("https://github.com/AlexanderPachacama/P1-AjusteCurvas-MatematicaAplicada")`, R2023b o superior).
2. Los dos archivos de datos ya vienen en el repositorio (extraídos del .exe). Si se quiere regenerarlos: copiar `AjusteCurvas.exe` (lo entrega el profesor) dentro de la carpeta clonada y ejecutarlo. Genera `Datos3D_Ruidosos.txt` y `Datos_RuidososBrutos.txt`. **Requiere el [MATLAB Runtime R2024a (24.1)](https://www.mathworks.com/products/compiler/matlab-runtime.html)**, gratuito; sin él aparece el error *Could not find version 24.1 of the MATLAB Runtime*.
3. Abrir `P1_AjusteCurvas.m` con clic derecho → **Open as Live Script** y guardarlo como `P1_AjusteCurvas.mlx`.
4. Pulsar **Run** (requiere Curve Fitting Toolbox).

## Subir cambios desde MATLAB

En el panel **Source Control** (o clic derecho en la carpeta → Source Control): *Commit* para guardar los cambios y *Push* para enviarlos a GitHub.
