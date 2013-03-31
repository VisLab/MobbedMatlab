%% convert one (Schalk) edf file to (EEGLAB) set file and save it
%
% input
%   fullPathFileName: full path file name of the file
% output
%   converted dataset
%
function [eeg] = schalk2set(fullPathFileName)
    if strcmp(fullPathFileName(end-2:end), 'edf')
        eeg = importEDF(fullPathFileName);		
        eeg = uniqueEventNameSchalk(eeg, fullPathFileName);% generage unique event name
        %[filePath, fileName, ~] = fileparts(fullPathFileName);
        %saveset(eeg, [filePath '\' fileName '.set']);
        [~, fileName, ~] = fileparts(fullPathFileName);
        saveset(eeg, [pwd '\converted\' fileName '.set']);
    end
end

function EEG = importEDF(filename) 
    EEG = eeg_emptyset;

    % import data
    dat = sopen(filename, 'r', 0,'OVERFLOWDETECTION:OFF');
    
    % check if file is open successfully
    if (dat.FILE.FID<0) || ~dat.FILE.OPEN, 
        dat.FILE.status = -1;
        fprintf(dat.FILE.stderr,'Warning SCLOSE (%s): invalid handle\n',dat.FileName);
        return;
    else
        fprintf('Reading %s in %s format...\n', dat.FILE.Name, dat.TYPE);
        DAT=sread(dat);    % this isn't transposed in original!!!!!!!!
        dat.FILE.OPEN = 0;
        dat.FILE.status = fclose(dat.FILE.FID);
        dat.FILE.FID = -1;
    end
    
    % convert to seconds for sread
    EEG.nbchan          = size(DAT,2);
    EEG.srate           = dat.SampleRate(1);
    EEG.data            = DAT'; % this isn't transposed in original!!!!!!!!
    clear DAT;
    EEG.setname 		= sprintf('%s file', dat.TYPE);
    EEG.comments        = [ 'Original file: ' dat.FileName ];
    EEG.xmin            = 0;
    EEG.trials   = 1;
    EEG.pnts     = size(EEG.data,2);

	EEG.chanlocs = struct('labels', dat.Label(1:min(length(dat.Label), size(EEG.data,1))));
    EEG = eeg_checkset(EEG);

    % extract events % this part I totally revamped to work...  JO
    EEG.event = [];

    if ~isempty(dat.EVENT.POS) 
        dat.EVENT.POS = [];    
        dat.EDF.ANNONS = dat.EDFplus.ANNONS;
    end

    if isempty(dat.EVENT.POS)
        disp('Extracting events from last EEG channel...');
        remain = dat.EDF.ANNONS;
        while true
            % MATLAB recommends textscan. 
            % But textscan does not work with '\0' delimiter.
            % so use strtok(str, 0);
            [token, remain] = strtok(remain, 0); %#ok<STTOK>
            if isempty(token),  break;  end
            [~, r1] = strtok(token, 20);
            if length(r1) ~= 2   % if length 2, the token is time marker. if not, it is an event.
                [t1, r1] = strtok(token, 21);
                startEvent = str2double(t1) * EEG.srate + 1;    % to conver second to array index, +1
                [~, r2] = strtok(r1, 20);
                EEG.event(end+1).latency = startEvent;
                r2(r2 == 20) = [];      % remove delimiter char(20)
                EEG.event(end).type = r2;
            end
        end
        EEG = eeg_checkset(EEG, 'eventconsistency');
    end

    % convert data to single if necessary
    EEG = eeg_checkset(EEG,'makeur');   % Make EEG.urevent field
    EEG = eeg_checkset(EEG);
end

% function [token, remain] = mystrtok(string, delimiter)
%     index = find(string == sprintf('%c', delimiter));
%     token = 
% 
% 
% end

%% Assign unique event name for Schalk's datasets
% unique event name = task name + original event tag (T0, T1 or T2)
% task name for each run file and its meaning
%	BASE1 , R01 file , Baseline (eye open)
%	BASE2 , R02 file , Baseline (eye closed)
%	TASK1 , R03,R07,R11 files , Left Right Real
%	TASK2 , R04,R08,R12 files , Left Right Imagine
%	TASK3 , R05,R09,R13 files , Up Down Real
%	TASK4 , R06,R010,R14 files , Up Down Imagine
function [EEG] = uniqueEventNameSchalk(EEG, filename) 
    switch filename(end-5:end-4)
        case '01',   eName = 'BASE1';
        case '02',   eName = 'BASE2';
        case {'03','07','11'}, eName = 'TASK1';
        case {'04','08','12'}, eName = 'TASK2';
        case {'05','09','13'}, eName = 'TASK3';
        case {'06','10','14'}, eName = 'TASK4';
        otherwise, eName = 'UNKNOWN'; 
    end
    for e=1:length(EEG.event)
        EEG.event(e).type = [eName EEG.event(e).type];
    end
end

function EEG = eeg_emptyset()
	EEG.setname     = '';
	EEG.filename    = '';
	EEG.filepath    = '';
	EEG.subject     = '';
	EEG.group       = '';
	EEG.condition   = '';
	EEG.session     = [];
	EEG.comments    = '';
	EEG.nbchan      = 0;
	EEG.trials      = 0;
	EEG.pnts        = 0;
	EEG.srate       = 1;
	EEG.xmin        = 0;
	EEG.xmax        = 0;
	EEG.times       = [];
	EEG.data        = [];
	EEG.icaact      = [];
	EEG.icawinv     = [];
	EEG.icasphere   = [];
	EEG.icaweights  = [];
	EEG.icachansind = [];
	EEG.chanlocs    = [];
	EEG.urchanlocs  = [];
	EEG.chaninfo    = [];
	EEG.ref         = [];
	EEG.event       = [];
	EEG.urevent     = [];
	EEG.eventdescription = {};
	EEG.epoch       = [];
	EEG.epochdescription = {};
	EEG.reject      = [];
	EEG.stats       = [];
	EEG.specdata    = [];
	EEG.specicaact  = [];
	EEG.splinefile  = '';
	EEG.icasplinefile = '';
	EEG.dipfit      = [];
	EEG.history     = '';
	EEG.saved       = 'no';
	EEG.etc         = [];
    EEG.datfile     = '';
end

% call: pop_saveset(eeg, 'filename', fullPathFileName, 'savemode', 'onefile');
function saveset(EEG, fullPathFileName)
    if isempty(EEG), error('Cannot save empty datasets'); end

    % current filename without the .set
    [EEG.filepath filenamenoext] = fileparts( fullPathFileName ); 
    EEG.filename = [ filenamenoext '.set' ];

    % Saving data as float and Matlab
    try 
        fprintf('Saving dataset...\n');
        EEG.saved = 'yes';
        save(fullfile(EEG.filepath, EEG.filename), '-v6',   '-mat', 'EEG');
    catch err
        rethrow(err)
    end
end

function [HDR] = sopen(arg1,PERMISSION,CHAN,MODE)

    HDR.FileName = arg1;
    
    HDR.FILE.stdout = 1;
    HDR.FILE.stderr = 2;
    HDR.FILE.PERMISSION = PERMISSION; 
    HDR.FILE.OPEN = 0.0;
    HDR.FILE.FID = -1;
    
    [pName,fName,fExt] = fileparts(HDR.FileName);
    HDR.FILE.Path = pName; 
    HDR.FILE.Name = fName; 
	HDR.FILE.Ext  = fExt(2:end); 

    HDR.TYPE = 'EDF';
    HDR.ErrNum = 0.0;
    HDR.ErrMsg = '';
    
    fid = fopen(HDR.FileName,HDR.FILE.PERMISSION);
    fseek(fid,0,'eof');
    HDR.FILE.size = ftell(fid);
    fclose(fid);

    ReRefMx = [];

    %% Initialization
    HDR.NS = NaN; 
    HDR.SampleRate = NaN; 
    HDR.T0 = nan(1,6);
    HDR.Filter.Notch    = NaN; 
    HDR.Filter.LowPass  = NaN; 
    HDR.Filter.HighPass = NaN; 
    HDR.FLAG = [];
    HDR.FLAG.FILT = 0; 	% FLAG if any filter is applied; 
    HDR.FLAG.TRIGGERED = 0; % the data is untriggered by default
    HDR.FLAG.UCAL = ~isempty(strfind(MODE,'UCAL'));   % FLAG for UN-CALIBRATING
    HDR.FLAG.OVERFLOWDETECTION = isempty(strfind(upper(MODE),'OVERFLOWDETECTION:OFF'));
    HDR.FLAG.FORCEALLCHANNEL = ~isempty(strfind(upper(MODE),'FORCEALLCHANNEL'));
    HDR.FLAG.OUTPUT = 'double'; 

    FLAG.BDF.status2event = regexp (MODE, '(^BDF:|[ \t;,]BDF:)(\d*)([ \t;,]|$)','tokens');

    HDR.EVENT.TYP = []; 
    HDR.EVENT.POS = []; 

    %%%%% Define Size for each data type %%%%%
    GDFTYP_BYTE=zeros(1,512+64);
    GDFTYP_BYTE(256+(1:64))=(1:64)/8;
    GDFTYP_BYTE(512+(1:64))=(1:64)/8;
    GDFTYP_BYTE(1:19)=[1 1 1 2 2 4 4 8 8 4 8 0 0 0 0 0 4 8 16]';

    H2idx = [16 80 8 8 8 8 8 80 8 32];

    HDR.ErrNum = 0; 

    [HDR.FILE.FID]=fopen(HDR.FileName,[HDR.FILE.PERMISSION,'b'],'ieee-le');          

    %%% Read Fixed Header %%%
    H1=fread(HDR.FILE.FID,[1,192],'uint8');     %

    HDR.VERSION=char(H1(1:8));                     % 8 Byte  Versionsnummer 
    HDR.VERSION = 0; 

    HDR.Patient.Sex = 0;
    HDR.Patient.Handedness = 0;

    H1(193:256)= fread(HDR.FILE.FID,[1,256-192],'uint8');     %
    H1 = char(H1);
    HDR.PID = deblank(char(H1(9:88)));                  % 80 Byte local patient identification
    HDR.RID = deblank(char(H1(89:168)));                % 80 Byte local recording identification
    [HDR.Patient.Id,tmp] = strtok(HDR.PID,' ');
    [~,tmp] = strtok(tmp,' ');
    [~,tmp] = strtok(tmp,' ');
    HDR.Patient.Name = tmp(2:end); 

    tmp = repmat(' ',1,22);
    tmp([3:4,6:7,9:10,12:13,15:16,18:19]) = H1(168+[7:8,4:5,1:2,9:10,12:13,15:16]);
    tmp1 = mystr2double(tmp);
    if length(tmp1)==6,
        HDR.T0(1:6) = tmp1;
    end

    % Y2K compatibility until year 2084
    if HDR.T0(1) < 85    % for biomedical data recorded in the 1950's and converted to EDF
        HDR.T0(1) = 2000+HDR.T0(1);
    elseif HDR.T0(1) < 100
        HDR.T0(1) = 1900+HDR.T0(1);
        %else % already corrected, do not change
    end

    HDR.HeadLen = mystr2double(H1(185:192));           % 8 Bytes  Length of Header
    HDR.reserved1=H1(193:236);              % 44 Bytes reserved   
    HDR.NRec    = mystr2double(H1(237:244));     % 8 Bytes  # of data records
    HDR.Dur     = mystr2double(H1(245:252));     % 8 Bytes  # duration of data record in sec
    HDR.NS      = mystr2double(H1(253:256));     % 4 Bytes  # of signals
    HDR.AS.H1 = H1;	                     % for debugging the EDF Header

    if strcmp(HDR.reserved1(1:4),'EDF+'),	% EDF+ specific header information 
        [HDR.Patient.Id,   tmp] = strtok(HDR.PID,' ');
        [sex, tmp] = strtok(tmp,' ');
        [~, tmp] = strtok(tmp,' ');
        [HDR.Patient.Name, ~] = strtok(tmp,' ');
        HDR.Patient.Sex = any(sex(1)=='mM') + any(sex(1)=='Ff')*2;

        [~, tmp] = strtok(HDR.RID,' ');
        [HDR.Date2, tmp] = strtok(tmp,' ');
        [HDR.RID, tmp] = strtok(tmp,' ');
        [HDR.REC.Technician,  tmp] = strtok(tmp,' ');
        [HDR.REC.Equipment,   ~] = strtok(tmp,' ');
    end

    % Octave assumes HDR.NS is a matrix instead of a scalare. Therefore, we need
    % Otherwise, eye(HDR.NS) will be executed as eye(size(HDR.NS)).
    HDR.NS = HDR.NS(1);     

    %%% Read variable Header %%%
    %if ~strcmp(HDR.VERSION(1:3),'GDF'),
    if ~strcmp(HDR.TYPE,'GDF'),
        idx1=cumsum([0 H2idx]);
        idx2=HDR.NS*idx1;

        h2=zeros(HDR.NS,256);
        H2=fread(HDR.FILE.FID,HDR.NS*256,'uint8');

        for k=1:length(H2idx);
            %disp([k size(H2) idx2(k) idx2(k+1) H2idx(k)]);
            h2(:,idx1(k)+1:idx1(k+1))=reshape(H2(idx2(k)+1:idx2(k+1)),H2idx(k),HDR.NS)';
        end
        h2=char(h2);

        HDR.Label      =    cellstr(h2(:,idx1(1)+1:idx1(2)));
        HDR.Transducer =    cellstr(h2(:,idx1(2)+1:idx1(3)));
        HDR.PhysDim    =    cellstr(h2(:,idx1(3)+1:idx1(4)));
        HDR.PhysMin    = mystr2double(cellstr(h2(:,idx1(4)+1:idx1(5))))';
        HDR.PhysMax    = mystr2double(cellstr(h2(:,idx1(5)+1:idx1(6))))';
        HDR.DigMin     = mystr2double(cellstr(h2(:,idx1(6)+1:idx1(7))))';
        HDR.DigMax     = mystr2double(cellstr(h2(:,idx1(7)+1:idx1(8))))';
        HDR.PreFilt    =            h2(:,idx1(8)+1:idx1(9));
        HDR.AS.SPR     = mystr2double(cellstr(h2(:,idx1(9)+1:idx1(10))));
        HDR.GDFTYP     = 3*ones(1,HDR.NS);	%	datatype
    end

    HDR.SPR = 1;
    if (HDR.NS>0)
        if ~isfield(HDR,'THRESHOLD')
            HDR.THRESHOLD  = [HDR.DigMin',HDR.DigMax'];       % automated overflow detection 
        end 
        if any(HDR.PhysMax==HDR.PhysMin), HDR.ErrNum=[1029,HDR.ErrNum]; end	
        if any(HDR.DigMax ==HDR.DigMin ), HDR.ErrNum=[1030,HDR.ErrNum]; end	
        HDR.Cal = (HDR.PhysMax-HDR.PhysMin)./(HDR.DigMax-HDR.DigMin);
        HDR.Off = HDR.PhysMin - HDR.Cal .* HDR.DigMin;

        HDR.AS.SampleRate = HDR.AS.SPR / HDR.Dur;
        if (CHAN==0)
            chan = 1:HDR.NS;
            if strcmp(HDR.TYPE,'EDF')
                if strcmp(HDR.reserved1(1:4),'EDF+')
                    tmp = strncmp(HDR.Label, 'EDF Annotations', length('EDF Annotations'));
                    chan(tmp)=[];
                end 
            end
        end	
        for k=chan,
            if (HDR.AS.SPR(k)>0)
                HDR.SPR = lcm(HDR.SPR,HDR.AS.SPR(k));
            end
        end
        HDR.SampleRate = HDR.SPR/HDR.Dur;

        HDR.AS.spb = sum(HDR.AS.SPR);	% Samples per Block
        HDR.AS.bi  = [0;cumsum(HDR.AS.SPR(:))]; 
        HDR.AS.BPR = ceil(HDR.AS.SPR.*GDFTYP_BYTE(HDR.GDFTYP+1)'); 
        HDR.AS.SAMECHANTYP = all(HDR.AS.BPR == (HDR.AS.SPR.*GDFTYP_BYTE(HDR.GDFTYP+1)')) && ~any(diff(HDR.GDFTYP)); 
        HDR.AS.bpb = sum(ceil(HDR.AS.SPR.*GDFTYP_BYTE(HDR.GDFTYP+1)'));	% Bytes per Block
        HDR.Calib  = [HDR.Off; diag(HDR.Cal)];
    end

    if HDR.VERSION<1.9,
        HDR.Filter.LowPass = nan(1,HDR.NS);
        HDR.Filter.HighPass = nan(1,HDR.NS);
        HDR.Filter.Notch = nan(1,HDR.NS);
        for k=1:HDR.NS,
            tmp = HDR.PreFilt(k,:);

            C = textscan(tmp, '%s', 'delimiter', ': ');
            T1 = C{1}{1};   F1 = C{1}{2};
            T2 = C{1}{3};   F2 = C{1}{4};
            T3 = C{1}{5};   F3 = C{1}{6};

            F1(F1==',')='.';
            F2(F2==',')='.';
            F3(F3==',')='.';

            if strcmp(F1,'DC'), F1='0'; end
            if strcmp(F2,'DC'), F2='0'; end
            if strcmp(F3,'DC'), F3='0'; end

            tmp = strfind(lower(F1),'hz');
            if ~isempty(tmp), F1=F1(1:tmp-1); end
            tmp = strfind(lower(F2),'hz');
            if ~isempty(tmp), F2=F2(1:tmp-1); end
            tmp = strfind(lower(F3),'hz');
            if ~isempty(tmp), F3=F3(1:tmp-1); end

            tmp = mystr2double(F1); 
            if isempty(tmp),tmp=NaN; end 
            if strcmp(T1,'LP'), 
                HDR.Filter.LowPass(k) = tmp;
            elseif strcmp(T1,'HP'), 
                HDR.Filter.HighPass(k)= tmp;
            elseif strcmp(T1,'Notch'), 
                HDR.Filter.Notch(k)   = tmp;
            end
            tmp = mystr2double(F2); 
            if isempty(tmp),tmp=NaN; end 
            if strcmp(T2,'LP'), 
                HDR.Filter.LowPass(k) = tmp;
            elseif strcmp(T2,'HP'), 
                HDR.Filter.HighPass(k)= tmp;
            elseif strcmp(T2,'Notch'), 
                HDR.Filter.Notch(k)   = tmp;
            end
            tmp = mystr2double(F3); 
            if isempty(tmp),tmp=NaN; end 
            if strcmp(T3,'LP'), 
                HDR.Filter.LowPass(k) = tmp;
            elseif strcmp(T3,'HP'), 
                HDR.Filter.HighPass(k)= tmp;
            elseif strcmp(T3,'Notch'), 
                HDR.Filter.Notch(k)   = tmp;
            end
        end
    end

    % filesize, position of eventtable, headerlength, etc. 	
    HDR.AS.EVENTTABLEPOS = -1;
    if (HDR.FILE.size == HDR.HeadLen)
        HDR.NRec = 0; 
    elseif HDR.NRec == -1   % unknown record size, determine correct NRec
        HDR.NRec = floor((HDR.FILE.size - HDR.HeadLen) / HDR.AS.bpb);
    end

    % prepare SREAD for different data types 
    n = 0; 
    typ = [-1;HDR.GDFTYP(:)];
    for k = 1:HDR.NS; 
        if (typ(k) == typ(k+1)),
            HDR.AS.c(n)   = HDR.AS.c(n)  + HDR.AS.SPR(k);
            HDR.AS.c2(n)  = HDR.AS.c2(n) + HDR.AS.BPR(k);
        else
            n = n + 1; 
            HDR.AS.c(n)   = HDR.AS.SPR(k);
            HDR.AS.c2(n)  = HDR.AS.BPR(k);
            HDR.AS.TYP(n) = HDR.GDFTYP(k);
        end
    end

    if 0, 
    elseif strcmp(HDR.TYPE,'EDF') && (sum(strncmp(HDR.Label, 'EDF Annotations', length('EDF Annotations')))==1),
        % EDF+: 
        tmp =  find(strncmp(HDR.Label, 'EDF Annotations', length('EDF Annotations')));
        HDR.EDF.Annotations = tmp;
        if isempty(ReRefMx)
            ReRefMx = sparse(1:HDR.NS,1:HDR.NS,1);
            ReRefMx(:,tmp) = [];
        end	

        fseek(HDR.FILE.FID,HDR.HeadLen+HDR.AS.bi(HDR.EDF.Annotations)*2,'bof');
        t = fread(HDR.FILE.FID,inf,[int2str(HDR.AS.SPR(HDR.EDF.Annotations)*2),'*uchar=>uchar'],HDR.AS.bpb-HDR.AS.SPR(HDR.EDF.Annotations)*2);
        HDR.EDFplus.ANNONS = char(t');
    end

    if isfield(HDR,'EDFplus') && isfield(HDR.EDFplus,'ANNONS'),
        %% decode EDF+/BDF+ annotations
        t = HDR.EDFplus.ANNONS;
        N = length(t);
        onset = zeros(N, 1);
        dur = zeros(N, 1);
        Desc = cell(1, N);
        N = 0;
        while ~isempty(t)
            % remove leading 0
            t  = t(find(t>0,1):end);

            ix = find(t==20,2); 		
            if isempty(ix), break; end

            % next event 
            N = N + 1; 
            [s1,s2] = strtok(t(1:ix(1)-1),21);
            s3 = t(ix(1)+1:ix(2)-1);

            tmp = mystr2double(s1);
            onset(N,1) = tmp;
            if  ~isempty(s2)
                tmp = mystr2double(s2(2:end));
                dur(N,1) = tmp; 	
            else 
                dur(N,1) = 0; 	
            end
            if all(s3(2:2:end)==0), s3 = s3(1:2:end); end %% unicode to ascii - FIXME 
            Desc{N} = s3;
            HDR.EVENT.TYP(N,1) = length(Desc{N});
            t = t(ix(2)+1:end);
        end		
        onset(N+1:end, :) = [];
        dur(N+1:end, :) = [];
        Desc(:, N+1:end) = [];
        HDR.EVENT.POS = onset * HDR.SampleRate;
        if any(HDR.EVENT.POS - ceil(HDR.EVENT.POS))
            warning('HDR.EVENT.POS is not integer')         %#ok<WNTAG>
            %HDR.EVENT.POS = round(HDR.EVENT.POS); 
        end
        HDR.EVENT.DUR = dur * HDR.SampleRate;
        HDR.EVENT.CHN = zeros(N,1); 
        % TODO: use eventcodes.txt for predefined event types e.g. QRS->0x501
        [HDR.EVENT.CodeDesc, ~, HDR.EVENT.TYP] = unique(Desc(1:N)');
    end

    fseek(HDR.FILE.FID, HDR.HeadLen, 'bof');
    HDR.FILE.POS  = 0;
    HDR.FILE.OPEN = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %	General Postprecessing for all formats of Header information 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % identify type of signal, complete header information
    if HDR.NS>0,
        HDR = leadidcodexyz(HDR); % complete information on LeadIdCode and Electrode positions of EEG channels.
        HDR.CHANTYP = repmat(' ',1,HDR.NS);
        tmp = HDR.NS-length(HDR.Label);
        %HDR.Label = [HDR.Label(1:HDR.NS,:);repmat(' ',max(0,tmp),size(HDR.Label,2))];
        Label = char(HDR.Label);
        tmp = reshape(lower([[Label(1:min(HDR.NS,size(Label,1)),:);repmat(' ',max(0,tmp),size(Label,2))],repmat(' ',HDR.NS,1)])',1,HDR.NS*(size(Label,2)+1));

        HDR.CHANTYP(ceil([strfind(tmp,'eeg'),strfind(tmp,'meg')]/(size(Label,2)+1))) = 'E'; 
        HDR.CHANTYP(ceil(strfind(tmp,'emg')/(size(Label,2)+1))) = 'M'; 
        HDR.CHANTYP(ceil(strfind(tmp,'eog')/(size(Label,2)+1))) = 'O'; 
        HDR.CHANTYP(ceil([strfind(tmp,'ecg'),strfind(tmp,'ekg')]/(size(Label,2)+1))) = 'C'; 
        HDR.CHANTYP(ceil([strfind(tmp,'air'),strfind(tmp,'resp')]/(size(Label,2)+1))) = 'R'; 
        HDR.CHANTYP(ceil(strfind(tmp,'trig')/(size(Label,2)+1))) = 'T'; 
    end

    [~,ix] = sort(HDR.EVENT.POS);
    HDR.EVENT.TYP=HDR.EVENT.TYP(ix);
    HDR.EVENT.POS=HDR.EVENT.POS(ix);
    HDR.EVENT.DUR=HDR.EVENT.DUR(ix);
    HDR.EVENT.CHN=HDR.EVENT.CHN(ix);

    % Calibration matrix
    if any(HDR.FILE.PERMISSION=='r') && (HDR.NS>0);
        sz = size(ReRefMx);
        HDR.Calib = HDR.Calib*sparse([ReRefMx; zeros(HDR.NS-sz(1),sz(2))]);

        HDR.InChanSelect = find(any(HDR.Calib(2:HDR.NS+1,:),2));
        HDR.Calib = sparse(HDR.Calib([1;1+HDR.InChanSelect(:)],:));
    end
end

function [HDR] = leadidcodexyz(arg1)
    % BIOSIG_GLOBAL=[]; %%% used for debugging, only. 

    HDR = arg1; 

    tmp.flag1 = isfield(HDR,'ELEC');
    tmp.flag2 = isfield(HDR,'LeadIdCode');
    tmp.flag3 = isfield(HDR,'Label');

    if (~tmp.flag1 || ~tmp.flag2 || ~tmp.flag3),
        if tmp.flag3,
            NS = length(HDR.Label); 
        end      

        if ~tmp.flag1,
            HDR.ELEC.XYZ   = NaN(NS,3);
            HDR.ELEC.Phi   = NaN(NS,1);
            HDR.ELEC.Theta = NaN(NS,1);
        end
        if ~tmp.flag2,
            HDR.LeadIdCode = NaN(NS,1);
        end
    end
end

function [S] = sread(HDR)

    NoS = inf; 

    StartPos = 0; 

    % define HDR.out.EVENT. This is used by EEGLAB. 
    ix = (HDR.EVENT.POS >= StartPos*HDR.SampleRate) & (HDR.EVENT.POS <= (StartPos+NoS)*HDR.SampleRate); 
    HDR.out.EVENT.POS = HDR.EVENT.POS(ix)-StartPos;
    HDR.out.EVENT.TYP = HDR.EVENT.TYP(ix);
    if isfield(HDR.EVENT,'CHN')
        if ~isempty(HDR.EVENT.CHN)
            HDR.out.EVENT.CHN = HDR.EVENT.CHN(ix);
        end
    end
    if isfield(HDR.EVENT,'DUR')
        if ~isempty(HDR.EVENT.DUR)
            HDR.out.EVENT.DUR = HDR.EVENT.DUR(ix);
        end
    end

    % experimental, might replace SDFREAD.M 
    nr     = min(HDR.NRec*HDR.SPR-HDR.FILE.POS, NoS*HDR.SampleRate);

    block1 = floor(HDR.FILE.POS/HDR.SPR);
    ix1    = HDR.FILE.POS- block1*HDR.SPR;	% starting sample (minus one) within 1st block 
    nb     = ceil((HDR.FILE.POS+nr)/HDR.SPR)-block1;
    fp     = HDR.HeadLen + block1*HDR.AS.bpb;
    fseek(HDR.FILE.FID, fp, 'bof');
    S = zeros(nr, length(HDR.InChanSelect));
    [s,~] = fread(HDR.FILE.FID,[HDR.AS.spb, nb],gdfdatatype(HDR.GDFTYP(1)));
    for k = 1:length(HDR.InChanSelect),
       K = HDR.InChanSelect(k);
       S(:,k) = reshape(s(HDR.AS.bi(K)+1:HDR.AS.bi(K+1),:),HDR.AS.SPR(K)*nb,1);
    end
    S = S(ix1+1:ix1+nr,:);
    count = nr;

    HDR.FILE.POS = HDR.FILE.POS + count;

    if ~HDR.FLAG.UCAL,
        Calib = HDR.Calib;
        tmp   = S;
        S     = zeros(size(S,1),size(Calib,2));   % memory allocation

        for k = 1:size(Calib,2),
            chan = find(Calib(2:end,k));
            S(:,k) = double(tmp(:,chan)) * full(Calib(1+chan,k)) + Calib(1,k);
        end
    end
end

function [datatyp,limits,datatypes,numbits,GDFTYP] = gdfdatatype(GDFTYP)
    
    datatyp = [];
    datatypes = cell(1, length(GDFTYP));
    limits = NaN(length(GDFTYP),3);
    numbits = NaN(size(GDFTYP));

    for k=1:length(GDFTYP),
        datatyp=('int16');
        limit = [-2^15,2^15-1,-2^15];        
        nbits = 16; 
        datatypes{k}  = datatyp;
        limits(k,:)   = limit;
        numbits(k)    = nbits; 
    end
end

function [EEG] = eeg_checkset( EEG, varargin )

    % standard checking
    % -----------------
    ALLEEG = EEG;
    for inddataset = 1:length(ALLEEG)

        EEG = ALLEEG(inddataset);

        % additional checks
        % -----------------
        if ~isempty( varargin)
            for index = 1:length( varargin )
                switch varargin{ index }
                case 'makeur',
                    if ~isempty(EEG.event)
                        disp('eeg_checkset note: creating the original event table (EEG.urevent)');
                        EEG.urevent = EEG.event;
                        for eid = 1:length(EEG.event)
                            EEG.event(eid).urevent = eid;
                        end
                    end
                case 'eventconsistency',
                    EEG = eeg_checkset(EEG);
                otherwise, 
                    error('eeg_checkset: unknown option');
                end
            end
        end

        % numerical format
        % ----------------
        if isnumeric(EEG.data)
            EEG.icawinv    = double(EEG.icawinv); % required for dipole fitting, otherwise it crashes
            EEG.icaweights = double(EEG.icaweights);
            EEG.icasphere  = double(EEG.icasphere);
            try
                if isa(EEG.data, 'double')
                    EEG.data       = single(EEG.data);
                    EEG.icaact     = single(EEG.icaact);
                end
            catch  %#ok<CTCH>
                disp('WARNING: EEGLAB ran out of memory while converting dataset to single precision.');
                disp('         Save dataset (preferably saving data to a separate file; see File > Memory options).');
                disp('         Then reload it.');
            end
        end

        % parameters consistency 
        % -------------------------
        if round(EEG.srate*(EEG.xmax-EEG.xmin)+1) ~= EEG.pnts
            fprintf( 'eeg_checkset note: upper time limit (xmax) adjusted so (xmax-xmin)*srate+1 = number of frames\n');
            EEG.xmax = (EEG.pnts-1)/EEG.srate+EEG.xmin;
        end

        if isempty(EEG.event)
            EEG.event = [];
        end
        if isempty(EEG.event)
            EEG.eventdescription = {};
        end
        if ~isfield(EEG, 'eventdescription') || ~iscell(EEG.eventdescription)
        else
            if ~isempty(EEG.event)
                if length(EEG.eventdescription) > length( fieldnames(EEG.event))
                elseif length(EEG.eventdescription) < length( fieldnames(EEG.event))
                    EEG.eventdescription(end+1:length( fieldnames(EEG.event))) = {''};
                end
            end
        end
        % create urevent if continuous data
        % ---------------------------------

        if isempty(EEG.epoch)
            EEG.epoch = [];
        end

        % check ica
        % ---------
        if ~isfield(EEG, 'icachansind')
        elseif isempty(EEG.icachansind)
            if isempty(EEG.icaweights)
                EEG.icachansind = []; 
            end
        end
        
        if isempty(EEG.icaact)
            EEG.icaact = [];
        end

        % -------------
        % check chanlocs
        % -------------
        if ~isempty( EEG.chanlocs )

            % reference (use EEG structure)
            % ---------
            if ~strcmpi(EEG.ref, 'averef')
                ref = '';
            end
            if ~isfield( EEG.chanlocs, 'ref')
                EEG.chanlocs(1).ref = ref;
            end
            charrefs = cellfun('isclass',{EEG.chanlocs.ref},'char');
            if any(charrefs) 
                ref = ''; 
            end
            for tmpind = find(~charrefs)
                EEG.chanlocs(tmpind).ref = ref;
            end

            % force Nosedir to +X (done here because of DIPFIT)
            % -------------------
            if isfield(EEG.chaninfo, 'nosedir')
                EEG.chaninfo.nosedir = '+X';
            end

            % general checking of channels
            % ----------------------------
            EEG = eeg_checkchanlocs(EEG);
        end
        EEG.chaninfo.icachansind = EEG.icachansind; % just a copy for programming convinience

        % DIPFIT structure
        % ----------------
        if ~isfield(EEG,'dipfit') || isempty(EEG.dipfit)
            EEG.dipfit = []; 
        end

        if ~isfield(EEG, 'ref') || isempty(EEG.ref), 
            EEG.ref = 'common';  
        end

        listf = { 'rejjp' 'rejkurt' 'rejmanual' 'rejthresh' 'rejconst', 'rejfreq' ...
            'icarejjp' 'icarejkurt' 'icarejmanual' 'icarejthresh' 'icarejconst', 'icarejfreq'};
        for index = 1:length(listf)
            name = listf{index};
            elecfield = [name 'E'];
            if ~isfield(EEG.reject, elecfield),     
                EEG.reject.(elecfield) = [];  
            end
            if ~isfield(EEG.reject, name)
                EEG.reject.(name) = [];
                
            end
        end
        if ~isfield(EEG.reject, 'rejglobal'),        
            EEG.reject.rejglobal = [];  end
        if ~isfield(EEG.reject, 'rejglobalE'),        
            EEG.reject.rejglobalE = [];  end

        % default colors for rejection
        % ----------------------------
        if ~isfield(EEG.reject, 'rejmanualcol'),   
            EEG.reject.rejmanualcol = [1.0000    1     0.783];  end
        if ~isfield(EEG.reject, 'rejthreshcol'),   
            EEG.reject.rejthreshcol = [0.8487    1.0000    0.5008];  end
        if ~isfield(EEG.reject, 'rejconstcol'),    
            EEG.reject.rejconstcol  = [0.6940    1.0000    0.7008];  end
        if ~isfield(EEG.reject, 'rejjpcol'),       
            EEG.reject.rejjpcol     = [1.0000    0.6991    0.7537];  end
        if ~isfield(EEG.reject, 'rejkurtcol'),     
            EEG.reject.rejkurtcol   = [0.6880    0.7042    1.0000];  end
        if ~isfield(EEG.reject, 'rejfreqcol'),     
            EEG.reject.rejfreqcol   = [0.9596    0.7193    1.0000];  end
        if ~isfield(EEG.reject, 'disprej'),        
            EEG.reject.disprej      = { }; end

        if ~isfield(EEG.stats, 'jp'),        
            EEG.stats.jp = [];  end
        if ~isfield(EEG.stats, 'jpE'),       
            EEG.stats.jpE = [];  end
        if ~isfield(EEG.stats, 'icajp'),     
            EEG.stats.icajp = [];  end
        if ~isfield(EEG.stats, 'icajpE'),    
            EEG.stats.icajpE = [];  end
        if ~isfield(EEG.stats, 'kurt'),      
            EEG.stats.kurt = [];  end
        if ~isfield(EEG.stats, 'kurtE'),     
            EEG.stats.kurtE = [];  end
        if ~isfield(EEG.stats, 'icakurt'),   
            EEG.stats.icakurt = [];  end
        if ~isfield(EEG.stats, 'icakurtE'),  
            EEG.stats.icakurtE = [];  end

        % component rejection
        % -------------------
        if ~isfield(EEG.stats, 'compenta'),        
            EEG.stats.compenta = [];  end
        if ~isfield(EEG.stats, 'compentr'),        
            EEG.stats.compentr = [];  end
        if ~isfield(EEG.stats, 'compkurta'),       
            EEG.stats.compkurta = [];  end
        if ~isfield(EEG.stats, 'compkurtr'),       
            EEG.stats.compkurtr = [];  end
        if ~isfield(EEG.stats, 'compkurtdist'),    
            EEG.stats.compkurtdist = [];  end
        if ~isfield(EEG.reject, 'threshold'),      
            EEG.reject.threshold = [0.8 0.8 0.8];  end
        if ~isfield(EEG.reject, 'threshentropy'),  
            EEG.reject.threshentropy = 600;  end
        if ~isfield(EEG.reject, 'threshkurtact'),  
            EEG.reject.threshkurtact = 600;  end
        if ~isfield(EEG.reject, 'threshkurtdist'), 
            EEG.reject.threshkurtdist = 600;  end
        if ~isfield(EEG.reject, 'gcompreject'),    
            EEG.reject.gcompreject = [];  end

        % store in new structure
        % ----------------------
        if isstruct(EEG)
            ALLEEGNEW = EEG;
        end
    end

    % recorder fields
    % ---------------
    fieldorder = { 'setname' ...
        'filename' ...
        'filepath' ...
        'subject' ...
        'group' ...
        'condition' ...
        'session' ...
        'comments' ...
        'nbchan' ...
        'trials' ...
        'pnts' ...
        'srate' ...
        'xmin' ...
        'xmax' ...
        'times' ...
        'data' ...
        'icaact' ...
        'icawinv' ...
        'icasphere' ...
        'icaweights' ...
        'icachansind' ...
        'chanlocs' ...
        'urchanlocs' ...
        'chaninfo' ...
        'ref' ...
        'event' ...
        'urevent' ...
        'eventdescription' ...
        'epoch' ...
        'epochdescription' ...
        'reject' ...
        'stats' ...
        'specdata' ...
        'specicaact' ...
        'splinefile' ...
        'icasplinefile' ...
        'dipfit' ...
        'history' ...
        'saved' ...
        'etc' };

    for fcell = fieldnames(EEG)'
        fname = fcell{1};
        if ~any(strcmp(fieldorder,fname))
            fieldorder{end+1} = fname;
        end
    end

    try
        ALLEEGNEW = orderfields(ALLEEGNEW, fieldorder);
        EEG = ALLEEGNEW;
    catch %#ok<CTCH>
        disp('Couldn''t order data set fields properly.');
    end

    if exist('ALLEEGNEW','var')
        EEG = ALLEEGNEW;
    end
end

function [chans]= eeg_checkchanlocs(chans)

    if nargin < 2
        chaninfo = [];
    end

    processingEEGstruct = 0;
    if isfield(chans, 'data')
        processingEEGstruct = 1;
        tmpEEG = chans;
        chans = tmpEEG.chanlocs;
        chaninfo = tmpEEG.chaninfo;
    end

    [chanedit,~,complicated] = insertchans(chans, chaninfo);

    nosevals       = { '+X' '-X' '+Y' '-Y' };
    if ~isfield(chaninfo, 'plotrad'), 
        chaninfo.plotrad = []; end
    if ~isfield(chaninfo, 'shrink'),  
        chaninfo.shrink = [];  end
    if ~isfield(chaninfo, 'nosedir'), 
        chaninfo.nosedir = nosevals{1}; end

    % set non-existent fields to []
    % -----------------------------
    fields    = { 'labels' 'theta' 'radius' 'X'   'Y'   'Z'   'sph_theta' 'sph_phi' 'sph_radius' 'type' 'ref' 'urchan' };
    fieldtype = { 'str'    'num'   'num'    'num' 'num' 'num' 'num'       'num'     'num'        'str'  'str' 'num'    };
    check_newfields = true; %length(fieldnames(chanedit)) < length(fields);
    if ~isempty(chanedit)
        for index = 1:length(fields)
            if check_newfields && ~isfield(chanedit, fields{index})
                % new field
                % ---------
                if strcmpi(fieldtype{index}, 'num')
                    chanedit = setfield(chanedit, {1}, fields{index}, []);
                else
                    for indchan = 1:length(chanedit)
                        chanedit = setfield(chanedit, {indchan}, fields{index}, '');
                    end
                end
            end
        end
    end
    if ~isequal(fieldnames(chanedit)',fields)
        try
            chanedit = orderfields(chanedit, fields);
        catch  %#ok<CTCH>
        end
    end

    % reconstruct the chans structure
    % -------------------------------
    if complicated
    else
        chans = rmfield(chanedit,'datachan');
        chaninfo.nodatchans = [];
    end

    if processingEEGstruct
        tmpEEG.chanlocs = chans;
        tmpEEG.chaninfo = chaninfo;
        chans = tmpEEG;
    end
end

% ----------------------------------------
% fuse data channels and non-data channels
% ----------------------------------------
function [chans, chaninfo,complicated] = insertchans(chans, chaninfo)
    [chans.datachan] = deal(1);
    complicated = false;        % whether we need complicated treatment of datachans & co further down the road.....
end

function [num,status,strarray] = mystr2double(s)

    % valid_char = '0123456789eE+-.nNaAiIfF';	% digits, sign, exponent,NaN,Inf
    valid_delim = char(sort([0,9:14,32:34,abs('()[]{},;:"|/')]));	% valid delimiter
    cdelim = char([9,32,abs(',')]);		% column delimiter
    rdelim = char([0,10,13,abs(';')]);	% row delimiter
    ddelim = '.';

    % check if delimiters are valid
    tmp  = sort(abs([cdelim,rdelim]));
    flag = zeros(size(tmp));
    k1 = 1;
    k2 = 1;
    while (k1 <= length(tmp)) && (k2 <= length(valid_delim)),
        if tmp(k1) == valid_delim(k2),            
            flag(k1) = 1; 
            k1 = k1 + 1;
        elseif tmp(k1) > valid_delim(k2),            
            k2 = k2 + 1;
        end
    end

    num = [];
    status = 0;
    strarray = {};
    if isempty(s),
        return;
    elseif iscell(s),
        strarray = s;
    elseif ischar(s) 
        s(end+1) = rdelim(1);     % add stop sign; makes sure last digit is not skipped

        RD = zeros(size(s));
        for k = 1:length(rdelim),
            RD = RD | (s==rdelim(k));
        end
        CD = RD;
        for k = 1:length(cdelim),
            CD = CD | (s==cdelim(k));
        end

        k1 = 1; % current row
        k2 = 0; % current column

        sl = length(s);
        ix = 1;
        %while (ix < sl) & any(abs(s(ix))==[rdelim,cdelim]),
        while (ix < sl) && CD(ix), 
            ix = ix + 1;
        end
        ta = ix; te = [];
        strarray = cell(1, sl);
        
        while ix <= sl;
            if (ix == sl),
                te = sl;
            end
            %if any(abs(s(ix))==[cdelim(1),rdelim(1)]),
            if CD(ix), 
                te = ix - 1;
            end
            if ~isempty(te),
                k2 = k2 + 1;
                strarray{k1,k2} = s(ta:te);

                flag = 0;
                %while any(abs(s(ix))==[cdelim(1),rdelim(1)]) & (ix < sl),
                while CD(ix) && (ix < sl),
                    flag = flag | RD(ix);
                    ix = ix + 1;
                end

                ta = ix;
                te = [];
            end
            ix = ix + 1;
        end 
        strarray(:, k2+1:end) = [];
    else
        error('STR2DOUBLE: invalid input argument');
    end

    [nr,nc]= size(strarray);
    status = zeros(nr,nc);
    num = NaN(nr,nc);

    for k1 = 1:nr,
        for k2 = 1:nc,
            t = strarray{k1,k2};
            %% get mantisse
            if ddelim=='.',
                t(t==ddelim)='.';
            end	
            [v,c,~,ni] = sscanf(char(t),'%f %s');
            c = c * (ni>length(t));
            if (c==1),
                num(k1,k2) = v;
            else
                num(k1,k2) = NaN;
                status(k1,k2) = -1;
            end
        end
    end        
end


