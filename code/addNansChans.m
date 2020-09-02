function featCells= addNansChans (featCells)
for i= 1:size(featCells,2)
    if size(featCells{i},2) ~= 21
       featCells{i}=cat(2,featCells{i}, nan(size(featCells{i},1),21-size(featCells{i},2)));
    end
end

end