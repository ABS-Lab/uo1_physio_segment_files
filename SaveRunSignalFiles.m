clear all;
%% Must change manually for each subject
subject_number = 'FSMAP_056_A_2';
block ='block2/unamed';
sub_block_path = strcat(subject_number,'/',block);
subject_data = load(strcat(subject_number,'.mat'));

signal_arr = [{'cardiacraw'} {'respraw'} {'skinconductance'} {'cardfilt'} {'respfilt'}];
%% Code

mkdir(sub_block_path);

number_of_names = numel(fieldnames(subject_data));
%% currently code assumes that experiment data is in block 2 - this will not always be
% the case as sometimes you redo subject zero when subject has interruption
% for these participants there should 24 for number of names
if (number_of_names == 16)
    disp('two total blocks')
end

titles = subject_data.titles_block1;
titles_str_arr = cellstr(titles);%convert to string array

tick_times = subject_data.ticktimes_block1;%timing data
subj_physio_data = subject_data.data_block1;%data data
tick_times_comments = subject_data.comtick_block1;%comments
comments_text = subject_data.comtext_block1;%comments

mri_triggers = subj_physio_data(1,1:end);
raw_signals = {'respraw','skinconductance','cardiacraw'};
filt_signals = {'respfilt','cardfilt'};


%% if there are multiple subject zeros may need to change to block 3 etc.
trigger_ticks_idx = find(mri_triggers>3);%assumes triggers are taller than 3
plot(tick_times, mri_triggers)
%% get trigger times
trigger_times = tick_times(trigger_ticks_idx);% times of triggers
time_between_triggers = diff(trigger_times);%triggers are box cars this gives all times of trigger


first_t = trigger_times(1);%first triggers
last_t = trigger_times(end);%last triggers

scanner_triggers_idx = find(time_between_triggers > .08);%get triggers idx that are at least 80msec apart
scanner_trigger_times = trigger_times(scanner_triggers_idx);%select these time points

%% Get triggers for each run
diffed_runs = diff(scanner_trigger_times);%difference between trigger times
diffed_greater_then_10_idx = find(diffed_runs>10);% find difference greater then t assumes no tr < 10
run_end_times = scanner_trigger_times(diffed_greater_then_10_idx);%diff gives you the first index of gap between runs meaning the last trigger of the preceding run
t_plus_one_start_trigger_idx = diffed_greater_then_10_idx + 1;% add one to indexes of gapped ends - meaning start of next
t_plus_one_start_times = scanner_trigger_times(t_plus_one_start_trigger_idx);%get start times for those indexes

start_times = [first_t t_plus_one_start_times];
end_times = [run_end_times last_t];

start_end_column_arr = transpose([start_times; end_times]);

column_names = [{'start_time'},{'end_time'},{'duration'}];
start_end_column_arr(:,3) = start_end_column_arr(:,2)-start_end_column_arr(:,1);
len_runs = numel(start_end_column_arr)/3;

comments_stringified = cellstr(comments_text);
comments_length = length(comments_stringified);

subject_save_path =strcat(sub_block_path, '/', subject_number,'_block_2');
run_times_name = strcat(subject_save_path,'_run_start_end_times.csv');

if comments_length < len_runs
    comments_stringified(comments_length + 1: len_runs,1) = {' '}; 
else
    n_rows = comments_length-len_runs;
    start_end_column_arr(len_runs+1:comments_length,1:end) = zeros(n_rows,3); 
end
save_table = array2table(start_end_column_arr, 'VariableNames', column_names);
save_table.comments = comments_stringified;
writetable(save_table,run_times_name)

%% Create Graph for visual inspection of runs

hold on
plot(scanner_trigger_times,ones(numel(scanner_trigger_times),1)*4.5,'ys')
plot(end_times, ones(numel(end_times),1)*4, 'gs')
plot(start_times, ones(numel(start_times),1)*4.1, 'rs')
hold off

input('check plot ');

%% Save graph and run start times for references
fig_name = strcat(subject_save_path,'_triggers_plot.fig');
savefig(fig_name);

%% loop to get each run data and save
for i=1:numel(start_times)

%% Get run timing info
    start_time =start_times(i);
    end_time = end_times(i);
    disp(strcat('run ',num2str(i)));
    disp('start time: ') 
    disp(num2str(start_time));
    disp('end time ')
    disp(num2str(end_time));
    disp(' ');
     
    idx_run_ticks = find(tick_times >= start_time & tick_times<= end_time);
    run_physio_data = subj_physio_data(:,idx_run_ticks);
    times_run = tick_times(idx_run_ticks);
    
%% loop over signals for each run  
    for signal_idx=1:numel(signal_arr)
        
        %get signal name and find index for column in data array
        signal_cell = signal_arr(signal_idx);
        signal = signal_cell{:};
        signal_match_arr = ismember(titles_str_arr,signal);%find index of signal in titles
        idx_of_signal_indata = find(signal_match_arr == 1);
        
        signal_data = run_physio_data(idx_of_signal_indata,:);
        column_time_signal = transpose([times_run; signal_data]);
        plot(column_time_signal(:,1),column_time_signal(:,2));
        %input('check plot')
        
        %create name for save file and save
        run_string = num2str(i);
        run_file = sprintf('%s/%s_%s_run_%s.txt',sub_block_path,signal,subject_number, run_string);
        dlmwrite(run_file,column_time_signal ,'delimiter',',','precision',10);
        
    end

end



