clear;

%% load table from run 
base_path='';
subject ='FSMAP_069_A';
subject_block_dir_path = [base_path subject '/block2/']; 
subject_unamed_dir_path=[subject_block_dir_path 'unamed'];

csv_name = [subject '_block_2_run_start_end_times.csv'];
path_to_csv = [subject_unamed_dir_path '/' csv_name];
master_table = readtable(path_to_csv);

master_table_dim = size(master_table);
master_table_n_rows = master_table_dim(1);
%% make name dir
name_dir_path =[subject_block_dir_path '/named'];
mkdir(name_dir_path);


%% loop and rename files
for row_idx=1:master_table_n_rows
    row = master_table(row_idx,:);
    run_name = row.comments;
    if ~strcmp(run_name, '')
        disp(run_name)
        disp(row_idx)
        subj_run_txt = strcat(subject_unamed_dir_path, '/*run_', int2str(row_idx), '.txt');
        run_files = dir(subj_run_txt);
        for run_file_idx=1:length(run_files)
            run_file =run_files(run_file_idx);
            split_name =split(run_file.name,'_run');
            new_name = strcat(split_name{1},'_',run_name,'.txt');
            new_path = strcat(name_dir_path,'/',new_name);
            old_path =strcat(subject_unamed_dir_path, '/',run_file.name);
            copyfile(old_path, new_path{1});
            %copy and rename
        end
        
        % signal_match_arr = ismember(titles_str_arr,signal);
        % rename what does this mean
        % find all files in this folder with run_row_idx.txt
        %can you contains command hopefully
        % should give an array of indexes for the files
        %then for each of the names create a new name for it with run_1
        %swapped for run_name
        % then use copy file with previous path and new path with new name
        % to rename file
        % in the last path 
    end
end
