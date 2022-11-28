classdef Model < handle
    properties (Access = public)
        % Dane modelu
        Populacja = 3;
        ilosc_gniazd = 12;
        Wi = [100 200 327 440 450 639 650 678 750 801 945 967];
        Wx = [25 23 7 95 3 54 67 32 24 66 84 34];
        Wy = [65 8 13 53 3 56 78 4 76 89 4 23];

%PARAMETRY DO POPRAWNEGO WYSWIETLANIA KLAS/POPRAWNEGO DZIAŁANIA MATLABA
%//////////////////////////////////DO ZIGNOROWANIA/////////////////////
        Cx;
        Cy;
        Cx_max;
        Cy_max;
        ki_max = zeros;
        ki = zeros;
        kj;
        K;
        Fcelu_max=0;
        Suma_Wi = 0;
        Suma_Ki = 0;
        vx_new = zeros;
        vy_new = zeros;
        F_celu = zeros;
        F_cel_old =zeros;
        Cxnew = zeros;
        Cynew = zeros;
        Xglob = zeros(1,3);
        Yglob = zeros(1,3);
        vx;
        vy;
        histF_celu;
        histVx_new;
        histVy_new;
        histXglob;
        histYglob;
%//////////////////////////////////DO ZIGNOROWANIA/////////////////////
    end


% FUNKCJE MODELU
methods
    function losowaniePredkosci(a,v_max)
for i=1:a.Populacja
a.vx(i) = 2*v_max*rand()-v_max; % vx pojemnika/cząstki
a.vy(i) = 2*v_max*rand()-v_max; % vy pojemnika/cząstki
end
    end

    function kiStart(a)
        a.ki_max = zeros(1,a.Populacja);
        a.ki = zeros(1,a.Populacja); 
    end

    function losowaniePozycji(a)
    %obliczenie sumy os
        for i=1:a.ilosc_gniazd 
        a.Suma_Wi = a.Suma_Wi + a.Wi(i);
        end 
        for i=1:a.Populacja
        % generowanie losowych położeń dla 3 pojemników
        a.Cx(i) = rand*100;   %  poł x wiadra/cząstki
        a.Cy(i) = rand*100;   % poł y wiadra/cząstki
        %przypisanie położeń lokalnych jako aktualne najlepsze lokalne
        a.Cx_max(i) = a.Cx(i);
        a.Cy_max(i) = a.Cy(i);
        end
    end
    
    function kiCalc(a)      % obliczanie ilości os zabijanych przez dany pojemnik
        a.Suma_Ki = 0;
        a.ki=zeros(1,a.Populacja);
        for i=1:a.ilosc_gniazd 
            for j=1:a.Populacja 
                 a.kj(j) = (a.Wi(i)*141.42)/(20*sqrt((a.Wx(i)-a.Cx(j))^2+(a.Wy(i)-a.Cy(j))^2)+0.0001);
                 a.ki(j) = a.ki(j) + a.kj(j);    
            end

        a.K(i) = a.kj(1)+a.kj(2)+a.kj(3);

            if a.K(i) > a.Wi(i)
               a.K(i) = a.Wi(i);   
            end

            a.Suma_Ki = a.Suma_Ki + a.K(i);
        end
    end

    function maxLoc(a)
        for j=1:a.Populacja
            if a.ki(j) > a.ki_max(j)
                a.ki_max(j) = a.ki(j);
                a.Cx_max(j) = a.Cx(j);
                a.Cy_max(j) = a.Cy(j);
            end
        end
    end

    % Obliczanie funkcji celu
    function fCelu(a)
        a.F_celu = 100*a.Suma_Ki/a.Suma_Wi;

    end
    % wyznaczanie wartości dla rozwiązania globalnego
    function maxGlob(a,iter)
        if a.F_celu > a.F_cel_old
            for i=1:a.Populacja
                a.Xglob(i) = a.Cx(i);
                a.Yglob(i) = a.Cy(i);  
            end
        end
        for i=1:a.Populacja
            a.histXglob(i,iter) = a.Xglob(i);
            a.histYglob(i,iter) = a.Yglob(i);
