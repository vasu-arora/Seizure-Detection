%Applying Gradient Boosting on data of 11 epileptic and 11 normal patients

tic;
normal = mynewdatafourfeatures(1:352,1:12);
epileptic = mynewdatafourfeatures(353:528,1:12);

sz_normal = size(normal);
n_normal = sz_normal(1);
sz_epileptic = size(epileptic);
n_epileptic = sz_epileptic(1);

%shuffling the data
n_rows = randperm(n_normal);
normal = normal(n_rows,:);

e_rows = randperm(n_epileptic);
epileptic = epileptic(e_rows,:);

normal = normal(1:176,:);
sz_normal = size(normal);
n_normal = sz_normal(1);

%generating training data
n_normal_training = (70/100)*n_normal;
n_normal_training = int16(n_normal_training);
n_normal_testing = n_normal - n_normal_training;

train_n_rows = [repelem(true, n_normal_training), repelem(false, n_normal_testing)];
per = randperm(n_normal);
train_n_rows = train_n_rows(per);
n_trainX = normal(train_n_rows,1:11);
n_trainY = normal(train_n_rows,12);
n_testX = normal(~train_n_rows,1:11);
n_testY = normal(~train_n_rows,12);

n_epileptic_training = (70/100)*n_epileptic;
n_epileptic_training = int16(n_epileptic_training);
n_epileptic_testing = n_epileptic - n_epileptic_training;

train_e_rows = [repelem(true, n_epileptic_training), repelem(false, n_epileptic_testing)];
per = randperm(n_epileptic);
train_e_rows = train_e_rows(per);
e_trainX = epileptic(train_e_rows,1:11);
e_trainY = epileptic(train_e_rows,12);
e_testX = epileptic(~train_e_rows,1:11);
e_testY = epileptic(~train_e_rows,12);

XTrain = [n_trainX; e_trainX];
XTest = [n_testX; e_testX];
YTrain = [n_trainY; e_trainY];
YTest = [n_testY; e_testY];

sztrain = size(XTrain);
ntrain = sztrain(1);
sztest = size(XTest);
ntest = sztest(1);

%Boosting

Nboost = 100;

%Training
%Starting with mode
YT2 = table2array(YTrain);
mu = mode(YT2);
dY = YTrain - mu;
for i = 1:Nboost
	Learner{i} = fitctree(XTrain, dY);
	alpha{i} = 1;
	dY = dY-alpha{i}*predict(Learner{i},XTrain);
end;

%Testing on test data
predict = zeros(ntest, 1);
for i = 1:Nboost
	predict = predict+alpha{i}*predict(Learner{k}, XTest);
end;

C = confusionmat(YTest, predict);
[sensitivity, specificity, recall, precision, fdr, accuracy] = params(C{1,1}, C{1,2}, C{1,3}, C{1,4});
fprintf("sensitivity = %d\n", sensitivity);
fprintf("specificity = %d\n", specificity);
fprintf("recall = %d\n", recall);
fprintf("precision = %d\n", precision);
fprintf("fdr = %d\n", fdr);
fprintf("accuracy = %d\n", accuracy);
toc;