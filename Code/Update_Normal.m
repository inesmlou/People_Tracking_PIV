%% ***************************************************************************************************************************************
%
% 																Update_Normal
%															
%	Atualiza a estrutura de todas as coordenadas das trajetórias de todos os objetos
% 
%% ***************************************************************************************************************************************
%    Francisco Oliveira nº 75167				Inês Lourenço nº 75637				Nuno Lages nº 82162
%% ***************************************************************************************************************************************


function tracked_objs = Update_Normal(i, ass, tracked_objs, Centroids_Anterior, Centroids_Actual, n_pontos)


% Neste ciclo vê-se a que estrutura do cell array pertence o centroide anterior
for k = 1:numel(ass)

   for m = 1:numel(tracked_objs)

        ultima_coordenada = size(tracked_objs{m}, 1);

        if Centroids_Anterior(k, :) == tracked_objs{m}(ultima_coordenada, 1:2)

            break

        end
   end

   if ass(k) ~= 0
       
        tracked_objs{m} = vertcat(tracked_objs{m}, [Centroids_Actual(ass(k), :) 0 i 0 n_pontos(ass(k))]);
        
		% Identificação de variáveis
        indice_d = size(tracked_objs{m}, 1);
        x_anterior = tracked_objs{m}(indice_d - 1, 1);
        x_atual = tracked_objs{m}(indice_d, 1);
        y_anterior = tracked_objs{m}(indice_d - 1, 2);
        y_atual = tracked_objs{m}(indice_d, 2);
        
		% Cálculo da distância anterior
        d_anterior = tracked_objs{m}(ultima_coordenada, 5);
		% Cálculo da nova distância até ao novo centroid calculado
        d_percorrida = sqrt((x_anterior - x_atual)^2 + (y_anterior - y_atual)^2);
		
        % Para evitar erros
		if d_percorrida > 100
		
			d_percorrida = 0;
			
        end
        
        % Distância acumulada
        tracked_objs{m}(indice_d, 5) = d_percorrida + d_anterior;
								
   end
       
end
