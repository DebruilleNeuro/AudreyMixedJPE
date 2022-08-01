%Version5
%%%%%Script to preprocess data for Visage experiments (JPE) 32 electrodes cap (-po10).

% !READ ME!
% Input: Raw eeg data *.EDF (eeg continuous) containing data for a paire of
% participants (H1&H2) recorded simultaneously (H1: first 32 channels of
% file; H2: last 32 channels). 
%
% Output: *.erp, (event related potentials) *.set files (Preprocessed, pruned
% with ICA, 0.1hz-50hz filtering, AR...), , *txt (Artifact Rejection
% summary) for H1 & H2
% 
%!! IMPORTANT READ BEFORE RUNNING !!!
% 
% 1) Run section per section (in Editor > Run and Advance not 'Run')
% 2) This script requires some manual input
%       a) Pop-up version of ICA (Check that correct channels are selected
%       i.e that *bad* channels are not included) for H1 and H2
%       b) Pop-up version of Automatic Channel Rejection: change measure
%       from Kurtosis to Probability. 
%       c) Channels that were rejected during the Automatic Rejection AFTER ICA
%          should be written down.
% 3) Artifact Rejection QUICK guide (Last section, after ICA)
%       a) Run Artifact Rejection once on all 28 electrodes. 
%       b) Run Artifact a second time removing channels with lots of artifacts
%          (See in Artifact rejection pop-up, channels that cause a lot of
%          trials to be rejected.) Should coincide with channels marked
%          *bad* by automatic channel rejection. 
%       c)Take note of bad channels. Double check which channels are bad by
%       plotting ERPs before recalculating bad channels.
% 4) In current folder create a folder named "output". Output files will
% be created there. 
% 5) Input .EDF filename format: 1:2 characters = pair number (01, 02...)
%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SECTION 1: from .EDF to filtered .set files for H1&H2 (paire of participants)
clear all
close all
clc

addpath(genpath('C:\Users\jeula\Documents\current subjects\eeglab2021.1'))

%open eeglab
eeglab

% search for .edf file in the current directory
searchFilter = '*.EDF';
currentDirectory = pwd;
asciiFileDirectory = fullfile( currentDirectory);
addpath( asciiFileDirectory );
searchString = [asciiFileDirectory, '/', searchFilter];
filesList = dir(searchString);

% Read .edf
for i=1:length(filesList)
    file_name(i)= fopen(filesList(i).name);% lire le fichier
end

i=1:length(file_name);

for j=1:8
    
    name_temp = filesList(i).name;
    
    %initializing variable
    events=[];
    %specify channels
    channels=((j-1)*9+1):j*9;
    
    %start processing data
    %open EDF file in eeglab
    EEGSET=pop_biosig(filesList(i).name, 'channels', channels);
    
    % choose the correct event list
    if name_temp(3) == 'D'
        events =[currentDirectory '/EVENTLISTMixed2021.txt'];
    elseif name_temp(3) == 'M'
        events =[currentDirectory '/EVENTLISTMixed2021.txt'];
    end
    
    % load event info
    EEGSET  = pop_editeventlist( EEGSET , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99}, 'BoundaryString', { 'boundary' }, 'List',...
        events, 'SendEL2', 'EEG', 'UpdateEEG', 'on', 'Warning', 'on' );
    
    % create epochs
    EEGSET = pop_epochbin( EEGSET , [-204.0  1200.0],  [ -204 -4]);
    
    %initializing variable
    placingelectrode=[];
    
    EEG=EEGSET;
    
    nameerp = [name_temp(1:2) 'b' int2str(j)];
    if (j==1 || j==5)
        placingelectrode = {'ch1 = ch1 label CP2', 'ch2 = ch2 label CP1', 'ch3 = ch3 label Fp2',  'ch4 = ch4 label Fp1',  'ch5 = ch5 label F8',  'ch6 = ch6 label F7', 'ch7 = ch7 label Fz',  'ch8 = ch8 label Cz'};
    elseif (j==2 || j==6)
        placingelectrode = {'ch1 = ch1 label Pz',  'ch2 = ch2 label P4',  'ch3 = ch3 label P3',  'ch4 = ch4 label P8', 'ch5 = ch5 label P7',  'ch6 = ch6 label T8',  'ch7 = ch7 label T7', 'ch8 = ch8 label Po10'};
    elseif (j==3 || j==7)
        placingelectrode = {'ch1 = ch1 label F4', 'ch2 = ch2 label F3',  'ch3 = ch3 label Fc6',  'ch4 = ch4 label Fc5',  'ch5 = ch5 label Fc2',  'ch6 = ch6 label Fc1',  'ch7 = ch7 label Fc1', 'ch8 = ch8 label C4'};
    elseif (j==4 || j==8)
        placingelectrode = {'ch1 = ch1 label C3', 'ch2 = ch2 label Tp10',  'ch3 = ch3 label Tp9',  'ch4 = ch4 label Cp6',  'ch5 = ch5 label Cp5', 'ch6 = ch6 label O2',  'ch7 = ch7 label O1', 'ch8 = ch8 label Po9'};
    end
    
    EEG = pop_eegchanoperator(EEG, placingelectrode);
    nameerp = [name_temp(1:2) '_' int2str(j)];
    EEG = pop_saveset( EEG, ['part_' nameerp '.'] , [pwd '/output']);
    
