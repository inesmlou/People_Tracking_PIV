%% ***************************************************************************************************************************************
%
% 																MatchPeople
%															
%	Prepara a matriz que vai ser tratada pelo Hungarian
%
%% ***************************************************************************************************************************************
%%    Francisco Oliveira nº 75167				Inês Lourenço nº 75637				Nuno Lages nº 82162
%% ***************************************************************************************************************************************

function [ass, cost, dists] = MatchPeople(positions1, positions2)
   
    len1 = size(positions1, 1);
    len2 = size(positions2, 1);
    
    dists = zeros(len1, len2);
    
    for i=1:len1
        for j=1:len2
            
                % Calcula as distâncias euclideanas entre todos os objetos 
                dists(i,j) = sqrt(sum((positions1(i,:) - positions2(j,:)) .^ 2));
           
        end
    end
  
	% Faz o Hungarian. Retorna as associações feitas entre objetos e o custos dessas ligações, com base nas distâncias entre cada um
    [ass, cost] = munkres(dists);

	