%% Progreso 1: Ajuste de superficies a datos ruidosos de una planta
% *Matemática Aplicada para Ingenieros – MATZ0375*
%
% Profesor: Alexis F. Tinoco-S
%
% Integrantes: Alexander Pachacama, Kevin Coello
%
% *Problema.* Una planta de baja dinámica, en un entorno ruidoso, se monitorea
% con dos sensores que entregan tensiones entre $\pm 5\,\mathrm{V}$
% ($sensor_1$ y $sensor_2$). El circuito de monitoreo calcula en tiempo real
% una _señal desempeño_. Durante la etapa de adquisición (500 ms) se toman
% 800 muestras de cada señal a $f_s = 1{,}6\,\mathrm{kHz}$:
%
% $$N = f_s \cdot T = 1600\,\mathrm{Hz} \times 0{,}5\,\mathrm{s} = 800 \ \text{muestras}$$
%
% Las tres variables se guardan en una matriz de $800\times 3$:
%
% $$\mathbf{D} = \left[\, sensor_1 \;\; sensor_2 \;\; desempe\tilde{n}o \,\right]_{800\times 3}$$
%
% Con esos datos se busca una superficie $z = f(x,y)$ que describa el
% desempeño en función de los dos sensores, para usarla en los siguientes
% 500 ms al ajustar la planta.
%
% *Requisitos:* MATLAB con _Curve Fitting Toolbox_ (comando |fit|).

clear; clc; close all;

%% Paso 0. Directorio de trabajo y generación de los datos
% Según el procedimiento del Word:
%
% # Abrir MATLAB y definir un subdirectorio de trabajo (la carpeta donde está
% este Live Script).
% # Copiar |AjusteCurvas.exe| en esa carpeta y ejecutarlo (doble clic en
% Windows). Necesita el _MATLAB Runtime_.
% # El programa genera |Datos3D_Ruidosos.txt| y |Datos_RuidososBrutos.txt|.
%
% *Si el .exe dice "Could not find version 24.1 of the MATLAB Runtime"*, hay
% que instalar el MATLAB Runtime R2024a (gratuito) desde
% https://www.mathworks.com/products/compiler/matlab-runtime.html y volver a
% ejecutar el .exe.
%
% La línea siguiente fija como carpeta de trabajo la carpeta del script, para
% que |readmatrix| encuentre los archivos .txt sin escribir rutas.

try
    carpeta = fileparts(matlab.desktop.editor.getActiveFilename);
    if ~isempty(carpeta), cd(carpeta); end
catch
    % Si se ejecuta fuera del editor se queda en la carpeta actual
end
disp(['Carpeta de trabajo: ' pwd])

% Si los archivos todavía no existen se intenta ejecutar el generador.
if ~isfile('Datos_RuidososBrutos.txt') && isfile('AjusteCurvas.exe')
    disp('Ejecutando AjusteCurvas.exe para generar los datos...')
    system('AjusteCurvas.exe');
end
if ~isfile('Datos_RuidososBrutos.txt')
    error(['No se encontró Datos_RuidososBrutos.txt en %s.\n' ...
        'AjusteCurvas.exe necesita el MATLAB Runtime R2024a (24.1), gratis en\n' ...
        'https://www.mathworks.com/products/compiler/matlab-runtime.html\n' ...
        'Instálelo, ejecute AjusteCurvas.exe en esta carpeta y vuelva a correr el script\n' ...
        '(o copie aquí los archivos Datos3D_Ruidosos.txt y Datos_RuidososBrutos.txt).'], pwd);
end

%% Paso 1. Carga de los datos en MATLAB
% Se usan los comandos sugeridos en el enunciado. |readmatrix| lee un archivo
% de texto con números y lo devuelve como matriz.
%
% * |DatosBrutos|: matriz de $800\times 3$. Columna 1 = $sensor_1$,
% columna 2 = $sensor_2$, columna 3 = _señal desempeño_. Es la matriz que se
% usa para el ajuste.
% * |Datos3D|: los mismos datos ruidosos organizados para graficar en 3D.