end

% merge datasets (function merge_eeg_sets)
name_temp = filesList(i).name;
nameH1 = ['1_' name_temp(1:2) 'H1.'];
nameH2 = ['1_' name_temp(1:2) 'H2.'];

merge_eeg_sets(['part_' name_temp(1:2) '_1.set'], ['part_' name_temp(1:2) '_2.set'], ['part_' name_temp(1:2) '_3.set'], ['part_' name_temp(1:2) '_4.set'], nameH1);
merge_eeg_sets(['part_' name_temp(1:2) '_5.set'], ['part_' name_temp(1:2) '_6.set'], ['part_' name_temp(1:2) '_7.set'], ['part_' name_temp(1:2) '_8.set'], nameH2);

%Create 2 filtered set files for each subject: one with 1hz filter to run
%ICA on and 0.1hz filter to apply ICA on.  

for h=1:2
    
    if h==1 % human 1 0,1hz 50hz filters
        nameset = ['0.1HZ_' name_temp(1:2) '_H1' '.'];
        nameerp = [name_temp(1:2) '_H1' '.erp'];
        EEG = pop_loadset('filename',['1_' name_temp(1:2) 'H1.set'],'filepath',[pwd '/output']);
        placingelectrode = {'nch1 = ch1 label CP2' 'nch2 = ch2 label CP1' 'nch3 = ch3 label Fp2','nch4 = ch4 label Fp1',  'nch5 = ch5 label F8',  'nch6 = ch6 label F7',...
            'nch7 = ch7 label Fz',  'nch8 = ch8 label Cz','nch9 = ch9 label Pz',  'nch10 = ch10 label P4',  'nch11 = ch11 label P3',  'nch12 = ch12 label P8',...
            'nch13 = ch13 label P7',  'nch14 = ch14 label T8',  'nch15 = ch15 label T7', 'nch16 = ch16 label Po10',  'nch17 = ch17 label F4',...
            'nch18 = ch18 label F3',  'nch19 = ch19 label Fc6',  'nch20 = ch20 label Fc5',  'nch21 = ch21 label Fc2',  'nch22 = ch22 label Fc1',  'nch23 = ch23 label C4',...
            'nch24 = ch24 label C3',  'nch25 = ch25 label Tp10',  'nch26 = ch26 label Tp9',  'nch27 = ch27 label Cp6',  'nch28 = ch28 label Cp5',...
            'nch29 = ch29 label O2',  'nch30 = ch30 label O1'}
        EEG = pop_eegchanoperator(EEG, placingelectrode);%placing electrodes
        EEG = pop_editset(EEG, 'run', [], 'chanlocs', [pwd '/Cap30electrodes.ced']);
        % filter data
        EEGSET = pop_eegfiltnew( EEGSET, 0.1, 50, [], false, [], 0); %0.1hz-50hz filter
        EEG = pop_saveset(EEG,[nameset],[pwd '/output']) %save
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
    elseif h==2 %human 2 0,1hz 50hz filters
        nameset = ['0.1HZ_' name_temp(1:2) '_H2' '.'];
        nameerp = [name_temp(1:2) '_H1' '.erp'];
        EEG = pop_loadset('filename',['1_' name_temp(1:2) 'H2.set'],'filepath',[pwd '/output']);
        placingelectrode = {'nch1 = ch1 label CP2' 'nch2 = ch2 label CP1' 'nch3 = ch3 label Fp2','nch4 = ch4 label Fp1',  'nch5 = ch5 label F8',  'nch6 = ch6 label F7',...
            'nch7 = ch7 label Fz',  'nch8 = ch8 label Cz','nch9 = ch9 label Pz',  'nch10 = ch10 label P4',  'nch11 = ch11 label P3',  'nch12 = ch12 label P8',...
            'nch13 = ch13 label P7',  'nch14 = ch14 label T8',  'nch15 = ch15 label T7', 'nch16 = ch16 label Po10',  'nch17 = ch17 label F4',...
            'nch18 = ch18 label F3',  'nch19 = ch19 label Fc6',  'nch20 = ch20 label Fc5',  'nch21 = ch21 label Fc2',  'nch22 = ch22 label Fc1',  'nch23 = ch23 label C4',...
            'nch24 = ch24 label C3',  'nch25 = ch25 label Tp10',  'nch26 = ch26 label Tp9',  'nch27 = ch27 label Cp6',  'nch28 = ch28 label Cp5',...
            'nch29 = ch29 label O2',  'nch30 = ch30 label O1'}
        EEG = pop_eegchanoperator(EEG, placingelectrode);%placing electrodes
        EEG = pop_editset(EEG, 'run', [], 'chanlocs', [pwd '/Cap30electrodes.ced']);
        % filter data
        EEGSET = pop_eegfiltnew( EEGSET, 0.1, 50, [], false, [], 0); %0.1hz-50hz filter
        EEG = pop_saveset(EEG,[nameset],[pwd '/output']) %save
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    end
    
    if h==1 % human 1 1hz 50hz filters
        nameset = ['1HZ_' name_temp(1:2) '_H1' '.'];
        nameerp = [name_temp(1:2) '_H1' '.erp'];
        EEG = pop_loadset('filename',['1_' name_temp(1:2) 'H1.set'],'filepath',[pwd '/output']);
        placingelectrode = {'nch1 = ch1 label CP2' 'nch2 = ch2 label CP1' 'nch3 = ch3 label Fp2','nch4 = ch4 label Fp1',  'nch5 = ch5 label F8',  'nch6 = ch6 label F7',...
            'nch7 = ch7 label Fz',  'nch8 = ch8 label Cz','nch9 = ch9 label Pz',  'nch10 = ch10 label P4',  'nch11 = ch11 label P3',  'nch12 = ch12 label P8',...
            'nch13 = ch13 label P7',  'nch14 = ch14 label T8',  'nch15 = ch15 label T7', 'nch16 = ch16 label Po10',  'nch17 = ch17 label F4',...
            'nch18 = ch18 label F3',  'nch19 = ch19 label Fc6',  'nch20 = ch20 label Fc5',  'nch21 = ch21 label Fc2',  'nch22 = ch22 label Fc1',  'nch23 = ch23 label C4',...
            'nch24 = ch24 label C3',  'nch25 = ch25 label Tp10',  'nch26 = ch26 label Tp9',  'nch27 = ch27 label Cp6',  'nch28 = ch28 label Cp5',...
            'nch29 = ch29 label O2',  'nch30 = ch30 label O1'}
        EEG = pop_eegchanoperator(EEG, placingelectrode);%placing electrodes
        EEG = pop_editset(EEG, 'run', [], 'chanlocs', [pwd '/Cap30electrodes.ced']);
        % filter data
        EEGSET = pop_eegfiltnew( EEGSET, 1, [], [], false, [], 0); %1hz filter
        EEG = pop_saveset(EEG,[nameset],[pwd '/output']) %save
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        
    elseif h==2 %human 2 1hz 50hz filters
        nameset = ['1HZ_' name_temp(1:2) '_H2' '.'];
        nameerp = [name_temp(1:2) '_H1' '.erp'];
        EEG = pop_loadset('filename',['1_' name_temp(1:2) 'H2.set'],'filepath',[pwd '/output']);
        placingelectrode = {'nch1 = ch1 label CP2' 'nch2 = ch2 label CP1' 'nch3 = ch3 label Fp2','nch4 = ch4 label Fp1',  'nch5 = ch5 label F8',  'nch6 = ch6 label F7',...
            'nch7 = ch7 label Fz',  'nch8 = ch8 label Cz','nch9 = ch9 label Pz',  'nch10 = ch10 label P4',  'nch11 = ch11 label P3',  'nch12 = ch12 label P8',...
            'nch13 = ch13 label P7',  'nch14 = ch14 label T8',  'nch15 = ch15 label T7', 'nch16 = ch16 label Po10',  'nch17 = ch17 label F4',...
            'nch18 = ch18 label F3',  'nch19 = ch19 label Fc6',  'nch20 = ch20 label Fc5',  'nch21 = ch21 label Fc2',  'nch22 = ch22 label Fc1',  'nch23 = ch23 label C4',...
            'nch24 = ch24 label C3',  'nch25 = ch25 label Tp10',  'nch26 = ch26 label Tp9',  'nch27 = ch27 label Cp6',  'nch28 = ch28 label Cp5',...
            'nch29 = ch29 label O2',  'nch30 = ch30 label O1'}
        EEG = pop_eegchanoperator(EEG, placingelectrode);%placing electrodes
        EEG = pop_editset(EEG, 'run', [], 'chanlocs', [pwd '/Cap30electrodes.ced']);
        % filter data
        EEGSET = pop_eegfiltnew( EEGSET, 1, [], [], false, [], 0); %1hz filter
        EEG = pop_saveset(EEG,[nameset],[pwd '/output']) %save
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    end
end