end

    end
    function oldfCelu(a, iter)
                  a.F_cel_old = a.F_celu; 
                  a.histF_celu(iter)=a.F_celu
    end

    function maxGlob2(a)
    poz_max_FC = find(a.histF_celu==max(a.histF_celu));
        for i = 1:a.Populacja
            a.Xglob(i) = a.histXglob(i,poz_max_FC);
            a.Yglob(i) = a.histYglob(i,poz_max_FC);
        end
    
    end

    % Obliczenia nowych prędkości cząstek
    function velocity(a,w,fl,fg,v_max,v_min)
        for i = 1:a.Populacja 
            a.vx_new(i) = w*a.vx(i) + fl*rand()*(a.Cx_max(i) - a.Cx(i)) + fg*rand()*(a.Xglob(i) - a.Cx(i));
            a.vy_new(i) = w*a.vy(i) + fl*rand()*(a.Cy_max(i) - a.Cy(i)) + fg*rand()*(a.Yglob(i) - a.Cy(i));
        % ograniczenia prędkości
                if a.vx_new(i) > v_max
                    a.vx_new(i) = v_max ;
                end
                if a.vy_new(i) > v_max
                    a.vy_new(i) = v_max ;
                end
                
                if a.vx_new(i) < v_min
                    a.vx_new(i) = v_min ;
                end
                if a.vy_new(i) < v_min
                    a.vy_new(i) = v_min ;
                end
            % przypisanie nowych wartości prędkości
            a.vx(i) = a.vx_new(i);
            a.vy(i) = a.vy_new(i);
        end
    end
    % Wygenerowanie nowych położeń
    function movement(a)
        for i=1:a.Populacja
            a.Cxnew(i) = a.Cx(i) + a.vx(i);
            a.Cynew(i) = a.Cy(i) + a.vy(i);
            a.Cx(i) = a.Cxnew(i);
            a.Cy(i) = a.Cynew(i);
        end
    end


    % Przedstawienie położeń na wykresie
    function rozmieszczenie(a)
       subplot(2,2,1)
       plot(a.Cx(1),a.Cy(1),'X red')
       plot(a.Cx(2),a.Cy(2),'X green')
       plot(a.Cx(3),a.Cy(3),'X blue')

          for i=1:a.ilosc_gniazd 
               f = plot(a.Wx(i),a.Wy(i),'O yellow');
               f.LineWidth = 4;
               hold on;
          end

    end

    % zmienne potrzebne do analizy poprawności działania programu
    function historyczne(a,iter)

        a.histVx_new(:,iter)=a.vx
        a.histVy_new(:,iter)=a.vy
        subplot(2,2,2)
        plot(a.histF_celu)
        hold on
   end
    
   % Przedstawienie na wykresie optymalnych znalezionych położeń
   function najlepszePolozenia(a)
       subplot(2,2,3);
       for i=1:a.ilosc_gniazd 
           plot(a.Wx(i),a.Wy(i),'X black')
           hold on;
       end
       subplot(2,2,3);
        plot(a.Xglob(1),a.Yglob(1),'o red')
        plot(a.Xglob(2),a.Yglob(2),'o green')
        plot(a.Xglob(3),a.Yglob(3),'o blue')
   end
   % Wyświetlenie w oknie komend otrzymanych wartości
   function najlepszeRozwiazania(a)
        disp('Najlepsze rozwiązania:')
        for i = a.Populacja
        disp('wektor X')    
        disp(a.Xglob(1:i))
        disp('wektor Y')    
        disp(a.Yglob(1:i))
        disp('')
        disp('Największa wartość funkcji celu: ')
        disp(max(a.histF_celu))
        end
        
      end
end
end