DatosBrutos = readmatrix('Datos_RuidososBrutos.txt');
Datos3D     = readmatrix('Datos3D_Ruidosos.txt');

tamDatosBrutos = size(DatosBrutos)
tamDatos3D     = size(Datos3D)

% Se separan las columnas en vectores con nombres claros
s1 = DatosBrutos(:,1);     % sensor 1  [V]
s2 = DatosBrutos(:,2);     % sensor 2  [V]
z  = DatosBrutos(:,3);     % señal desempeño [V]

% Se eliminan filas incompletas (NaN), por si el archivo tiene encabezado
ok = ~any(isnan([s1 s2 z]), 2);
s1 = s1(ok);  s2 = s2(ok);  z = z(ok);
N  = numel(z)

% Vector de tiempo de la adquisición: t = n / fs
fs = 1600;                          % frecuencia de muestreo [Hz]
t  = (0:N-1)'/fs;                   % [s]
fprintf('Duración de la adquisición: %.1f ms\n', 1000*N/fs);

% Resumen estadístico de cada señal
resumen = table({'sensor1';'sensor2';'desempeño'}, ...
    [min(s1);min(s2);min(z)], [max(s1);max(s2);max(z)], ...
    [mean(s1);mean(s2);mean(z)], [std(s1);std(s2);std(z)], ...
    'VariableNames', {'Senal','Minimo_V','Maximo_V','Media_V','Desv_V'})

%% Ítem 1. Gráfico 3D de los datos de los primeros 500 ms
% Cada fila de la matriz es un punto $(sensor_1,\, sensor_2,\, desempe\tilde{n}o)$
% en el espacio. Con |scatter3| se dibujan los 800 puntos y el color de cada
% punto representa el valor del desempeño.
%
% El gráfico cumple lo pedido:
%
% * _i)_ título y etiquetas de los tres ejes;
% * _ii)_ barra de color (|colorbar|) fijada en la escala de $\pm 5\,\mathrm{V}$
% con |caxis([-5 5])|.

figure(1);
scatter3(s1, s2, z, 25, z, 'filled');
formatoGrafico('Ítem 1: Datos ruidosos adquiridos en los primeros 500 ms');
view(-35, 30);

%%
% El archivo |Datos3D_Ruidosos.txt| contiene los datos preparados para la
% vista 3D. Si tiene tres columnas son puntos $(x,y,z)$; si es una matriz se
% interpreta como una malla de alturas $z$ y se dibuja con |surf|.

figure(2);
if size(Datos3D,2) == 3
    scatter3(Datos3D(:,1), Datos3D(:,2), Datos3D(:,3), 25, Datos3D(:,3), 'filled');
else
    [Xd, Yd] = meshgrid(linspace(min(s1), max(s1), size(Datos3D,2)), ...
                        linspace(min(s2), max(s2), size(Datos3D,1)));
    surf(Xd, Yd, Datos3D, 'EdgeColor', 'none');
end
formatoGrafico('Ítem 1: Datos3D\_Ruidosos (vista 3D)');
view(-35, 30);

%%
% *Observación:* la nube de puntos muestra una tendencia (una superficie)
% pero con mucha dispersión vertical, que es el ruido del entorno. Por eso
% no conviene tomar decisiones con un solo punto aislado.

%% Ítem 2. Máximo(s) y mínimo(s) de la señal desempeño en los datos brutos
% Sobre los datos sin procesar se busca la fila donde el desempeño es mayor y
% la fila donde es menor:
%
% $$i_{max} = \arg\max_i \, z_i \qquad i_{min} = \arg\min_i \, z_i$$
%
% Los valores de los sensores en esas filas son los puntos buscados. Se usa
% |find| con todas las filas que alcanzan el extremo por si hay más de una
% (empates).

