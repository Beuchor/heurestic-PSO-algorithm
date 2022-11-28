clc
clear all
close all

% stałe parametry 
iter_max = 250;     % max ilosc iter
v_max = 2;          % predkosc max
v_min = -2;         % predkosc min
w = 1.3;  %1.2      % bezwladnosc czastki
fl = 0.5; %0.4      % wsp dąż do max lok
fg = 6;   %6        % wsp dąż do max glob


% wywołanie funkcji z optymalizowanego modelu 
m = Model;
m.losowaniePredkosci(v_max);
m.losowaniePozycji();
m.kiStart();


%Główna pętla iteracji algorytmu
for iter=1:iter_max
m.kiCalc();
m.maxLoc();
m.fCelu();
m.maxGlob(iter);
m.oldfCelu(iter);
m.maxGlob2();
m.velocity(w,fl,fg,v_max,v_min);
m.movement();
pause(0.005);
m.rozmieszczenie();
m.historyczne(iter);
end

% Wyświetlenie wartości
m.najlepszePolozenia();
m.najlepszeRozwiazania()

