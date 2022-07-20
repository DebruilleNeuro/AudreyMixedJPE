%Function to merge eegsets (modified with files in output folder) 
function EEG = merge_eeg_sets(set1, set2, set3, set4, save_name)

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',set1,'filepath',[pwd '\output']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_loadset('filename',set2,'filepath',[pwd '\output']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_loadset('filename',set3,'filepath',[pwd '\output']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_loadset('filename',set4,'filepath',[pwd '\output']);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'retrieve',1,'study',0); 

channel_indices = 1:8;

EEG.data(end+1:end+8,:) = ALLEEG(2).data(channel_indices,:);
EEG.nbchan = size(EEG.data,1);
if ~isempty(EEG.chanlocs)
 	EEG.chanlocs(end+1).labels = 'Pz';
 	EEG.chanlocs(end+1).labels = 'P4';
 	EEG.chanlocs(end+1).labels = 'P3';
 	EEG.chanlocs(end+1).labels = 'P8';
    EEG.chanlocs(end+1).labels = 'P7';
 	EEG.chanlocs(end+1).labels = 'T8';
 	EEG.chanlocs(end+1).labels = 'T7';
 	EEG.chanlocs(end+1).labels = 'Po10';
end
EEG.saved = 'no';
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

EEG.data(end+1:end+8,:) = ALLEEG(3).data(channel_indices,:);
EEG.nbchan = size(EEG.data,1);
if ~isempty(EEG.chanlocs)
 	EEG.chanlocs(end+1).labels = 'F4';
 	EEG.chanlocs(end+1).labels = 'F3';
 	EEG.chanlocs(end+1).labels = 'Fc6';
 	EEG.chanlocs(end+1).labels = 'Fc5';
    EEG.chanlocs(end+1).labels = 'Fc2';
 	EEG.chanlocs(end+1).labels = 'Fc1';
 	EEG.chanlocs(end+1).labels = 'Fc1';
 	EEG.chanlocs(end+1).labels = 'C4';
end
EEG.saved = 'no';
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

EEG.data(end+1:end+8,:) = ALLEEG(4).data(channel_indices,:);
EEG.nbchan = size(EEG.data,1);
if ~isempty(EEG.chanlocs)
 	EEG.chanlocs(end+1).labels = 'C3';
 	EEG.chanlocs(end+1).labels = 'Tp10';
 	EEG.chanlocs(end+1).labels = 'Tp9';
 	EEG.chanlocs(end+1).labels = 'Cp6';
    EEG.chanlocs(end+1).labels = 'Cp5';
 	EEG.chanlocs(end+1).labels = 'O2';
 	EEG.chanlocs(end+1).labels = 'O1';
 	EEG.chanlocs(end+1).labels = 'Po9';
end
EEG.saved = 'no';
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

EEG = pop_saveset(EEG, save_name , [pwd '/output']);
%eeglab redraw

end