zMaxBruto = max(z);
zMinBruto = min(z);
iMax = find(z == zMaxBruto);
iMin = find(z == zMinBruto);

fprintf('\n--- Extremos en los DATOS BRUTOS ---\n');
for k = 1:numel(iMax)
    fprintf('MÁXIMO: desempeño = %7.4f V en sensor1 = %7.4f V, sensor2 = %7.4f V (muestra %d, t = %.2f ms)\n', ...
        z(iMax(k)), s1(iMax(k)), s2(iMax(k)), iMax(k), 1000*t(iMax(k)));
end
for k = 1:numel(iMin)
    fprintf('MÍNIMO: desempeño = %7.4f V en sensor1 = %7.4f V, sensor2 = %7.4f V (muestra %d, t = %.2f ms)\n', ...
        z(iMin(k)), s1(iMin(k)), s2(iMin(k)), iMin(k), 1000*t(iMin(k)));
end

% Guardamos el primer punto de cada extremo para compararlo en el ítem 5
pMaxBruto = [s1(iMax(1)), s2(iMax(1)), zMaxBruto];
pMinBruto = [s1(iMin(1)), s2(iMin(1)), zMinBruto];

%%
% Para ver cuán "aislados" son estos extremos se listan también los 5 valores
% más altos y los 5 más bajos. Si están en zonas distintas del plano
% $(sensor_1, sensor_2)$, es una señal de que el ruido domina los extremos.

[~, orden] = sort(z, 'descend');
Top5Maximos = table(s1(orden(1:5)), s2(orden(1:5)), z(orden(1:5)), ...
    'VariableNames', {'sensor1_V','sensor2_V','desempeno_V'})
[~, orden] = sort(z, 'ascend');
Top5Minimos = table(s1(orden(1:5)), s2(orden(1:5)), z(orden(1:5)), ...
    'VariableNames', {'sensor1_V','sensor2_V','desempeno_V'})

figure(3);
scatter3(s1, s2, z, 15, z, 'filled', 'MarkerFaceAlpha', 0.4); hold on;
plot3(pMaxBruto(1), pMaxBruto(2), pMaxBruto(3), 'rp', 'MarkerSize', 18, 'MarkerFaceColor', 'r');
plot3(pMinBruto(1), pMinBruto(2), pMinBruto(3), 'bp', 'MarkerSize', 18, 'MarkerFaceColor', 'b');
hold off;
formatoGrafico('Ítem 2: Máximo (rojo) y mínimo (azul) en los datos brutos');
legend('Datos', 'Máximo bruto', 'Mínimo bruto', 'Location', 'best');
view(-35, 30);

%% Ítem 3. Búsqueda de la mejor superficie de ajuste con |fit|
% El comando |fit(X, z, tipo)| ajusta una superficie $z = f(x,y)$ a los
% puntos, donde |X = [sensor1 sensor2]|. Se prueban todos los modelos que
% indica el Word:
%
% * *Polinomiales* |polyij|: polinomio de grado $i$ en $x$ y grado $j$ en $y$.
% Por ejemplo |poly22|:
%
% $$f(x,y) = p_{00} + p_{10}x + p_{01}y + p_{20}x^2 + p_{11}xy + p_{02}y^2$$
%
% * *Interpolantes* (|linearinterp|, |nearestinterp|, |cubicinterp|,
% |biharmonicinterp|, |thinplateinterp|): pasan exactamente por todos los
% puntos.
% * *Spline de suavizado* (|smoothingspline|): curva flexible con un
% parámetro que equilibra suavidad y cercanía a los datos. En varias
% versiones de MATLAB este modelo solo existe para curvas (2D); si |fit| no
% lo acepta para superficies, el script lo informa y continúa.
% * *Regresión local* (|lowess|, |loess|): además de la lista del Word se
% agregan estos dos modelos, que son la versión "suavizada" para superficies:
% en cada punto ajustan un plano (|lowess|) o una cuadrática (|loess|) con
% los vecinos cercanos, y así filtran el ruido.
%
% *Criterios de bondad de ajuste* que entrega |fit| (estructura |gof|):
%
% $$SSE = \sum_{i=1}^{N} (z_i - \hat z_i)^2 \qquad
% RMSE = \sqrt{\frac{SSE}{N - m}} \qquad
% R^2 = 1 - \frac{SSE}{\sum (z_i - \bar z)^2}$$
%
% *Cuidado:* los interpolantes siempre dan $SSE = 0$ y $R^2 = 1$ porque pasan
% por todos los puntos, _incluido el ruido_. Eso no significa que sean los
% mejores, sino que memorizan el ruido (sobreajuste). Por eso se agrega una
% *validación cruzada*: se ajusta cada modelo con el 80 % de los puntos
% (entrenamiento) y se mide el error en el 20 % restante (validación), que el
% modelo nunca vio. El mejor modelo es el que predice mejor puntos nuevos:
%
% $$RMSE_{val} = \sqrt{\frac{1}{N_{val}} \sum_{i \in val} \left(z_i - f(x_i, y_i)\right)^2}$$

