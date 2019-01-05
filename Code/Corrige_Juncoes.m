%% ***************************************************************************************************************************************
%
% 																Corrige_Juncoes
%															
%	Esta função é chamada quando há o desaparecimento de uma região e outra duplica o seu número de pontos. 
%  O primeiro passo é encontrar as duas regiões que se juntaram numa só, e o segundo é proceder à sua separação, calculando dois novos centroides a partir %%  do centroid da região que se juntou. 
%  O que se tem até aqui é um objeto (tracked_objs{Regiao_Junta}) que tem todas as coordenadas da região até à junção, mais as do centróide da regiao_Junta.
%  E outro objeto que tem também as suas coordenadas todas, até uma iteração onde morre (porque se terá juntado ao outro, e ficou o outro com as coordenadas %%  da junção). O objetivo é que as coordenadas da junção dêm origem as duas novas coordenadas, uma para cada objeto que se juntou nessa região. Assim sendo, %%  o objeto que ficou com as coordenadas da junção deve atualizá-las para a sua nova que for calculada, e o objeto que morrer deve acrescentar à sua 
%  trajetória também novas coordenadas, primeiro as resultantes da junção, e depois todas as outras de um objeto que tiver sido criado quando este morreu,
%  que no fim desta função ele já saberá que faz parte da mesma trajetória depois da junção.
%
%% ***************************************************************************************************************************************
%    Francisco Oliveira nº 75167				Inês Lourenço nº 75637				Nuno Lages nº 82162
%% ***************************************************************************************************************************************

function [tracked_objs, Centroids_Actual] = Corrige_Juncoes(index, tracked_objs, Centroids_Actual, Centroids_Anterior, Regiao_Junta) 

% O Indice_Actual identifica na regiao_Junta o número da linha em que ocorreu a junção, e o Indice_anterior o anterior, que corresponde à situação em que
% os centroids ainda estavam separados antes da junção
Indice_Actual = size(tracked_objs{Regiao_Junta}, 1); 	
Indice_Anterior = Indice_Actual - 1;

% Vai buscar toda a linha correspondente às duas situações (da junção, e antes)
Info_Mau = tracked_objs{Regiao_Junta}(Indice_Actual, :); 	
Info_Pre_Mau = tracked_objs{Regiao_Junta}(Indice_Anterior, :);

% Vai buscar só as duas colunas, o x e o y, dessas linhas
Coord_Anterior = Info_Pre_Mau(1:2); 	
Coord_Estragadas = Info_Mau(1:2);

% Inicializa a distância a infinito, para assim que encontrar uma menor substituir
min_dist = inf;
Closest_Obj = 0;  

% Vai percorrer todos os objetos existentes antes da junção e ver qual deles tem a menor distância ao que se juntou
for i = 1:size(Centroids_Anterior, 1)

    dist = sqrt((Centroids_Anterior(i, 1) - Coord_Anterior(1))^2 + (Centroids_Anterior(i, 2) - Coord_Anterior(2))^2);
    
    if (dist < min_dist) && (dist ~= 0)
        
        min_dist = dist; 
		% Closest_Obj corresponde à linha do centroids anteriores em que se encontra a coord mais próxima		
        Closest_Obj = i;
    
    end
end

% Procura o objeto que se juntou ao objeto Regiao_Junta 
for k = 1:size(tracked_objs, 2) 	
	
	% Vai procurar as ultimas coordenadas de todos os objetos
    ultima_coordenada = size(tracked_objs{k}, 1);
   
	% Vê se a ultima coordenada é igual às coordenadas do centroide
    if tracked_objs{k}(ultima_coordenada, 1:2) == Centroids_Anterior(Closest_Obj, :)
       
	   % Guarda essa linha
       Last_Info = tracked_objs{k}(ultima_coordenada, :); 
       break
       
   end

end

% Até aqui foram identificadas as duas regiões que se juntaram
% No tracked_objs do objeto que se juntou mas foi considerado como morto, adiciona-se uma linha depois da última, com novas coordenadas para esse
% objeto, baseadas numa média entre as coordenadas onde tinha desaparecido e as coordenadas da Regiao_Junta onde ele se foi juntar
Coord_Perdidas = [(Centroids_Anterior(Closest_Obj, 1) + Coord_Estragadas(1))/2, (Centroids_Anterior(Closest_Obj, 2) + Coord_Estragadas(2))/2]; 
% A distância será uma soma da que tinha sido até morrer, mais a distância entre as coordenadas onde morreu e as novas coordenadas calculadas (coord_Perdidas)
dist_local = sqrt((Coord_Perdidas(1) - Last_Info(1))^2 + (Coord_Perdidas(2) - Last_Info(2))^2);
dist_total = Last_Info(5) + dist_local;
tracked_objs{k} = vertcat(tracked_objs{k}, [Coord_Perdidas, 0, index, dist_total, Info_Mau(6)/2]);

% Agora é preciso atualizar também as coordenadas do outro objeto que se juntou à região, substituindo a linha que tinha as do centroide da regiao_Junta.
Coord_Atualizada = [(Coord_Anterior(1) + Coord_Estragadas(1))/2, (Coord_Anterior(2) + Coord_Estragadas(2))/2];
dist_local = sqrt((Coord_Anterior(1) - Coord_Atualizada(1))^2 + (Coord_Anterior(2) - Coord_Atualizada(2))^2);
dist_total = Info_Pre_Mau(5) + dist_local;
tracked_objs{Regiao_Junta}(Indice_Actual, :) = [Coord_Atualizada, 0, index, dist_total, Info_Mau(6)/2];

% Falta atualizar no Centroids_Actual estas novas coordenadas atualizadas calculadas, eliminando a da região que ficou junta
linha_centroid = find(Centroids_Actual == Coord_Estragadas(1));
Centroids_Actual(linha_centroid, :) = Coord_Atualizada;

Centroids_Actual = vertcat(Centroids_Actual, Coord_Perdidas);


end