%% SECTION FOR PARTICIPANT H1 (ICA, Artifact rejection...)

j=1; %human 1

%initializing variables
nameerp = [];
nameset = [];
electrodes=[];

EEG = pop_loadset('filename',['1HZ_' name_temp(1:2) '_H' int2str(j) '.set'],'filepath',[pwd '/output']); %load 1hz dataset for ICA
nameerp = [name_temp(1:2) '_H' int2str(j) '.erp'];
nameset = [name_temp(1:2) '_H' int2str(j) '.set'];
EEG = pop_editset(EEG, 'run', [], 'chanlocs', [pwd '/Cap30electrodes.ced']);%load channel location info

% automatic channel rejection
EEG = pop_rejchan(EEG, 'elec',[1:30],'measure','prob','norm','on','threshold',5); %automatic rejection parameters
%  fprintf('If *bad* channels exist, remove them from brackets in pop_runica')

%% run ICA
%%!!! Remove *bad* electrodes in ICA Pop-up (or if ICA automated, remove from brackets to run e.g.[1:23 25:28] %24)
EEG = pop_runica( EEG ) 
%EEG = pop_runica(EEG, 'icatype', 'runica', 'chanind', [1:30], 'extended',1); %  change chanind to reject bad electrode if needed
EEG = pop_saveset( EEG, 'filename',['ICA_1HZ_' name_temp(1:2) '_H' int2str(j) '.set'],'filepath',[pwd '/output']); %save set

