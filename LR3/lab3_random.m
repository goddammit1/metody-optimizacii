% Лабораторная работа №3. Методы случайного поиска. Вариант 30
% f(x) = (x1 + 7*x2)^2 + (x1 - 1)^2 -> min
% 1) слепой (простой) случайный поиск: N = 100000 точек в области [A,B]x[C,D]
% 2) адаптивный случайный поиск: x0 = (9; -5), dx = 11, c = 10, eps = 0.001
%    (точки в квадрате x0 +- dx; после неудачного прогона dx сжимается в c раз)
clc; clear; close all;

f = @(x1, x2) (x1 + 7*x2).^2 + (x1 - 1).^2;   % целевая функция
rand('twister', 30);      % фиксированное состояние генератора (повторяемость)

%% 1. Слепой (простой) случайный поиск
A = -29; B = -24;         % диапазон по x1
C = -12; D = 30;          % диапазон по x2
N = 100000;               % количество точек

P1 = zeros(N, 2);         % все сгенерированные точки (для графика)
T1 = zeros(20, 6);        % первые 20 точек: i, x1, x2, f, лучшее x1, x2, f
xs = [NaN NaN]; fs = Inf; ks = 0;
for i = 1:N
    x  = [A + (B - A)*rand, C + (D - C)*rand];   % равномерно в [A,B]x[C,D]
    fx = f(x(1), x(2));
    if fx < fs                % запоминаем лучшую точку
        xs = x; fs = fx; ks = i;
    end
    P1(i,:) = x;
    if i <= 20
        T1(i,:) = [i x fx fs ks];
    end
end

fprintf('1. Слепой случайный поиск, N = %d\n', N);
fprintf('%4s %10s %10s %12s %12s %6s\n', 'i', 'x1', 'x2', 'f(x)', 'f лучш.', 'i лучш.');
for i = 1:20
    fprintf('%4d %10.4f %10.4f %12.4f %12.4f %6d\n', T1(i,:));
end
fprintf('Минимум: x* = (%.4f; %.4f), f(x*) = %.4f (точка № %d)\n\n', ...
        xs(1), xs(2), fs, ks);

%% 2. Адаптивный случайный поиск
x0 = [9 -5];              % начальная точка
dx = 11;                  % начальный диапазон
c  = 10;                  % константа сжатия диапазона
e  = 0.001;               % точность: поиск заканчивается при dx < e
M  = 100;                 % количество точек в одном прогоне

xa = x0; fa = f(x0(1), x0(2));
T2 = [];                  % прогоны: r, x0(1), x0(2), f(x0), dx, xлучш(1), xлучш(2), f, успех
T3 = [];                  % первые 20 точек каждого прогона: r, i, x1, x2, f
r  = 0;
while dx >= e
    r  = r + 1;
    xb = xa; fb = fa;     % лучшая точка прогона (начинаем с центра)
    for i = 1:M
        x  = xa + dx*(2*rand(1, 2) - 1);   % точка в квадрате [xa - dx, xa + dx]
        fx = f(x(1), x(2));
        if fx < fb
            xb = x; fb = fx;
        end
        if i <= 20
            T3(end+1,:) = [r i x fx];
        end
    end
    ok = fb < fa;         % найдена ли точка лучше начальной
    T2(end+1,:) = [r xa fa dx xb fb ok];
    if ok
        xa = xb; fa = fb; % лучшая точка - начальная для следующего прогона
    else
        dx = dx / c;      % неудачный прогон - сжатие диапазона
    end
end

fprintf('2. Адаптивный случайный поиск, M = %d точек в прогоне\n', M);
fprintf('Первые 20 точек первого прогона:\n');
fprintf('%4s %10s %10s %12s\n', 'i', 'x1', 'x2', 'f(x)');
for i = 1:20
    fprintf('%4d %10.4f %10.4f %12.4f\n', T3(i, 2:5));
end
fprintf('\n%3s %22s %12s %9s %22s %12s %s\n', 'r', 'начальная точка', 'f', 'dx', ...
        'лучшая точка', 'f', 'результат');
for i = 1:size(T2, 1)
    if T2(i,9)
        act = 'переход';
    else
        act = 'сжатие dx';
    end
    fprintf('%3d (%9.5f;%9.5f) %12.6g %9.5f (%9.5f;%9.5f) %12.6g %s\n', T2(i,1:8), act);
end
fprintf('Минимум: x* = (%.5f; %.5f), f(x*) = %.3e, прогонов %d, dx = %.5f < e\n', ...
        xa(1), xa(2), fa, r, dx);

% Сохранение таблиц для отчета
dlmwrite('lab3_blind.csv', [T1; 0 xs fs fs ks], 'delimiter', ';', 'precision', '%.6f');
dlmwrite('lab3_adapt_runs.csv', T2, 'delimiter', ';', 'precision', '%.10g');
dlmwrite('lab3_adapt_points.csv', T3, 'delimiter', ';', 'precision', '%.6f');
dlmwrite('lab3_result.csv', [xs fs; xa fa], 'delimiter', ';', 'precision', '%.10g');

%% Графики
% Рис. 1: точки слепого поиска (первые 3000) и найденный минимум
h = figure('Color', 'w');
[G1, G2] = meshgrid(linspace(A, B, 200), linspace(C, D, 200));
contour(G1, G2, f(G1, G2), [700 1000 2000 5000 10000 20000 40000]); hold on; grid on;
hp = plot(P1(1:3000,1), P1(1:3000,2), 'b.', 'MarkerSize', 3);
hm = plot(xs(1), xs(2), 'rp', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
xlabel('x_1'); ylabel('x_2'); axis([A B C D]);
legend([hp hm], 'случайные точки', 'x*', 'Location', 'NorthEast');
title('Слепой случайный поиск (показаны 3000 из 100000 точек)');
print(h, '-dpng', '-r150', 'lab3_blind.png');

% Рис. 2: области прогонов адаптивного поиска и траектория центров
h = figure('Color', 'w');
[G1, G2] = meshgrid(linspace(-3, 21, 200), linspace(-17, 7, 200));
contour(G1, G2, f(G1, G2), [1 5 10 25 50 100 200 400 700 1000 1500]); hold on; grid on;
for i = 1:size(T2, 1)
    q = T2(i, 2:3); d = T2(i, 5);
    hs = plot(q(1) + d*[-1 1 1 -1 -1], q(2) + d*[-1 -1 1 1 -1], 'b-');
end
Q  = [T2(:, 2:3); xa];
ht = plot(Q(:,1), Q(:,2), 'r-o', 'LineWidth', 1.5, 'MarkerSize', 5);
h0 = plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
hm = plot(xa(1), xa(2), 'rp', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
he = plot(1, -1/7, 'k+', 'MarkerSize', 12, 'LineWidth', 2);
axis equal; axis([-3 21 -17 7]);
legend([hs ht h0 hm he], 'области прогонов', 'центры прогонов', 'x^0', 'x*', ...
       'точный минимум', 'Location', 'NorthEast');
xlabel('x_1'); ylabel('x_2');
title('Адаптивный случайный поиск: области прогонов');
print(h, '-dpng', '-r150', 'lab3_adapt.png');