X = [s1 s2];

tipos = {'poly11','poly12','poly13','poly21','poly22','poly23', ...
         'poly31','poly32','poly33','poly44','poly55', ...
         'linearinterp','nearestinterp','cubicinterp', ...
         'biharmonicinterp','thinplateinterp','smoothingspline', ...
         'lowess','loess'};
nT = numel(tipos);

% División aleatoria 80 / 20 (rng fija la semilla para que sea repetible)
rng(1);
perm  = randperm(N);
nEnt  = round(0.8*N);
iEnt  = perm(1:nEnt);
iVal  = perm(nEnt+1:end);

SSE = nan(nT,1);  R2 = nan(nT,1);  R2aj = nan(nT,1);
RMSE = nan(nT,1); RMSEval = nan(nT,1);

warning('off', 'all');   % los interpolantes avisan si hay puntos repetidos
for k = 1:nT
    try
        opciones = {};
        if startsWith(tipos{k}, 'poly')
            opciones = {'Normalize', 'on'};   % centra y escala x, y (mejor condicionamiento)
        end
        % (a) Ajuste con TODOS los datos: bondad de ajuste
        [~, gof] = fit(X, z, tipos{k}, opciones{:});
        SSE(k)  = gof.sse;
        R2(k)   = gof.rsquare;
        R2aj(k) = gof.adjrsquare;
        RMSE(k) = gof.rmse;
        % (b) Validación cruzada: ajustar con 80 % y probar en 20 %
        sfEnt = fit(X(iEnt,:), z(iEnt), tipos{k}, opciones{:});
        zPred = sfEnt(X(iVal,1), X(iVal,2));
        RMSEval(k) = sqrt(mean((z(iVal) - zPred).^2, 'omitnan'));
    catch err
        fprintf('No se pudo ajustar %s: %s\n', tipos{k}, err.message);
    end
end
warning('on', 'all');

TablaAjustes = table(tipos', SSE, R2, R2aj, RMSE, RMSEval, ...
    'VariableNames', {'Modelo','SSE','R2','R2_ajustado','RMSE','RMSE_validacion'});
TablaAjustes = sortrows(TablaAjustes, 'RMSE_validacion')

%%
% Gráfico comparativo del error de validación (barra más baja = mejor).

figure(4);
bar(categorical(TablaAjustes.Modelo, TablaAjustes.Modelo), TablaAjustes.RMSE_validacion);
ylabel('RMSE de validación [V]'); grid on;
title('Ítem 3: Error de predicción de cada superficie (menor es mejor)');

%%
% *Selección del mejor modelo:* el de menor $RMSE_{val}$. Después se vuelve a
% ajustar con los 800 puntos para usar toda la información.

mejorTipo = TablaAjustes.Modelo{1};
opciones = {};
if startsWith(mejorTipo, 'poly')
    opciones = {'Normalize', 'on'};