%ICA activation matrix
TMP.icawinv = EEG.icawinv;
TMP.icasphere = EEG.icasphere;
TMP.icaweights = EEG.icaweights;
TMP.icachansind = EEG.icachansind;

% apply matrix to 0.1hz dataset
clear EEG;
EEG = pop_loadset('filename', ['0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']); %load 0.1hz .set
EEG.icawinv = TMP.icawinv;
EEG.icasphere = TMP.icasphere;
EEG.icaweights = TMP.icaweights;
EEG.icachansind = TMP.icachansind;
clear TMP;
EEG = pop_saveset(EEG, 'filename',['ICA_0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']); %save 0.1hz+ICA matrix .set
%0.1hz set is the one kept for further processing
%% !!! when 'reject component' window pops up, before rejecting need to label components manually (precaution)
EEG = pop_loadset('filename', ['ICA_0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']);
%IC component rejection
EEG=iclabel(EEG);
noisethreshold = [0 0;0.9 1; 0.9 1; 0 0; 0 0; 0 0; 0 0]; %IC label parameters: 90% Muscle and Eye probability;
EEG = pop_icflag(EEG, noisethreshold);
% remove bad component(s)
EEG = pop_subcomp( EEG ); %manual check
% save
EEG = pop_saveset(EEG, 'filename',['ICs_ICA_0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']); %set 0.1hz filter + ICA + bad ICs removed

