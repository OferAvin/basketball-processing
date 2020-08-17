function sigMat = calcSigMat(tf,labels,classes,pVal)
%this function gets a tf matrix and calculate significance between two
%conditions 
    good = tf(:,:,labels==classes(1));
    bad = tf(:,:,labels==classes(2));

    sigMat = zeros(size(tf,1),size(tf,2));
    for i=1:size(tf,1)
        for j=1:size(tf,2)
       [~,sigMat(i,j)]= ttest2(bad(i,j,:),good(i,j,:));    
        end
    end
    sigMat(sigMat > pVal) = NaN;
    sigMat= 1-sigMat;
end