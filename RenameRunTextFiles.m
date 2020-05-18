clear;

%% load table from run 
base_path='/Users/abslab/Documents/GitHub/uo1_physio_segment_files/';
subject ='FSMAP_009_A';
subject_dir_path = [base_path subject '/block2/unamed'];
subject_dir_struct = dir(subject_dir_path);

csv_name = [subject '_block_2_run_start_end_times.csv'];
path_to_csv = [subject_dir_path '/' csv_name];
master_table = readtable(path_to_csv);

master_table_dim = size(master_table);
master_table_n_rows = master_table_dim(1);



for row_idx=1:master_table_n_rows
    row = master_table(row_idx,:);
    run_name = row.comments;
    if ~strcmp(run_name, '')
        disp(run_name)
        disp(row_idx)
        
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
