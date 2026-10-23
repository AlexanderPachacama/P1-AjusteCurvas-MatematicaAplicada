%% Progreso 1 - Ajuste de superficies
% Matemática Aplicada para Ingenieros (MATZ0375) - Prof. Alexis F. Tinoco-S
% Integrantes: Alexander Pachacama, Kevin Coello

clear; clc; close all;

%% Carga de datos
DatosBrutos = readmatrix('Datos_RuidososBrutos.txt');   % 800 x 3
Datos3D     = readmatrix('Datos3D_Ruidosos.txt');       % 640000 x 3 (malla 800 x 800)
s1 = DatosBrutos(:,1);   % sensor 1 [V]
s2 = DatosBrutos(:,2);   % sensor 2 [V]
z  = DatosBrutos(:,3);   % señal desempeño [V]

%% Ítem 1. Gráfico 3D de los datos de los primeros 500 ms
figure(1);
scatter3(s1, s2, z, 25, z, 'filled');
title('Ítem 1: Datos adquiridos en los primeros 500 ms');
xlabel('sensor_1 [V]'); ylabel('sensor_2 [V]'); zlabel('Señal desempeño [V]');
cb = colorbar; cb.Label.String = 'Amplitud [V]'; caxis([-5 5]); colormap(jet);
grid on; view(-35, 30);

figure(2);
n  = round(sqrt(size(Datos3D,1)));
[xd, ix] = sort(Datos3D(1:n:end,1));
[yd, iy] = sort(Datos3D(1:n,2));
Zd = reshape(Datos3D(:,3), n, n);
surf(xd, yd, Zd(iy, ix), 'EdgeColor', 'none');
title('Ítem 1: Datos3D\_Ruidosos');
xlabel('sensor_1 [V]'); ylabel('sensor_2 [V]'); zlabel('Señal desempeño [V]');
cb = colorbar; cb.Label.String = 'Amplitud [V]'; caxis([-5 5]); colormap(jet);
grid on; view(-35, 30);

%% Ítem 2. Máximo y mínimo de la señal desempeño (datos brutos)
[zMaxB, iMax] = max(z);
[zMinB, iMin] = min(z);
fprintf('Datos brutos -> MÁXIMO: %.4f V en sensor1 = %.4f V, sensor2 = %.4f V\n', zMaxB, s1(iMax), s2(iMax));
fprintf('Datos brutos -> MÍNIMO: %.4f V en sensor1 = %.4f V, sensor2 = %.4f V\n', zMinB, s1(iMin), s2(iMin));

%% Ítem 3. Mejor superficie de ajuste con fit
X = [s1 s2];
tipos = {'poly11','poly12','poly13','poly21','poly22','poly23','poly31','poly32', ...
         'poly33','poly44','poly55','linearinterp','nearestinterp','cubicinterp', ...
         'biharmonicinterp','thinplateinterp','smoothingspline','lowess','loess'};
nT = numel(tipos);
rng(1); p = randperm(numel(z)); iE = p(1:640); iV = p(641:end);   % 80% ajuste, 20% validación
R2 = nan(nT,1); RMSE = nan(nT,1); RMSEval = nan(nT,1);
warning('off','all');
for k = 1:nT
    try
        [~, g] = fit(X, z, tipos{k});
        R2(k) = g.rsquare; RMSE(k) = g.rmse;
        sfE = fit(X(iE,:), z(iE), tipos{k});
        RMSEval(k) = sqrt(mean((z(iV) - sfE(X(iV,1), X(iV,2))).^2, 'omitnan'));
    catch
    end
end
warning('on','all');
Tabla = sortrows(table(tipos', R2, RMSE, RMSEval, ...
    'VariableNames', {'Modelo','R2','RMSE','RMSE_validacion'}), 'RMSE_validacion')

% Los interpolantes pasan por todos los puntos (R2 = 1) y copian el ruido,
% por eso se elige el modelo de regresión con menor error de validación.
TablaReg = Tabla(~endsWith(Tabla.Modelo,'interp') & ~isnan(Tabla.RMSE_validacion), :);
mejor = TablaReg.Modelo{1};
sf = fit(X, z, mejor);
fprintf('Mejor superficie de ajuste: %s\n', mejor);

%% Ítem 4. Gráficos de la superficie de ajuste
[Xg, Yg] = meshgrid(linspace(min(s1),max(s1),150), linspace(min(s2),max(s2),150));
Zg = sf(Xg, Yg);

