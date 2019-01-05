%% ***************************************************************************************************************************************
%
% 																Limpa_Lixo
%															
%	Elimina as regioes que n�o t�m o comportamento esperado que uma pessoa tenha
%
%% ***************************************************************************************************************************************
%    Francisco Oliveira n� 75167				In�s Louren�o n� 75637				Nuno Lages n� 82162
%% ***************************************************************************************************************************************

function tracked_objs = Limpa_Lixo(tracked_objs)


% Depois de ter feito o algoritmo principal, elimina as regi�es/objetos que tenham tido um deslocamento menor que 50
for i = 1:size(tracked_objs, 2)
    
	% Na 5� coluna da �ltima coordenada de cada objeto est� representada a dist�ncia total percorrida por esse objeto, por isso basta ver o seu valor
    ultima_coordenada = size(tracked_objs{i}, 1);
    
    if tracked_objs{i}(ultima_coordenada, 5) < 50
        
        tracked_objs{i} = [];
        
    end
    
end