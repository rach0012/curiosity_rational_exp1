function in = check_badSubject(trivia_response)

in = 0;

if(sum(trivia_response(:,3)) < 1) %if only less than 1 answers are revealed
    in = 4;    
elseif(sum(trivia_response(:,3)) > 39) %if greater 39 answers are revealed
    in = 5;    
end

end