figure(3);
surf(Xg, Yg, Zg, 'EdgeColor', 'none');
title(['Ítem 4 i): Superficie de ajuste (' mejor ')']);
xlabel('sensor_1 [V]'); ylabel('sensor_2 [V]'); zlabel('Señal desempeño [V]');
cb = colorbar; cb.Label.String = 'Amplitud [V]'; caxis([-5 5]); colormap(jet);
grid on; view(-35, 30);

figure(4);
surf(Xg, Yg, Zg, 'EdgeColor', 'none', 'FaceAlpha', 0.75); hold on;
plot3(s1, s2, z, 'k.', 'MarkerSize', 8); hold off;
title(['Ítem 4 ii): Superficie de ajuste (' mejor ') y datos originales']);
xlabel('sensor_1 [V]'); ylabel('sensor_2 [V]'); zlabel('Señal desempeño [V]');
cb = colorbar; cb.Label.String = 'Amplitud [V]'; caxis([-5 5]); colormap(jet);
legend('Superficie de ajuste', 'Datos originales'); grid on; view(-35, 30);

%% Ítem 5a. Máximo y mínimo en la superficie ajustada
[zMaxA, kMax] = max(Zg(:));
[zMinA, kMin] = min(Zg(:));
fprintf('Superficie -> MÁXIMO: %.4f V en sensor1 = %.4f V, sensor2 = %.4f V\n', zMaxA, Xg(kMax), Yg(kMax));
fprintf('Superficie -> MÍNIMO: %.4f V en sensor1 = %.4f V, sensor2 = %.4f V\n', zMinA, Xg(kMin), Yg(kMin));

% RESPUESTA 5a:
% No son los mismos puntos. En los datos brutos el máximo es 7,88 V en
% (sensor1, sensor2) = (0,41; 1,67) V y el mínimo es -6,08 V en
% (0,34; -1,78) V. En la superficie ajustada los extremos quedan en la misma
% zona del plano pero en otra posición y con mucha menor amplitud (ver los
% valores impresos arriba).
% La diferencia se produce porque cada dato bruto es tendencia + ruido. El
% máximo bruto es la muestra donde el ruido fue más positivo y el mínimo
% donde fue más negativo, o sea, son picos de ruido. La superficie de ajuste
% minimiza el error de los 800 puntos a la vez y promedia el ruido, por eso
% sus extremos representan el comportamiento real de la planta. El suavizado
% también recorta un poco los picos angostos, por eso la amplitud baja.

%% Ítem 5b. Puntos brutos vs. superficie ajustada
% RESPUESTA 5b:
% Es mejor usar la superficie ajustada. Los puntos brutos traen el ruido
% mezclado con la información: ajustar la planta hacia el máximo bruto es
% perseguir un pico de ruido que no se repetirá. La superficie resume los
% 800 datos en un modelo continuo que se puede evaluar en cualquier punto.
%
% Limitante: la superficie se calcula con los primeros 500 ms y se usa en
% los 500 ms siguientes, así que la planta no debe cambiar en ese tiempo
% (solo vale porque es de baja dinámica). También el tiempo de cálculo del
% ajuste debe caber en el ciclo y la superficie solo es confiable dentro del
% rango medido de los sensores.
%
% (Opcional) Ejemplo donde no sirve: una planta de dinámica rápida, como el
% control de corriente de un motor, un convertidor conmutado o la
% estabilización de un dron, que cambian en milisegundos.
%
% (Opcional) Región de trabajo: alrededor del máximo de la superficie, en
% la parte donde la superficie es más plana, porque ahí pequeñas variaciones
% o ruido en los sensores casi no bajan el desempeño.

%% Ítem 5c (Opcional). Agente de IA
% RESPUESTA 5c:
% Sí es factible si los tiempos alcanzan. Un agente de IA (por ejemplo,
% aprendizaje por refuerzo u optimización bayesiana) puede guardar el
% historial de cada ventana (sensores, ajuste aplicado, desempeño obtenido),
% aprender qué ajustes funcionaron mejor y anticipar la deriva lenta de la
% planta. Debe operar dentro de límites seguros (rango de ±5 V y zonas ya
% medidas), con suficientes datos para no aprender el ruido y con
% supervisión humana para poder revertir sus decisiones.