% check bad channels again
pop_rejchan(EEG)
%EEG = pop_rejchan(EEG, 'elec',[1:30],'measure','prob','norm','on','threshold',5); %automatic rejection parameters
fprintf('In next section: Remove *bad electrodes from brackets')
%% artifact detection

%%%!! exclude *bad* electrodes, comment which electrode(s) and restore
%%%after participant is done
frontals = [3:6];
electrodes=[1 2 7:30]; %!!take note of which electrode is removed

%peak to peak (frontal elec and other elec)
EEG  = pop_artextval( EEG , 'Channel', electrodes, 'Flag',  1, 'Threshold', [ -75 75], 'Twindow',[ -204 1200] );
EEG  = pop_artextval( EEG , 'Channel', frontals, 'Flag',  1, 'Threshold', [ -100 100], 'Twindow',[ -204 1200] );

%flat line (frontal elec and other elec)
EEG  = pop_artflatline( EEG , 'Channel', electrodes, 'Duration',  100, 'Flag',  1, 'Threshold', [ -1e-07 1e-07], 'Twindow', [ -204 1200] );
EEG  = pop_artflatline( EEG , 'Channel', frontals, 'Duration',  100, 'Flag',  1, 'Threshold', [ -1e-07 1e-07], 'Twindow', [ -204 1200] );

%close;
EEG = pop_saveset( EEG, [nameset] ,[pwd '/output']);

%% compute erp
ERP = pop_averager( EEG , 'Criterion', 'good', 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );

% load channel location information
ERP = pop_erpchanedit( ERP, [currentDirectory '/Cap30electrodes.ced']);

