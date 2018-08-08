clear;
Data = readtable("ExcelData.xlsx");

Data = Data(:,1:12);

%shuffling the data
Data = shuffledata(Data);

%Extracting equal number of normal and epieptic patients
Data = extractequal(Data);

%Dividing Data into Train(70%) and Test(30%)
[Train, Test] = divideTrainTest(Data, 70);

n_rounds = 3;
%Training the ensemble model
[Model,error] = AdaBoostModel(Train, n_rounds);

%Testing the model
%Prediction = predictAdaBoost(Test, n_rounds, Model, error);

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

function [Model,error] = AdaBoostModel(data,k)
	%Training the model, in k rounds
	[sz,sz2] = size(data);
	wt = 1/sz;
	weight = repelem(wt,sz);
	for i = 1:k
		error{i} = 0;
		predicted = cell2table(cell(sz,0));
		while error{i}>0.5
			TrainSample = datasample(data, sz, 'Replace', true, 'Weights', weight);
			TrainSampleX = TrainSample(:,1:11);
			TrainSampleY = TrainSample(:,12);
			Model{i} = fitctree(TrainSampleX, TrainSampleY);
			error{i} = 0;
			predicted = predict(Model{i}, TrainSampleX);
			for j = 1:sz
				if predicted{j,1}~=categorical(TrainSampleY{j,1})
					error{i} = error{i} + weight(j);
				end
			end
		end
		sum{i} = 0;
		for j = 1:sz
			if predicted{j,1}==categorical(TrainSampleY{j,1})
				weight(j) = weight(j)*(error{i}/(1-error{i}));
			end
			sum{i} = sum{i} + weight(j);
		end
		%normalizing
		for j = 1:sz
			weight(j) = weight(j)/(sum{i}*100.0);
		end
		%weight = normalize(weight,'range') %normalizing weights such that they are all between 0 and 1
	end
end
%if categorical(predicted{j,1})~=categorical(TrainSampleY{j,1})

function Prediction = predictAdaBoost(data, k, Model, error)
	[sz,sz2] = size(data);
	X = data(:,1:11);
	Y = data(:,12);
	for i = 1:k
		w{i} = log((1-error{i})/error{i});
		pred{i} = predict(Model{i}, X);
	end
	for i = 1:sz
		cats = categries(categorical(data{:,12}));
		values = [0 0];
		M = containers.Map(cats, values);
		for j = 1:k
			M(pred{j}(i,1)) = M(pred{j}(i,1)) + w{j};
		end
		[n_cat,n_cat2] = size(cats);
		maxm = 0;
		for j = 1:n_cat
			if M(cats(i))>=maxm
				maxm = M(cats(i));
				ind = i;
			end
		end
		Prediction{i} = cats(ind);
	end
end