end
[sfMejor, gofMejor] = fit(X, z, mejorTipo, opciones{:})
fprintf('\nMEJOR SUPERFICIE: %s  (R^2 = %.4f, RMSE = %.4f V, RMSE validación = %.4f V)\n', ...
    mejorTipo, gofMejor.rsquare, gofMejor.rmse, TablaAjustes.RMSE_validacion(1));

% Nivel de ruido estimado: dispersión de los datos alrededor de la superficie
residuos = z - sfMejor(s1, s2);
fprintf('Desviación estándar del ruido estimada: %.4f V\n', std(residuos));

%%
% *Interpretación:* el modelo elegido es el que mejor separa la tendencia real
% de la planta del ruido. Los interpolantes quedan con errores de validación
% altos (copian el ruido) y los polinomios de grado muy bajo (|poly11|) no
% alcanzan a seguir la forma de la superficie (subajuste). El mejor queda en
% el punto medio entre ambos extremos.

%% Ítem 4. Gráficos de la superficie de ajuste
% Se evalúa la superficie elegida sobre una malla regular que cubre el rango
% medido de los sensores. |meshgrid| crea las coordenadas de la malla y
% |sfMejor(Xg, Yg)| calcula $\hat z = f(x,y)$ en cada nodo.

nMalla = 200;
[Xg, Yg] = meshgrid(linspace(min(s1), max(s1), nMalla), ...
                    linspace(min(s2), max(s2), nMalla));
Zg = sfMejor(Xg, Yg);

%%
% *Figura i)* Solo la superficie 3D elegida como mejor ajuste (con título,
% etiquetas y barra de color en $\pm 5\,\mathrm{V}$, igual que el ítem 1).

figure(5);
surf(Xg, Yg, Zg, 'EdgeColor', 'none'); shading interp;
formatoGrafico(['Ítem 4 i): Superficie de ajuste (' mejorTipo ')']);
view(-35, 30);

%%
% *Figura ii)* La superficie de ajuste junto con los 800 datos originales,
% para ver cómo la superficie pasa por el "centro" de la nube de puntos.

figure(6);
surf(Xg, Yg, Zg, 'EdgeColor', 'none', 'FaceAlpha', 0.75); shading interp; hold on;
plot3(s1, s2, z, 'k.', 'MarkerSize', 8);
hold off;
formatoGrafico(['Ítem 4 ii): Superficie (' mejorTipo ') y datos originales']);
legend('Superficie de ajuste', 'Datos originales', 'Location', 'best');
view(-35, 30);

%% Ítem 5a. Máximos y mínimos sobre la superficie ajustada
% Se buscan los extremos de $\hat z = f(x,y)$ sobre la malla fina (paso de
% aprox. 0,05 V). Además se buscan *extremos locales*: nodos cuyo valor es
% mayor (o menor) que sus 8 vecinos, por si la superficie tiene más de un
% pico o valle.

[zMaxAj, kMax] = max(Zg(:));
[zMinAj, kMin] = min(Zg(:));
pMaxAj = [Xg(kMax), Yg(kMax), zMaxAj];
pMinAj = [Xg(kMin), Yg(kMin), zMinAj];

fprintf('\n--- Extremos en la SUPERFICIE AJUSTADA (%s) ---\n', mejorTipo);
fprintf('MÁXIMO: desempeño = %7.4f V en sensor1 = %7.4f V, sensor2 = %7.4f V\n', pMaxAj(3), pMaxAj(1), pMaxAj(2));
fprintf('MÍNIMO: desempeño = %7.4f V en sensor1 = %7.4f V, sensor2 = %7.4f V\n', pMinAj(3), pMinAj(1), pMinAj(2));

[esMaxLoc, esMinLoc] = extremosLocales(Zg);
MaximosLocales = table(Xg(esMaxLoc), Yg(esMaxLoc), Zg(esMaxLoc), ...
    'VariableNames', {'sensor1_V','sensor2_V','desempeno_V'})
