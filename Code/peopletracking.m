% ***************************************************************************************************************************************
%
% 																People Tracking
%															
%
% ***************************************************************************************************************************************
%    Francisco Oliveira n� 75167				In�s Louren�o n� 75637				Nuno Lages n� 82162
% ***************************************************************************************************************************************
%	
%			     _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
% 				|   																										  |
% 				|   Para visualizar o movimento das pessoas, identificadas pelos seus centroides, � medida que o programa 	  |
% 				|   corre e as imagens passam, basta descomentar as linhas 210 e 211, e 336 e 337.	             			  |
% 				|   � importante notar que o funcionamento do algoritmo n�o est� 100% representado nestas imagens uma vez     |
% 				|   que algumas correc��es finais s�o apenas feitas ap�s o plot das imagens, nomeadamente a elimina��o do	  |
% 				|   lixo, ou seja, a fun��o retorna apenas os objetos que t�m um percurso relevante, no entanto no plot,      | 
% 				|   quando uma regi�o aparece em duas ou tr�s imagens o seu centroide aparece representado, embora n�o        |  
% 				|   se trate de facto de uma pessoa que se queira seguir.													  |																										  |																			  |
% 				|_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _|
%

function tracked_objs = peopletracking(file_names, depth_cam, rgb_cam, Rdtrgb, Tdtrgb)

%clear;
%clc;
%close all;

%% ------------------------------------------------- Obter o Background ------------------------------------------------------ %%
x_max = 0; 
y_max = 0;
x_min = 0;
y_min = 0;

Depth_cam = depth_cam;

% Inicializa uma estrutura que guarda a informa��o das imagens
Im_Store = struct();
for k = 1:length(file_names)
	Im_Store(k).name = file_names(k).depth; 
end

% N�mero de imagens usado para construir o Background
n_imagens = floor(length(Im_Store)/3);

% Inicializa��o de vari�veis
ims = zeros(480, 640, n_imagens);
median_vec = zeros(480, 640, 2);

% Guarda os x e y min�mos e m�ximos de cada imagem, para garantir que a voxeliza��o utiliza os pontos ideais
for i =1:n_imagens

    str = Im_Store(i*3).name;
    load(str);
    ims(:, :, i) = depth_array;

	% Obt�m as coordenadas x,y,z dos pontos das imagens
    xyz = get_xyzasus(depth_array(:), [480 640], find(depth_array(307200)>0), Depth_cam.K, 1, 0);
    
    if x_max < max(xyz(:, 1))
        
        x_max = max(xyz(:, 1));
        
    end
    
    if y_max < max(xyz(:, 2))
        
        y_max = max(xyz(:, 2));
        
    end
    
     if x_min > min(xyz(:, 1))
        
        x_min = min(xyz(:, 1));
        
    end
    
    if y_min > min(xyz(:, 2))
        
        y_min = min(xyz(:, 2));
        
    end
    
end

% Cria um Background que ainda n�o � o final, fazendo a mediana de todos os pixeis de todas as imagens
imbg = median(ims, 3);

% Guarda o Background tempor�rio
median_vec(:, :, 1) = imbg;

% Guarda a �ltima imagem
str = Im_Store(length(Im_Store)).name;
load(str);
median_vec(:, :, 2) = depth_array;

% Faz o Background final, que vai ser a mediana do Background tempor�rio com a �ltima imagem
imbg = median(median_vec, 3);

%% ------------------------------------------------- Descobrir o plano do ch�o ------------------------------------------------------ %%

%% --------- Voxeliza��o ---------------- %%

% Dimens�es em x e y que cada pixel representa
Distance_x = x_max - x_min;
Delta_x = Distance_x / 800;

Distance_y = y_max - y_min;
Delta_y = Distance_y / 800;

% Servir� para garantir que nenhum pixel fica no eixo da origem
Compensa_x = abs(x_min);
Compensa_y = abs(y_min);


% Seleciona pontos aleatoriamente
i = 1:1:307200;