% Save the erp
ERP = pop_savemyerp(ERP, 'erpname', nameerp, 'filename', nameerp, 'filepath', [pwd], 'Warning', 'on');
ERP = pop_summary_AR_erp_detection(ERP, [currentDirectory '/output' '\' nameerp(1:end-4) '.txt'])


fprintf(':) Participant 1 done. Last files created are final output :)');

%% SECTION FOR PARTICIPANT H2 (ICA, Artifact rejection...)

j=2;

%initializing variables
nameerp = [];
nameset = [];
electrodes=[];

EEG = pop_loadset('filename',['1HZ_' name_temp(1:2) '_H' int2str(j) '.set'],'filepath',[pwd '/output']); %load 1hz dataset for ICA
nameerp = [name_temp(1:2) '_MH' int2str(j) '.erp'];
nameset = [name_temp(1:2) '_MH' int2str(j) '.set'];
EEG = pop_editset(EEG, 'run', [], 'chanlocs', [pwd '/Cap30electrodes.ced']);%load channel location info

% automatic channel rejection
EEG = pop_rejchan(EEG, 'elec',[1:30],'measure','prob','norm','on','threshold',5); %automatic rejection parameters
%  fprintf('If *bad* channels exist, remove them from brackets in pop_runica')

%% run ICA
%%!!! Remove *bad* electrodes in ICA Pop-up (or if ICA automated, remove from brackets to run e.g.[1:23 25:28] %24)
EEG = pop_runica( EEG ) 
%EEG = pop_runica(EEG, 'icatype', 'runica', 'chanind', [1:30], 'extended',1); %  change chanind to reject bad electrode if needed
EEG = pop_saveset( EEG, 'filename',['ICA_1HZ_' name_temp(1:2) '_H' int2str(j) '.set'],'filepath',[pwd '/output']); %save set

%ICA activation matrix
TMP.icawinv = EEG.icawinv;
TMP.icasphere = EEG.icasphere;
TMP.icaweights = EEG.icaweights;
TMP.icachansind = EEG.icachansind;

% apply matrix to 0.1hz dataset
clear EEG;
EEG = pop_loadset('filename', ['0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']); %load 0.1hz .set
EEG.icawinv = TMP.icawinv;
EEG.icasphere = TMP.icasphere;
EEG.icaweights = TMP.icaweights;
EEG.icachansind = TMP.icachansind;
clear TMP;
EEG = pop_saveset(EEG, 'filename',['ICA_0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']); %save 0.1hz+ICA matrix .set

%% !!! when 'reject component' window pops up, before rejecting need to label components manually (precaution)
EEG = pop_loadset('filename', ['ICA_0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']);
%IC component rejection
EEG=iclabel(EEG);
noisethreshold = [0 0;0.9 1; 0.9 1; 0 0; 0 0; 0 0; 0 0]; %IC label parameters: 90% Muscle and Eye probability;
EEG = pop_icflag(EEG, noisethreshold);
% remove bad component(s)
EEG = pop_subcomp( EEG ); %manual check
% save
EEG = pop_saveset(EEG, 'filename',['ICs_ICA_0.1HZ_' name_temp(1:2) '_H' int2str(j) '.set'], 'filepath', [pwd '/output']); %set 0.1hz filter + ICA + bad ICs removed

% check bad channels again
pop_rejchan(EEG)
%EEG = pop_rejchan(EEG, 'elec',[1:30],'measure','prob','norm','on','threshold',5); %automatic rejection parameters
fprintf('In next section: Remove *bad electrodes from brackets')
%% artifact detection

%%%!! exclude *bad* electrodes, comment which electrode(s) and restore
%%%after participant is done
frontals = [3:6];
electrodes=[1 2 7:30]; %!!take note of which electrode is removed

%peak to peak (frontal elec and other elec)
EEG  = pop_artextval( EEG , 'Channel', electrodes, 'Flag',  1, 'Threshold', [ -75 75], 'Twindow',[ -204 1200] );
EEG  = pop_artextval( EEG , 'Channel', frontals, 'Flag',  1, 'Threshold', [ -100 100], 'Twindow',[ -204 1200] );

%flat line (frontal elec and other elec)
EEG  = pop_artflatline( EEG , 'Channel', electrodes, 'Duration',  100, 'Flag',  1, 'Threshold', [ -1e-07 1e-07], 'Twindow', [ -204 1200] );
EEG  = pop_artflatline( EEG , 'Channel', frontals, 'Duration',  100, 'Flag',  1, 'Threshold', [ -1e-07 1e-07], 'Twindow', [ -204 1200] );

%close;
EEG = pop_saveset( EEG, [nameset] ,[pwd '/output']);

%% compute erp
ERP = pop_averager( EEG , 'Criterion', 'good', 'DSindex',1, 'ExcludeBoundary', 'on', 'SEM', 'on' );

% load channel location information
ERP = pop_erpchanedit( ERP, [currentDirectory '/Cap30electrodes.ced']);

% Save the erp
ERP = pop_savemyerp(ERP, 'erpname', nameerp, 'filename', nameerp, 'filepath', [pwd], 'Warning', 'on');
ERP = pop_summary_AR_erp_detection(ERP, [currentDirectory '/output' '\' nameerp(1:end-4) '.txt'])


fprintf('Both participants done. The final output files are named as follows: <Pair n°, _MH1/_MH2, .set/erp/txt>.');