MinimosLocales = table(Xg(esMinLoc), Yg(esMinLoc), Zg(esMinLoc), ...
    'VariableNames', {'sensor1_V','sensor2_V','desempeno_V'})

%%
% *Comparación con el ítem 2.* Se calcula la distancia en el plano de los
% sensores entre el extremo bruto y el extremo de la superficie, y qué valor
% predice la superficie en el punto bruto.

dMax = norm(pMaxBruto(1:2) - pMaxAj(1:2));
dMin = norm(pMinBruto(1:2) - pMinAj(1:2));

Comparacion = table({'Máximo';'Mínimo'}, ...
    [pMaxBruto(1); pMinBruto(1)], [pMaxBruto(2); pMinBruto(2)], [pMaxBruto(3); pMinBruto(3)], ...
    [pMaxAj(1); pMinAj(1)],       [pMaxAj(2); pMinAj(2)],       [pMaxAj(3); pMinAj(3)], ...
    [dMax; dMin], ...
    'VariableNames', {'Extremo','s1_bruto','s2_bruto','z_bruto', ...
                      's1_ajuste','s2_ajuste','z_ajuste','distancia_V'})

fprintf('En el punto del máximo bruto la superficie predice %.4f V (el dato medido fue %.4f V).\n', ...
    sfMejor(pMaxBruto(1), pMaxBruto(2)), pMaxBruto(3));
fprintf('En el punto del mínimo bruto la superficie predice %.4f V (el dato medido fue %.4f V).\n', ...
    sfMejor(pMinBruto(1), pMinBruto(2)), pMinBruto(3));

figure(7);
surf(Xg, Yg, Zg, 'EdgeColor', 'none', 'FaceAlpha', 0.6); shading interp; hold on;
plot3(pMaxBruto(1), pMaxBruto(2), pMaxBruto(3), 'rp', 'MarkerSize', 16, 'MarkerFaceColor', 'r');
plot3(pMinBruto(1), pMinBruto(2), pMinBruto(3), 'bp', 'MarkerSize', 16, 'MarkerFaceColor', 'b');
plot3(pMaxAj(1), pMaxAj(2), pMaxAj(3), 'ro', 'MarkerSize', 12, 'LineWidth', 2.5);
plot3(pMinAj(1), pMinAj(2), pMinAj(3), 'bo', 'MarkerSize', 12, 'LineWidth', 2.5);
hold off;
formatoGrafico('Ítem 5a: Extremos brutos (estrellas) vs. extremos de la superficie (círculos)');
legend('Superficie', 'Máx. bruto', 'Mín. bruto', 'Máx. ajuste', 'Mín. ajuste', 'Location', 'best');
view(-35, 30);

%%
% *Respuesta 5a.*
%
% * *¿Son los mismos puntos?* No. Como muestra la tabla |Comparacion|, los
% valores de $sensor_1$ y $sensor_2$ donde ocurren los extremos de los datos
% brutos no coinciden con los de la superficie ajustada (columna
% |distancia_V| distinta de cero), y además los valores extremos del
% desempeño son menores en magnitud en la superficie.
% * *Nuevos valores:* son los que se imprimen arriba como "Extremos en la
% SUPERFICIE AJUSTADA" (|pMaxAj| y |pMinAj|).
% * *¿Por qué la diferencia?* Cada dato bruto es $z_i = f(x_i,y_i) + \varepsilon_i$,
% donde $\varepsilon_i$ es ruido. El máximo de los datos brutos es el punto
% donde la suma _tendencia + ruido_ fue más alta, es decir, casi siempre una
% muestra donde el ruido fue grande y positivo (y el mínimo, una muestra con
% ruido grande y negativo). La superficie de ajuste minimiza el error
% cuadrático de todos los puntos a la vez, lo que equivale a _promediar_ el
% ruido ($E[\varepsilon]=0$), y por eso sus extremos reflejan el
% comportamiento real de la planta y no un pico aleatorio. Además el máximo
% bruto solo puede estar en uno de los 800 puntos medidos, mientras que la
% superficie se puede evaluar en cualquier punto del plano.