indice_random = randperm(length(i));
indice_random = indice_random(1:(307200/2));

Melhor_Plano = 0;
% Retorna as coordenadas x, y e z de cada ponto do plano
xyz = get_xyzasus(imbg(:), [480 640], find(imbg(307200)>0), Depth_cam.K, 1, 0);

% Escolhe 3 pontos do ch�o aleatoriamente
for j = 1:500
    
    indice_p1 = indice_random(3*j - 2);
    indice_p2 = indice_random(3*j - 1);
    indice_p3 = indice_random(3*j);
    
    xyz1 = xyz(indice_p1, :);
    xyz2 = xyz(indice_p2, :);
    xyz3 = xyz(indice_p3, :);
    
    % Cria matriz com as coordenadas reais dos pontos escolhidos + 1
    x = [xyz1; xyz2; xyz3];
    p = [x ones(3, 1)];

    % Decompoe em tres matrizes, v(:, 4) � a equacao do plano
    [u, s, v] = svd(p);
    pl = v(:, 4);

    vector_1 = ones(307200, 1); 
    
    % V� erros em relacao ao plano, pouco erro � ch�o!
    erros = [xyz vector_1]*pl;
    erros = sqrt(erros.*erros);

    % Guarda indices (formato vectorial) dos pontos do ch�o
    inds = find((erros < .05) & depth_array(:)>0);

    if length(inds) > length(Melhor_Plano)
        
        Melhor_Plano = inds;
        
    end
    
end

% "Pinta" ch�o
Depth_array_chao = imbg;
Depth_array_chao(Melhor_Plano) = 9593;

% Transla��o do plano do ch�o
Centro_Plano = mean(xyz(Melhor_Plano, :));
Translacao_Plano = xyz(Melhor_Plano,:) - ones(length(Melhor_Plano),1)*Centro_Plano;

