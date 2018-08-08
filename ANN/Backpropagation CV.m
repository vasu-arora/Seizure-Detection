
n_folds = 4;


for i = 1:n_folds
	not_fold_size = n_rem_normal-fold_size;
	fold_rows = [repelem(true, fold_size), repelem(false, not_fold_size)];
	per = randperm(n_rem_normal);
	fold_rows = fold_rows(per);
	fold_n{i} = rem_normal(fold_rows,:);
	rem_normal = rem_normal(~fold_rows,:);
	sz_rem_normal = size(rem_normal);
	n_rem_normal = sz_rem_normal(1);
end