%% Ítem 5b. ¿Puntos brutos o superficie ajustada? Región de trabajo
% Para responder qué región conviene, se marca la zona donde la superficie
% está dentro del 10 % superior de su rango de desempeño:
%
% $$\hat z(x,y) \ge \hat z_{min} + 0{,}9\,(\hat z_{max} - \hat z_{min})$$
%
% y también se calcula la pendiente $\|\nabla \hat z\|$: donde la pendiente es
% pequeña, un error en los sensores casi no cambia el desempeño (zona robusta).

umbral = zMinAj + 0.9*(zMaxAj - zMinAj);
zonaOptima = Zg >= umbral;

[dZdx, dZdy] = gradient(Zg, Xg(1,2)-Xg(1,1), Yg(2,1)-Yg(1,1));
pendiente = hypot(dZdx, dZdy);

fprintf('Zona de mejor desempeño (z >= %.3f V):\n', umbral);
fprintf('  sensor1 entre %.3f y %.3f V\n', min(Xg(zonaOptima)), max(Xg(zonaOptima)));
fprintf('  sensor2 entre %.3f y %.3f V\n', min(Yg(zonaOptima)), max(Yg(zonaOptima)));
fprintf('  pendiente media en la zona: %.3f V/V (en toda la superficie: %.3f V/V)\n', ...
    mean(pendiente(zonaOptima), 'omitnan'), mean(pendiente(:), 'omitnan'));

figure(8);
contourf(Xg, Yg, Zg, 20, 'LineStyle', 'none'); hold on;
contour(Xg, Yg, double(zonaOptima), [0.5 0.5], 'w', 'LineWidth', 2.5);
plot(pMaxAj(1), pMaxAj(2), 'wp', 'MarkerSize', 16, 'MarkerFaceColor', 'r');
hold off;
xlabel('sensor_1 [V]'); ylabel('sensor_2 [V]');
title('Ítem 5b: Zona de mejor desempeño (contorno blanco)');
cb = colorbar; cb.Label.String = 'Señal desempeño [V]'; caxis([-5 5]); colormap(jet);
axis equal tight; grid on;

%%
% *Respuesta 5b.*
%
% * *¿Puntos brutos o superficie ajustada?* Es mejor usar la *superficie
% ajustada*. Los puntos brutos tienen el ruido mezclado con la información:
% si se ajusta la planta hacia el máximo bruto, se está persiguiendo un pico
% de ruido que no se repetirá en los siguientes 500 ms. La superficie resume
% los 800 datos en un modelo continuo, con un error típico (RMSE) cercano a
% la desviación del ruido, permite evaluar el desempeño en cualquier
% combinación de sensores y se puede derivar para encontrar extremos y
% pendientes.
% * *Limitante:* el ajuste supone que la planta *no cambia* mientras se usa
% el modelo. La superficie se construye con los primeros 500 ms y se aplica en
% los 500 ms siguientes; eso solo es válido porque la planta es de _baja
% dinámica_. Otros limitantes son el tiempo de cálculo del |fit| (debe caber
% en el ciclo de control), que la superficie solo es confiable dentro del
% rango medido (fuera de él se extrapola) y que elegir mal el modelo lleva a
% sobreajuste o subajuste.
% * *(Opcional) Ejemplo donde no sirve:* una planta de dinámica rápida, por
% ejemplo el control de corriente de un motor eléctrico, un convertidor de
% potencia conmutado o la estabilización de un dron, donde el comportamiento
% cambia en milisegundos; cuando la superficie esté lista ya no representa a
% la planta. Tampoco sirve si el sistema tiene memoria o histéresis (el
% desempeño depende de la historia y no solo de los valores actuales de los
% sensores).
% * *(Opcional) Región de trabajo:* se elegiría la zona marcada con el
% contorno blanco (Figura 8), alrededor del máximo de la superficie. Dentro de
% ella conviene la parte más plana (menor $\|\nabla\hat z\|$), porque ahí
% pequeñas variaciones o ruido en los sensores no bajan el desempeño: es un
% punto de operación robusto. Se evita trabajar cerca de los bordes del rango
% medido, donde la superficie es menos confiable.