% Rota��o do plano do ch�o
[a, b, c] = svd(Translacao_Plano','econ');
Rotacao_Plano = a';

% Tendo j� garantido que o ch�o � o plano na origem, aplicam-se as
% transforma��es aos restantes pontos xyz
xyz_Translacao = xyz-ones(length(xyz),1)*Centro_Plano;
xyz_Rotacao = Rotacao_Plano*xyz_Translacao';

% Corrige a point cloud
xyz_corrigido = xyz_Rotacao';
xyz_corrigido(:, 2) = -xyz_corrigido(:, 2);
xyz_final = -xyz_corrigido;


%% ----------------------------------------- Detecta objetos em movimento -------------------------------- %%

% Inicializa��o
tracked_objs_inicial = {};
new_object = 0;

% Calcula Centroids inicial
[Centroids_Anterior, n_pontos] = Fore(Im_Store, 1, imbg, Depth_cam, Centro_Plano, Rotacao_Plano, Compensa_x, Compensa_y, Delta_x, Delta_y);

% Caso exista algum objecto na primeira imagem, 
if ~isequal(Centroids_Anterior, [0 0]) 

	% Percorre os v�rios objetos iniciais que existam
    for i = 1:size(Centroids_Anterior, 1)
    
    	new_object = i;
       	% tracked_objs_inicial � um cell array onde cada entrada corresponde a um objeto. 
		% Cada objeto estar� representado por uma matriz onde cada linha representa um instante, que � dado pelo n�mero da fotografia em que aconteceu.
		% Cada linha tem 6 colunas. As duas primeiras s�o as coordenadas do seu centr�ide (x, y, z), sendo que x e y est�o guardados na vari�vel 
		% Centroids_Anterior, a terceira � z e tem sempre o valor 0, a 4� coluna � a imagem em causa, a 5� � a dist�ncia que vai sendo acumulada ao 
		% longo do trajeto desse objeto, e a 6� � o n�mero de pontos que esse objeto tem nessa fotografia (n_pontos).
		Trajectory_Data = [Centroids_Anterior(i, :) 0 1 0 n_pontos(i)];
        tracked_objs_inicial{new_object} = Trajectory_Data;
        
    end
    
%     plot(Centroids_Anterior(:, 1), Centroids_Anterior(:, 2));
%     pause(0.2)
%     
end

% Ciclo principal, que percorre todas as imagens e cria o ficheiro de sa�da
for i = 2:length(Im_Store)
    
	% Calcula as coordenadas dos centroides para a imagem i, assim como o n�mero de pontos que cada objeto dessa imagem tem
    [Centroids_Actual, n_pontos] = Fore(Im_Store, i, imbg, Depth_cam, Centro_Plano, Rotacao_Plano, Compensa_x, Compensa_y, Delta_x, Delta_y);
    
    % Quando algum objeto aparece pela primeira vez nesse dataset
    if (isequal(Centroids_Anterior, [0 0])) && ~(isequal(Centroids_Actual,[0 0]))
        
		% Faz o for para percorrer todos os objetos caso tenha mais do que um ao mesmo tempor�rio
		for j = 1:size(Centroids_Actual, 1)
			
			% Incrementa o n�mero de objetos existentes
			new_object = new_object + 1;
			% Atualiza o cell array das coordenadas de todos os objectos que tenham surgido, para a imagem i 
			% Quando n�o existem coordenadas anteriores desse centroide, a dist�ncia tem sempre o valor zero
			Trajectory_Data = [Centroids_Actual(j, :) 0 i 0 n_pontos(j)];
			tracked_objs_inicial{new_object} = Trajectory_Data;
        
        end
        
    end
    
    % Se entrar aqui, significa j� existia uma regi�o. Nesse caso j� � preciso calcular 
	% todos os par�metros importantes, e aplicar o h�ngaro
    if ~((isequal(Centroids_Anterior, [0 0])) || (isequal(Centroids_Actual,[0 0])))
        
		% MatchPeople � a fun��o que aplica o h�ngaro. Esta fun��o retorna o vector ass,
		% que diz respeito aos assignments, ou seja � correspond�ncia entre os centroides de uma imagem 
		% com os da anterior. Retorna tamb�m o custo dessa associa��o, e a matriz das dist�ncias percorridas
		% por cada centroide de uma imagem para a outra
        [ass, cost, dists] = MatchPeople(Centroids_Anterior, Centroids_Actual);
                        
        % O algoritmo tem que considerar as situa��es de aparecimento, desaparecimento, e update da posi��o
		% de objetos j� existentes entre cada par de imagens
		
		% Entra aqui se houver aparecimento de um objeto na imagem i que n�o havia na imagem anterior, i-1.
		% Compara-se o tamanho do vetor ass com o n� de linhas da matriz dists, pois caso haja um aparecimento
		% para essa imagem ass ainda s� tem o n� de objetos anteriores, e dists j� tem o atualizado.
		if numel(ass) < size(dists, 2)
                
           % Vetor de indices de regi�es ainda n�o agrupadas com anteriores
           objetos_novos = 1:1:size(dists,2);
                     
           % Update das coordenadas dos objetos 
           tracked_objs_inicial = Update_Normal(i, ass, tracked_objs_inicial, Centroids_Anterior, Centroids_Actual, n_pontos);
           
		   % Atualiza o vetor objetos_novos com as entradas no ass, eliminando as que estejam j� associadas a outras da imagem anterior
           for m = 1:numel(ass)
               
                indice_ass = find(objetos_novos == ass(m));
                objetos_novos(indice_ass) = [];
               
           end
           
           %Cria objecto novo
           for j = 1:size(objetos_novos,2)      
    
				% Atualiza o n�mero de objetos do dataset
               new_object = new_object + 1;
			   % Cria uma nova matriz no tracked_objs_inicial correnpondente ao novo objeto encontrado,
				% escreve as coordenadas do seu centroide, e coloca a dist�ncia ao anterior (que n�o existe) a zero
               Trajectory_Data = [Centroids_Actual(objetos_novos(j), :) 0 i 0 n_pontos(objetos_novos(j))];
               tracked_objs_inicial{new_object} = Trajectory_Data;

           end            
           
        % Se n�o houve cria��o, � preciso saber que objetos se mantiveram na imagem e atualizar as suas coordenadas,
		% e perceber se algum desapareceu.
        else
                    
			
            tracked_objs_inicial = Update_Normal(i, ass, tracked_objs_inicial, Centroids_Anterior, Centroids_Actual, n_pontos);
            
			% Se houve uma "morte" de um objeto, o ass fica com uma das entradas a zero mas ainda tem o tamanho da itera��o anterior. 
			% Aqui vai corrigir-se o problema de duas regi�es se juntarem numa s�
            if numel(ass) > size(dists, 2)
               
			   % N�o houve nenhumas regi�es que se tenham juntado
               Regiao_Junta = 0;
			
				% Percorre para todos os objetos
               for k = 1:size(tracked_objs_inicial, 2)
					
					% A �ltima coordenada � a linha do objeto k correspondente �s coordenadas dele na imagem i, e a pen�ltima s�o as coordenadas na imagem i-1
                   ultima_coordenada = size(tracked_objs_inicial{k}, 1);
                   penultima_coordenada = ultima_coordenada - 1;
                   
				   % Caso o objeto ainda n�o tivesse uma posi��o na imagem anterior, n�o se faz nada
                   if penultima_coordenada == 0;
                       
                       continue
                       
                   end
                   % Se o n�mero de pontos de algum objeto na imagem atual tiver aumentado consideravelmente o seu tamanho relativamente ao seu n�mero de pontos
				   % na imagem anterior, considera-se que provavelmente houve uma jun��o de duas regi�es. Note-se que s� se chega a esta hip�tese quando se sabe que um dos objetos desapareceu
                   if tracked_objs_inicial{k}(ultima_coordenada, 6) > 1.8*tracked_objs_inicial{k}(penultima_coordenada, 6)
                       
					   % Identifica qual o objeto, k, que fica duplicou o n�mero de pontos
                       Regiao_Junta = k;
                   
                   end
                                         
               end
				
				% Se alguma regi�o tiver duplicado o n�mero de pontos, � preciso corrigir esta situa��o com a fun��o Corrige_Juncoes
               if Regiao_Junta ~= 0 
                   
                   [tracked_objs_inicial, Centroids_Actual] = Corrige_Juncoes(i, tracked_objs_inicial, Centroids_Actual, Centroids_Anterior, Regiao_Junta);
                   
               end
               
            end
            
        end
        
    end
    
	% Antes de passar para a pr�xima imagem, os centroides anteriores passam a ser os atuais, e ao voltar ao in�cio do ciclo s�o calculados os novos
    Centroids_Anterior = Centroids_Actual;
    
%     plot(Centroids_Actual(:, 1), Centroids_Actual(:, 2), 'ro');
%     pause(0.02);
    
end

% No fim de todo o algoritmo, eliminam-se todas as matrizes do cell array (todos os objetos) que n�o se tenham praticamente deslocado ao longo de todas as imagens
tracked_objs_inicial = Limpa_Lixo(tracked_objs_inicial);


tracked_objs = {};
j = 1;

% O tracked_objs_inicial apresenta as coordenadas dos centroides dos objetos segundo as unidades da voxeliza��o.
% Para apresentar as coordenadas na forma pretendida, � agora calculado uma nova matriz tracked_objs a partir da anterior, mas nas unidades verdadeiras da imagem original
for i = 1:length(tracked_objs_inicial)
    
    if numel(tracked_objs_inicial{i}) ~= 0
        
       tracked_objs{j} = tracked_objs_inicial{i}; 
       tracked_objs{j} = tracked_objs{j}(:, 1:4);
       tracked_objs{j}(:, 1) = tracked_objs{j}(:, 1).*Delta_x;
       tracked_objs{j}(:, 2) = tracked_objs{j}(:, 2).*Delta_y;
       
       j = j + 1;
       
    end
    
end

end 

