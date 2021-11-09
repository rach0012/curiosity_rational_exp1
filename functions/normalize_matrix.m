function matrix = normalize_matrix(matrix)
%function normalizes each column of the matrix columnwise (rescales
%confidence and normalizes curiosity)

%normalize curiosity
  meanValue = mean(matrix(:,1));
  stdValue = std(matrix(:,1));
% 
  matrix(:,1) =  (matrix(:,1) - meanValue)./stdValue;

% % rescale confidence to 0 - 1
%       maxValue = max(matrix(:,2));
%       minValue = min(matrix(:,2));
%       matrix(:,2) =  (matrix(:,2) - minValue)./(maxValue-minValue);

end