%% Ítem 5c (Opcional). ¿Un agente de IA en el ajuste de la planta?
% *Respuesta.* Sí es factible, si los tiempos de adquisición y ajuste
% alcanzan. El esquema actual decide solo con la última ventana de 500 ms;
% un agente de IA (por ejemplo, aprendizaje por refuerzo u optimización
% bayesiana) puede guardar el historial de ventanas _(estado de sensores,
% ajuste aplicado, desempeño obtenido)_ y aprender qué ajustes dieron mejores
% resultados, prever la deriva lenta de la planta y proponer el siguiente
% punto de operación. Esto mejora el trabajo futuro, porque cada ciclo aporta
% datos nuevos.
%
% Condiciones para hacerlo bien: (1) el agente debe actuar dentro de límites
% seguros (no puede llevar la planta fuera del rango de $\pm5\,\mathrm{V}$ ni a
% zonas no medidas), (2) necesita suficientes datos de entrenamiento y
% validación para no aprender el ruido, (3) sus decisiones deben poder
% supervisarse y revertirse, y (4) el tiempo de inferencia debe caber dentro
% del ciclo de control. Con esas salvaguardas, el agente complementa (no
% reemplaza) al ajuste de superficie: la superficie da un modelo físico
% interpretable y el agente decide cómo moverse sobre ella con base en la
% experiencia.

%% Conclusiones
%
% * Se cargaron las 800 muestras $\times$ 3 señales adquiridas en 500 ms a
% 1,6 kHz y se graficaron en 3D con su barra de color en $\pm5\,\mathrm{V}$.
% * Los extremos de los datos brutos están dominados por el ruido.
% * Comparando los modelos de |fit| con validación cruzada se eligió la
% superficie que mejor predice datos nuevos; los interpolantes tienen
% $R^2=1$ pero sobreajustan.
% * Los extremos de la superficie ajustada difieren de los brutos y son los
% que deben usarse para ajustar la planta, siempre que esta sea de baja
% dinámica.

%% Funciones auxiliares
% En un Live Script las funciones locales van al final del archivo.

function formatoGrafico(titulo)
% Aplica el formato pedido en el ítem 1: título, etiquetas de los ejes y
% barra de color asociada a la escala de ±5 V.
    title(titulo);
    xlabel('sensor_1 [V]');
    ylabel('sensor_2 [V]');
    zlabel('Señal desempeño [V]');
    cb = colorbar;
    cb.Label.String = 'Amplitud [V]';
    caxis([-5 5]);
    colormap(jet);
    grid on; box on;
end

function [esMax, esMin] = extremosLocales(Z)
% Devuelve máscaras lógicas de los nodos que son máximo (o mínimo) local:
% su valor es estrictamente mayor (o menor) que el de sus 8 vecinos.
% Los bordes se rellenan con -Inf / +Inf para que también puedan ser extremos.
    Zmax = -inf(size(Z) + 2);  Zmax(2:end-1, 2:end-1) = Z;
    Zmin =  inf(size(Z) + 2);  Zmin(2:end-1, 2:end-1) = Z;
    esMax = true(size(Z));  esMin = true(size(Z));
    for di = -1:1
        for dj = -1:1
            if di == 0 && dj == 0, continue; end
            vecMax = Zmax((2:end-1) + di, (2:end-1) + dj);
            vecMin = Zmin((2:end-1) + di, (2:end-1) + dj);
            esMax = esMax & (Z > vecMax);
            esMin = esMin & (Z < vecMin);
        end
    end
    esMax(isnan(Z)) = false;  esMin(isnan(Z)) = false;
end
