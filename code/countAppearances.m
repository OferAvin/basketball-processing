function [app,uniq] = countAppearances(vec)
    uniq = unique(vec);
    nUniq = length(uniq);
    app = zeros(nUniq,1);
    for i = 1:nUniq
        app(i) = sum(vec(:) == uniq(i));
    end
end