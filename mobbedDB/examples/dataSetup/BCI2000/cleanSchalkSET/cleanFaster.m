%% script to run FASTER on all set files 
%  in the directory and its sub directories
%  . by Kyung, May 13, 2012
%
%  set: EEGLAB dataset
%
%  how to use: run and select the top directory
%
function numFiles = cleanFaster(inDir, outDir)
	%

% function FASTER_directory(dirName, options) 
%     listing = dir(dirName);      
%     for l=1:length(listing)
%         if listing(l).isdir     % if directory, process it recursively
%             switch listing(l).name
%                 case '.'
%                 case '..'
%                 otherwise
%                     FASTER_directory(fullfile(dirName, listing(l).name), options);
%             end
%         else
%             FASTER_file(fullfile(dirName, listing(l).name), options);
%         end
%     end
% end
    options = setOptions;
    numFiles = 0;
    directories = {inDir};
    while ~isempty(directories)
        inFolder = directories{end};

        files = dir(inFolder);
        fileNames = {files.name}';
        fileDirs = cell2mat({files.isdir}');
        compareIndex = ~strcmp(fileNames, '.') & ~strcmp(fileNames, '..');
        % Add subdirectories to list of directories to traverse
        subDirNames = fileNames(compareIndex & fileDirs);
        if ~isempty(subDirNames)      
           subDirs = strcat([inFolder filesep], fileNames(compareIndex & fileDirs));
        else
           subDirs = {};
        end
        directories = [directories(1:end-1); subDirs(:)];
        % Process the files in inFolder
        fileNames = fileNames(compareIndex & ~fileDirs);
        if isempty(fileNames)  
            continue;
        end
        subNumber = str2double(inFolder(end-2:end));
        fprintf('Subject: %g\n', subNumber);
        if subNumber > 14
            continue;
        end
        outFolder = getOutPath(inFolder, inDir, outDir);
        if ~exist(outFolder, 'dir')
            fprintf('Making %s\n', outFolder);
            mkdir(outFolder);
        end
        for k = 1:length(fileNames)
            inName = [inFolder filesep fileNames{k}];
            outName = [outFolder filesep fileNames{k}];
            fprintf('In path: %s, out Path %s\n', inName, outName);
            load(inName);
            tStart = tic;
            EEG = cleanEEG(EEG, options);
            tElapsed = toc(tStart);
            fprintf('Cleaning took %d seconds\n', tElapsed);
            save(outName, 'EEG');
            numFiles = numFiles + 1;
        end
    end  
end

% the modification of FASTER_process()
function EEG = cleanEEG(EEG, options) 
    EEG = eeg_checkset(EEG);   % Make sure this is a valid EEG structure
    ref_chan = options.channel_options.ref_chan;
    eeg_chans = options.channel_options.eeg_chans;
    ext_chans = options.channel_options.ext_chans;
    do_reref = options.channel_options.do_reref;
    EEG.setname = ['clean_' EEG.filename];

    % Check if channel locations exist, and if not load them from disk.
    if (~isfield(EEG.chanlocs,'X') || ~isfield(EEG.chanlocs,'Y') || ~isfield(EEG.chanlocs,'Z') || isempty(EEG.chanlocs)) || isempty([EEG.chanlocs(:).X]) || isempty([EEG.chanlocs(:).Y]) || isempty([EEG.chanlocs(:).Z])
        fprintf('No channel location information.\n');
        return;
    end
    
    % high pass filtering
    w_h=options.filter_options.hpf_freq;
    t_h=options.filter_options.hpf_bandwidth;
    r_h=options.filter_options.hpf_ripple;
    a_h=options.filter_options.hpf_attenuation;

    [m, wtpass, wtstop] = pop_firpmord([w_h-(t_h) w_h+(t_h)], [0 1], [10^(-1*abs(a_h)/20) (10^(r_h/20)-1)/(10^(r_h/20)+1)], EEG.srate);
    if mod(m,2);m=m+1;end;
    EEG = pop_firpm(EEG, 'fcutoff', w_h, 'ftrans', t_h, 'ftype', 'highpass', 'wtpass', wtpass, 'wtstop', wtstop, 'forder', m);

    % low pass filtering
    w_l=options.filter_options.lpf_freq;
    t_l=options.filter_options.lpf_bandwidth;
    r_l=options.filter_options.lpf_ripple;
    a_l=options.filter_options.lpf_attenuation;

    [m, wtpass, wtstop] = pop_firpmord([w_l-(t_l) w_l+(t_l)], [1 0], [(10^(r_l/20)-1)/(10^(r_l/20)+1) 10^(-1*abs(a_l)/20)], EEG.srate);
    if mod(m, 2)
        m = m + 1;
    end;
    EEG = pop_firpm(EEG, 'fcutoff', w_l, 'ftrans', t_l, 'ftype', 'lowpass', 'wtpass', wtpass, 'wtstop', wtstop, 'forder', m);

    % notch filtering
    for n = 1:length(options.filter_options.notch_freq)
        w_n = [options.filter_options.notch_freq(n) - ...
            options.filter_options.notch_bandwidth1/2 ...
            options.filter_options.notch_freq(n) + ...
            options.filter_options.notch_bandwidth1/2];
        t_n = options.filter_options.notch_bandwidth2;
        r_n = options.filter_options.notch_ripple;
        a_n = options.filter_options.notch_attenuation;

        [m, wtpass, wtstop] = pop_firpmord([w_n(1)-(t_n) w_n(1) + ...
            (t_n) w_n(2)-(t_n) w_n(2)+(t_n)], [0 1 0], ...
            [10^(-1*abs(a_n)/20) (10^(r_n/20)-1)/(10^(r_n/20)+1) ...
            10^(-1*abs(a_n)/20)], EEG.srate);
        if mod(m, 2)
            m= m + 1;
        end;
        EEG = pop_firpm(EEG, 'fcutoff', w_n, 'ftrans', t_n, ...
            'ftype', 'bandstop', 'wtpass', wtpass, 'wtstop', ...
             wtstop, 'forder', m);
    end

    list_properties = channel_properties(EEG,eeg_chans, ref_chan);
    lengths = min_z(list_properties, options.channel_options.rejection_options); % Need to edit to make rejection_options.measure a vector, instead of multiple fields
    chans_to_interp = union(eeg_chans(logical(lengths)), ...
                     options.channel_options.bad_channels);
    chans_to_interp = setdiff(chans_to_interp, ref_chan); % Ref chan may appear bad, but we shouldn't interpolate it!
    if (options.channel_options.exclude_EOG_chans)
        chans_to_interp = setdiff(chans_to_interp, options.ica_options.EOG_channels);
    end
    if ~options.channel_options.interp_after_ica
        if ~isempty(chans_to_interp)
            fprintf('Interpolating channel(s)');
            fprintf(' %d',chans_to_interp);
            fprintf('.\n');
            EEG = h_eeg_interp_spl(EEG,chans_to_interp,ext_chans);
        end
    end

    if (do_reref && ~options.ica_options.keep_ICA)
        if ~options.channel_options.interp_after_ica
            EEG = h_pop_reref(EEG, [], 'exclude', ext_chans, 'refstate', ref_chan);
        else
            EEG = h_pop_reref(EEG, [], 'exclude', [ext_chans chans_to_interp], 'refstate', ref_chan);
        end
    end

    do_ica = options.ica_options.run_ica;
    k_value = options.ica_options.k_value;
    do_component_rejection = options.ica_options.component_rejection_on;
    EOG_chans = options.ica_options.EOG_channels;
    ica_chans = options.ica_options.ica_channels;

    if do_ica && (~options.ica_options.keep_ICA || isempty(EEG.icaweights))
        num_pca = min(floor(sqrt(size(EEG.data(:,:),2) / k_value)),(size(EEG.data,1) - length(chans_to_interp) - 1));
        num_pca = min(num_pca,length(setdiff(ica_chans,chans_to_interp)));
        if (options.channel_options.interp_after_ica)
            ica_chans=intersect(setdiff(ica_chans,chans_to_interp),union(eeg_chans,ext_chans));
            EEG = pop_runica(EEG, 'dataset', 1, ...
                  'chanind', setdiff(ica_chans,chans_to_interp), ...
                   'options', {'extended', 1, 'pca',num_pca});
        else
            ica_chans=intersect(ica_chans, union(eeg_chans,ext_chans));
            EEG = pop_runica(EEG,  'dataset', 1, ...
                   'chanind',ica_chans, 'options', ...
                   {'extended', 1, 'pca', num_pca});
        end
    end

    if do_component_rejection && ~isempty(EEG.icaweights)
        EEG = eeg_checkset(EEG);
        original_name = EEG.setname;  % What does this do?
        list_properties = component_properties(EEG, EOG_chans, [w_l-(t_l/2) w_l+(t_l/2)]);
        [lengths] = min_z(list_properties, options.ica_options.rejection_options);

        % Reject
        if ~isempty(find(lengths, 1))
            fprintf('Rejecting components');
            fprintf(' %d', find(lengths));
            fprintf('.\n');
            EEG = pop_subcomp(EEG, find(lengths), 0);
        else
            fprintf('Rejected no components.\n');
        end
        EEG.setname = original_name;
    end

    if options.channel_options.interp_after_ica
        if ~isempty(chans_to_interp)
            fprintf('Interpolating channel(s)');
            fprintf(' %d',chans_to_interp);
            fprintf('.\n');
            EEG = h_eeg_interp_spl(EEG,chans_to_interp,ext_chans);
        end
    end

    if ~isempty(options.channel_options.op_ref_chan)
        EEG = h_pop_reref(EEG, options.channel_options.op_ref_chan, ...
              'exclude',ext_chans, 'refstate', [], 'keepref', 'on');
    end

end


    