clear;
clc;
Data = readtable("mynewdatafourfeatures.xlsx");

Data = Data(:,1:12);

%shuffling the data
Data = shuffledata(Data);

%Extracting equal number of normal and epieptic patients
Data = extractequal(Data);

%Dividing Data into Train(70%) and Test(30%)
[Train, Test] = divideTrainTest(Data, 70);

TrainX = Train(:,1:11);
TrainY = Train(:,12);

sz_total = size(TrainY);
n_total = sz_total(1);

for i = 1:n_total
	if categorical(TrainY{i,:}) == 'N'
		Train_Y{i,1} = 1;
	end
	if categorical(TrainY{i,:}) == 'I'
		Train_Y{i,1} = 0;
	end
end

%{
Nboost = 100;

sum_t = 0;
for i = 1:n_total
    sum_t = sum_t+Train_Y{i};
end
    
mu = sum_t/n_total;	
for i = 1:n_total
    dY(i,1) = Train_Y{i} - mu;	
end

for k=1:Nboost
	Learner{k} = fitrtree(TrainX,dY);
	alpha{k} = 1; 
    predicted = predict(Learner{k}, TrainX);
    for i = 1:n_total
        dY(i,1) = dY(i,1) - alpha{k} * predicted(i);
    end
	%dY = dY - alpha{k} * predict(Learner{k}, TrainX);
end

TestX = Test(:,1:11);
TestY = Test(:,12);

[Ntest,D] = size(TestX);
predict_pr = zeros(Ntest,1);

for k=1:Nboost,
    predicted = predict(Learner{k}, TestX);
	for i = 1:Ntest
        predict_pr(i,1) = predict_pr(i,1) + alpha{k} * predicted(i);
    end
    %predict = predict + alpha{k}*predict(Learner{k}, TestX);
end;

for i = 1:Ntest
    if predict_pr(i,1)>=0
        Prediction(i,1) = 'N';
    end
    if predict_pr(i,1)<0
        Prediction(i,1) = 'I';
    end
end

Y = TestY;

Y = Test(:,12);

tp = 0;
fp = 0;
tn = 0;
fn = 0;
for i = 1:106
    if char(Prediction(i,1)) == char(Y{i,1})
        if(char(Prediction(i,1)) == 'N')
            tp = tp+1;
        end
        if(char(Prediction(i,1)) == 'I')
            tn = tn+1;
        end
    end
    if char(Prediction(i,1)) ~= char(Y{i,1})
        if(char(Prediction(i,1)) == 'N')
            fn = fn+1;
        end
        if(char(Prediction(i,1)) == 'I')
            fp = fp+1;
        end
    end
end

[sensitivity, specificity, recall, precision, fdr, accuracy] = params(tp, fp, fn, tn);

fprintf("sensitivity = %d\n", sensitivity);
fprintf("specificity = %d\n", specificity);
fprintf("recall = %d\n", recall);
fprintf("precision = %d\n", precision);
fprintf("fdr = %d\n", fdr);
fprintf("accuracy = %d\n", accuracy);
}%


%sensitivity = 1
%specificity = 9.464286e-01
%recall = 1
%precision = 9.433962e-01
%fdr = 5.660377e-02
%accuracy = 9.716981e-01


function EqualData = extractequal(data)
	%Extracting equal number of normal and epieptic patients
	normal = data(categorical(data{:,12})== 'N',:);
	epileptic = data(categorical(data{:,12})== 'I',:);

	sz_normal = size(normal);
	n_normal = sz_normal(1);
	sz_epileptic = size(epileptic);
	n_epileptic = sz_epileptic(1);

	%shuffling the data
	n_rows = randperm(n_normal);
	normal = normal(n_rows,:);

	e_rows = randperm(n_epileptic);
	epileptic = epileptic(e_rows,:);

	%extracting data of just 176 patients
	normal = normal(1:176,:);
	sz_normal = size(normal);
	n_normal = sz_normal(1);

	EqualData = [normal;epileptic];
	EqualData = shuffledata(EqualData);
end

function ShuffledData = shuffledata(data)
	%shuffling the data
	[sz, sz2] = size(data);
	rows = randperm(sz);
	ShuffledData = data(rows,:);
end

function [Train, Test] = divideTrainTest(data, per)
	%Divides data into Train(per%) and Test((100-per)%)
	%Keeps equal number of normal and epileptic patients in both Train and Test
	normal = data(categorical(data{:,12})== 'N',:);
	epileptic = data(categorical(data{:,12})== 'I',:);
	sz_normal = size(normal);
	n_normal = sz_normal(1);
	sz_epileptic = size(epileptic);
	n_epileptic = sz_epileptic(1);
	n_normal_training = (per/100)*n_normal;
	n_normal_training = int16(n_normal_training);
	n_normal_testing = n_normal - n_normal_training;
	train_n_rows = [repelem(true, n_normal_training), repelem(false, n_normal_testing)];
	permutation = randperm(n_normal);
	train_n_rows = train_n_rows(permutation);
	n_train = normal(train_n_rows,:);
	n_test = normal(~train_n_rows,:);
	n_epileptic_training = (per/100)*n_epileptic;
	n_epileptic_training = int16(n_epileptic_training);
	n_epileptic_testing = n_epileptic - n_epileptic_training;
	train_e_rows = [repelem(true, n_epileptic_training), repelem(false, n_epileptic_testing)];
	permutation = randperm(n_epileptic);
	train_e_rows = train_e_rows(permutation);
	e_train = epileptic(train_e_rows,:);
	e_test = epileptic(~train_e_rows,:);
	Train = [n_train; e_train];
	Test = [n_test; e_test];
	Train = shuffledata(Train);
	Test = shuffledata(Test);
end

function [sensitivity, specificity, recall, precision, fdr, accuracy] = params(tp, fp, fn, tn)
	sensitivity = tp/(tp+fn)
	recall = sensitivity
	specificity = tn/(fp+tn)
	precision = tp/(tp+fp)
	fdr = fp/(fp+tp)
	accuracy = (tp+tn)/(tp+tn+fp+fn)
end
