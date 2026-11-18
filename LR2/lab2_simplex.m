% Лабораторная работа №2. Методы нулевого порядка
% Симплекс-метод (поиск по регулярному симплексу). Вариант 30
% f(x) = (x1 + 7*x2)^2 + (x1 - 1)^2 -> min, начальная точка x0 = (2; 1)
clc; clear; close all;

f    = @(x) (x(1) + 7*x(2))^2 + (x(1) - 1)^2;   % целевая функция
x0   = [2 1];             % начальная точка
l    = 4;                 % длина ребра симплекса
c    = 2;                 % коэффициент уменьшения ребра при редукции
e    = 1.5;               % точность: поиск заканчивается при l < e
n    = 2;                 % размерность задачи
Kmax = 100;               % ограничение на число итераций

% Приращения координат для построения регулярного симплекса с ребром l
d1 = (sqrt(n+1) + n - 1) / (n*sqrt(2)) * l;
d2 = (sqrt(n+1) - 1)     / (n*sqrt(2)) * l;
X  = [x0; x0 + [d1 d2]; x0 + [d2 d1]];      % вершины симплекса (по строкам)
F  = [f(X(1,:)); f(X(2,:)); f(X(3,:))];     % значения функции в вершинах

fprintf('d1 = %.4f, d2 = %.4f\n\n', d1, d2);

T    = [];   % таблица: k, l, x1(1..3), x2(1..3), f(1..3), j, xr1, xr2, f(xr), действие
S    = {};   % симплексы всех итераций для графика
last = 0;    % номер вершины, полученной на предыдущей итерации
k    = 0;
while l >= e && k < Kmax
    S{end+1} = X;
    [Fs, idx] = sort(F, 'descend');   % idx(1) - наихудшая вершина, idx(n+1) - наилучшая
    ok = 0;
    jt = 0; xt = [NaN NaN]; ft = NaN;   % последняя неудачная попытка отражения
    for j = idx(1:n)'                 % отражаем вершины по убыванию f, кроме наилучшей
        if j == last
            continue;                 % только что полученную вершину не отражаем
        end
        xc = (sum(X, 1) - X(j,:)) / n;   % центр тяжести противолежащей грани
        xr = 2*xc - X(j,:);              % отраженная вершина
        fr = f(xr);
        if fr < F(j)                  % отражение удачное
            T(end+1,:) = [k l X(:,1)' X(:,2)' F' j xr fr 1];
            X(j,:) = xr;
            F(j)   = fr;
            last   = j;
            ok     = 1;
            break;
        end
        jt = j; xt = xr; ft = fr;
    end
    if ~ok                            % все отражения неудачны - редукция симплекса
        b = idx(n+1);                 % наилучшая вершина
        T(end+1,:) = [k l X(:,1)' X(:,2)' F' jt xt ft 2];
        X = repmat(X(b,:), n+1, 1) + (X - repmat(X(b,:), n+1, 1)) / c;
        F = [f(X(1,:)); f(X(2,:)); f(X(3,:))];
        l = l / c;
        last = 0;
    end
    k = k + 1;
end
S{end+1} = X;

[fmin, b] = min(F);
xmin = X(b,:);

% Вывод таблицы
fprintf('%3s %6s %18s %18s %18s %9s %9s %9s %2s %18s %9s %s\n', 'k', 'l', ...
        'X1', 'X2', 'X3', 'f(X1)', 'f(X2)', 'f(X3)', 'j', 'Xr', 'f(Xr)', 'действие');
for i = 1:size(T, 1)
    r = T(i,:);
    if r(16) == 1
        act = 'отражение';
    else
        act = 'неудача, редукция';
    end
    fprintf(['%3d %6.2f (%7.4f;%7.4f) (%7.4f;%7.4f) (%7.4f;%7.4f) ', ...
             '%9.4f %9.4f %9.4f %2d (%7.4f;%7.4f) %9.4f %s\n'], ...
            r(1), r(2), r(3), r(6), r(4), r(7), r(5), r(8), r(9), r(10), r(11), ...
            r(12), r(13), r(14), r(15), act);
end
fprintf('\nКонечный симплекс (l = %.2f < e = %.2f):\n', l, e);
for i = 1:n+1
    fprintf('  X%d = (%.4f; %.4f), f = %.4f\n', i, X(i,1), X(i,2), F(i));
end
fprintf('Точка минимума x* = (%.4f; %.4f), f(x*) = %.6f, итераций %d\n', ...
        xmin(1), xmin(2), fmin, k);

% Сохранение таблицы для отчета
dlmwrite('lab2_table.csv', T, 'delimiter', ';', 'precision', '%.6f');
dlmwrite('lab2_result.csv', [X F; xmin fmin; l k 0], 'delimiter', ';', 'precision', '%.6f');

% График: линии уровня функции и последовательность симплексов
P  = cell2mat(S');
x1 = linspace(min(P(:,1)) - 1, max(P(:,1)) + 1, 200);
x2 = linspace(min(P(:,2)) - 1, max(P(:,2)) + 1, 200);
[X1, X2] = meshgrid(x1, x2);
Z = (X1 + 7*X2).^2 + (X1 - 1).^2;
h = figure('Color', 'w');
contour(X1, X2, Z, [1 5 10 25 50 100 200 400 700 1000 1500]); hold on; grid on;
for i = 1:length(S)
    V = S{i}([1 2 3 1], :);
    hs = plot(V(:,1), V(:,2), 'b-', 'LineWidth', 1);
end
V  = S{end}([1 2 3 1], :);
hf = plot(V(:,1), V(:,2), 'r-', 'LineWidth', 2);
h0 = plot(x0(1), x0(2), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
hm = plot(xmin(1), xmin(2), 'rp', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
he = plot(1, -1/7, 'k+', 'MarkerSize', 12, 'LineWidth', 2);
axis equal;
legend([hs hf h0 hm he], 'симплексы', 'конечный симплекс', 'x^0', 'x*', ...
       'точный минимум', 'Location', 'NorthWest');
xlabel('x_1'); ylabel('x_2');
title('f(x) = (x_1+7x_2)^2+(x_1-1)^2, симплекс-метод');
print(h, '-dpng', '-r150', 'lab2_graph.png');
