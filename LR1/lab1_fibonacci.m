% Лабораторная работа №1. Методы одномерного поиска
% Метод Фибоначчи. Вариант 30
% f(x) = (x-1)^2 -> min на интервале [-2; 10]
clc; clear; close all;

f    = @(x) (x - 1).^2;   % целевая функция
a0   = -2;                % левая граница начального интервала
b0   = 10;                % правая граница начального интервала
l    = 1;                 % допустимая длина конечного интервала
e    = 0.01;              % константа различимости (точность поиска)
Nmax = 10;                % максимальное число итераций

% Числа Фибоначчи: F0 = F1 = 1, Fk = F(k-1) + F(k-2).
% Индексация в MATLAB начинается с 1, поэтому F(j+1) хранит число F_j
F = [1 1];
while F(end) < (b0 - a0) / l
    F(end+1) = F(end) + F(end-1);
end
N = length(F) - 1;        % наименьшее N, при котором F_N >= (b0-a0)/l

fprintf('Числа Фибоначчи: %s\n', num2str(F));
fprintf('N = %d, F_N = %d >= (b-a)/l = %g\n\n', N, F(N+1), (b0 - a0) / l);

% Начальные точки: x1 = a + F_(N-2)/F_N*(b-a), x2 = a + F_(N-1)/F_N*(b-a)
a  = a0;
b  = b0;
x1 = a + F(N-1) / F(N+1) * (b - a);
x2 = a + F(N)   / F(N+1) * (b - a);

T = [];                   % таблица: k, ak, bk, x1k, x2k, f(x1k), f(x2k)
for k = 0:N-3
    f1 = f(x1);
    f2 = f(x2);
    T(end+1, :) = [k a b x1 x2 f1 f2];
    if f1 <= f2           % минимум в [a; x2]
        b  = x2;
        x2 = x1;
        x1 = a + F(N-k-2) / F(N-k) * (b - a);   % F_(N-k-3)/F_(N-k-1)
    else                  % минимум в [x1; b]
        a  = x1;
        x1 = x2;
        x2 = a + F(N-k-1) / F(N-k) * (b - a);   % F_(N-k-2)/F_(N-k-1)
    end
    if k + 1 >= Nmax
        break;
    end
end

% Последний шаг: точки совпали в середине интервала,
% вторую точку сдвигаем на константу различимости e
k  = N - 2;
x2 = x1 + e;
f1 = f(x1);
f2 = f(x2);
T(end+1, :) = [k a b x1 x2 f1 f2];
if f1 <= f2
    b = x2;
else
    a = x1;
end

xmin = (a + b) / 2;
fmin = f(xmin);

% Вывод таблицы
fprintf('%3s %9s %9s %9s %9s %10s %10s\n', ...
        'k', 'ak', 'bk', 'x1k', 'x2k', 'f(x1k)', 'f(x2k)');
for i = 1:size(T, 1)
    fprintf('%3d %9.4f %9.4f %9.4f %9.4f %10.4f %10.4f\n', T(i, :));
end
fprintf('\nКонечный интервал: [%.4f; %.4f], длина %.4f\n', a, b, b - a);
fprintf('Точка минимума x* = %.4f, f(x*) = %.6f\n', xmin, fmin);

% Сохранение таблицы для отчета
dlmwrite('lab1_table.csv', T, 'delimiter', ';', 'precision', '%.6f');
dlmwrite('lab1_result.csv', [a b xmin fmin N], 'delimiter', ';', 'precision', '%.6f');

% График функции на [a0; b0] с шагом 0.05
x = a0:0.05:b0;
h = figure('Color', 'w');
plot(x, f(x), 'b-', 'LineWidth', 1.5); hold on; grid on;
plot(T(:, 4), T(:, 6), 'ko', 'MarkerFaceColor', 'g');
plot(T(:, 5), T(:, 7), 'ks', 'MarkerFaceColor', 'y');
plot(xmin, fmin, 'rp', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
xlabel('x'); ylabel('f(x)');
title('f(x) = (x-1)^2, метод Фибоначчи');
legend('f(x)', 'x_{1k}', 'x_{2k}', 'x*', 'Location', 'North');
print(h, '-dpng', '-r150', 'lab1_graph.png');
