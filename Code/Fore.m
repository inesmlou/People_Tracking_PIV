%% ***************************************************************************************************************************************
%
% 																Fore
%															
%	Trata da criação do foreground para todas as imagens, faz a voxelização, identifica as regiões e filtra as pessoas
%
%% ***************************************************************************************************************************************
%    Francisco Oliveira nº 75167				Inês Lourenço nº 75637				Nuno Lages nº 82162
%% ***************************************************************************************************************************************

function [centroids_dots, n_pontos] = Fore(Im_Store, index, imbg, Depth_cam, Centro_Plano, Rotacao_Plano, Compensa_x, Compensa_y, Delta_x, Delta_y)

%% ------------------------------------------------ Point Cloud do Foreground -------------------------------------------- %%

str = Im_Store(index).name;
load(str);

% Para todas as imagens, obtém o foreground através da subtração da imagem ao background
foreground = double(abs(double(depth_array) - imbg) > 350);

[row, col] = find(foreground > 0);

for i = 1:length(row)

    foreground(row(i), col(i)) = depth_array(row(i), col(i));

end

% Arranja as coordenadas x y e z de cada ponto da imagem de profundidade
xyz = get_xyzasus(foreground(:), [480 640], find(foreground(307200)>0), Depth_cam.K, 1, 0);

% Tendo já garantido que o chão é o plano na origem, aplicam-se as transformações aos restantes pontos xyz
xyz_Translacao = xyz-ones(length(xyz),1)*Centro_Plano;
xyz_Rotacao = Rotacao_Plano*xyz_Translacao';

% Corrige point cloud
xyz_corrigido = xyz_Rotacao';
xyz_corrigido(:, 2) = -xyz_corrigido(:, 2);
xyz_final = -xyz_corrigido;


% Aproveita apenas os pontos que tiverem entre as alturas de 1 e 2.1 metros
corte = find(xyz_final(:, 3) > 1 & xyz_final(:, 3) < 2.1); 

xyz_cortado = zeros(length(corte), 3);

for i = 1:length(corte)

    xyz_cortado(i, :) = xyz_final(corte(i), :); 

end


%% -------- Voxelização e Criação de regioes -------- %%

% Serve para garantir que a origem fica no sítio certo, evitando pontos com valores negativos
xyz_vox = xyz_cortado;

xyz_vox(:, 1) = xyz_vox(:, 1) + Compensa_x;

xyz_vox(:, 2) = xyz_vox(:, 2) + Compensa_y;


Regiao = zeros(800, 800);     
 

for i = 1:length(xyz_vox)

        x = xyz_vox(i, 1);
        y = xyz_vox(i, 2);
		
		% Identifica a distância real a que cada pixel corresponde
        pixel_x = ceil(x / Delta_x);
        pixel_y = ceil(y / Delta_y);

		% Verifica que todas as regioes pertencem a um dos pixeis, nao ficando fora da imagem
        if ((pixel_x > 0 && pixel_x <= 800) && (pixel_y > 0 && pixel_y <= 800))        

                Regiao(pixel_x, pixel_y) = Regiao(pixel_x, pixel_y) + 1;

        end

end


% Filtragem inicial de ruido, ignorando areas que sejam menores que 250
if bwarea(Regiao) < 250
    centroids_dots = [0 0];
    n_pontos = 0;
    return
    
end

% A função labeled_objects atribui diferentes identificacoes a cada uma das regioes
labeled_objects = bwlabel(bwareafilt(logical(Regiao), [250 bwarea(Regiao)]));
 
% Se uma regiao tiver area zero o programa continua
if bwarea(labeled_objects) == 0
    
    centroids_dots = [0 0];
    n_pontos = 0;
    
    return
end

% Inicializacoes
just_people = zeros(size(labeled_objects));

centroids_dots = [0 0];
n_pontos = [];

counter = 0;

% For que guarda no just_people regioes com um numero de pontos superior a 200
for i=1:length(labeled_objects)
    
    one_object = labeled_objects == i;
    n_pontos_temp = sum(sum(Regiao(one_object)));
    
	% Pessoa encontrada
	if n_pontos_temp > 200 
        Prop = regionprops(one_object, 'centroid');
        counter = counter + 1;
        n_pontos(counter) = n_pontos_temp;
        centroids_dots(counter,:) = Prop.Centroid;
        just_people = just_people + one_object;        
    end
    
end

% Permite vizualização das regiões (Se for necessário ver basta tirar de
% comentário)
% imshow(just_people);
hold on

if isempty(centroids_dots)
    
    n_pontos = 0;
    centroids_dots = [0 0];

end
