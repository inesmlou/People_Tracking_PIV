%% ***************************************************************************************************************************************
%
% 																Limpa_Lixo
%															
%	Elimina as regioes que não têm o comportamento esperado que uma pessoa tenha
%
%% ***************************************************************************************************************************************
%    Francisco Oliveira nº 75167				Inês Lourenço nº 75637				Nuno Lages nº 82162
%% ***************************************************************************************************************************************

function tracked_objs = Limpa_Lixo(tracked_objs)


% Depois de ter feito o algoritmo principal, elimina as regiões/objetos que tenham tido um deslocamento menor que 50
for i = 1:size(tracked_objs, 2)
    
	% Na 5ª coluna da última coordenada de cada objeto está representada a distância total percorrida por esse objeto, por isso basta ver o seu valor
    ultima_coordenada = size(tracked_objs{i}, 1);
    
    if tracked_objs{i}(ultima_coordenada, 5) < 50
        
        tracked_objs{i} = [];
        
    end
    
end