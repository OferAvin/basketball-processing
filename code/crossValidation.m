function Results = crossValidation(k,featMat,lables)
    
    nTrials = size(featMat,1);
    idxSegments = mod(randperm(nTrials),k)+1;   %randomly split trails in to k groups
    nclass = length(unique(lables));
    cmT = zeros(nclass,nclass);                 % allocate space for confusion matrix
    results = cell(k,1);
    trainErr = cell(k,1);
    acc = zeros(k,1);
    
    for i = 1:k
    % each test on 1 group and train on the else
        validSet = logical(idxSegments == i)';
        trainSet = logical(idxSegments ~= i)';
        [results{i},trainErr{i}] =...
            classify(featMat(validSet,:),featMat(trainSet,:),lables(trainSet),'linear');
        acc(i) = sum(results{i} == lables(validSet));  %sum num of correct results
        acc(i) = acc(i)/length(results{i})*100;             
        %build the confusion matrix
        cm = confusionmat(lables(validSet),results{i});
       cmT =cmT + cm;
    end
    %calculate accuracy and f1
    percision = cmT(1,1)/(cmT(1,1) + cmT(1,2));
    recall = cmT(1,1)/(cmT(1,1) + cmT(2,1));
    f1 = 2*((percision*recall)/(percision+recall));
   
    accAvg = mean(acc);
    accSD = std(acc);
        
    trainAcc = (1-cell2mat(trainErr))*100;
    trAccAvg = mean(trainAcc);
    trAccSD = std(trainAcc);
    
    Results = struct('nFolds',k,'acc',accAvg,'SD',accSD,'trainAcc',trAccAvg,'trainSD',trAccSD,...
        'f1',f1,'percision',percision,'recall',recall,'conf_mat',cmT);
end
