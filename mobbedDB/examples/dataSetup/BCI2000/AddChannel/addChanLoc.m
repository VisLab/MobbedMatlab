function addChanLoc
    % add channel location information
    [FileName, PathName, ~] = uigetfile('*.loc;*.locs', 'Load a channel location file'); 
    if ~isequal(FileName, 0)
        chanlocs = readlocs([PathName FileName]);
    end

    [FileList, PathName, ~] = uigetfile('*.set', 'MultiSelect', 'on');
    for i=1:length(FileList)
        FileName = FileList{i};
        TMPVAR = load('-mat', [PathName FileName]);
        EEG = TMPVAR.EEG;
        EEG.saved = 'justloaded';

        if isempty(EEG.chanlocs(1).theta)
            for c=1:EEG.nbchan
                EEG.chanlocs(c).labels = chanlocs(c).labels;
                EEG.chanlocs(c).theta = chanlocs(c).theta;
                EEG.chanlocs(c).radius = chanlocs(c).radius;
                EEG.chanlocs(c).sph_theta = chanlocs(c).sph_theta;
                EEG.chanlocs(c).sph_phi = chanlocs(c).sph_phi;
                EEG.chanlocs(c).X = chanlocs(c).X;
                EEG.chanlocs(c).Y = chanlocs(c).Y;
                EEG.chanlocs(c).Z = chanlocs(c).Z;
                EEG.chanlocs(c).urchan = c;
            end
        end
        EEG.saved = 'yes';
        save([PathName FileName], '-v6',   '-mat', 'EEG');
    end
    fprintf('Done.\n');
end

function eloc = readlocs( filename, varargin ) 
    g.filetype = '';
    g.importmode = 'eeglab';
    g.defaultelp = 'polhemus';
    g.skiplines = [];
    g.elecind = [];
    g.format = {};

    g.filetype = strtok(g.filetype);
    g.filetype = lower(g.filetype);
    g.filetype = 'loc';
    fprintf('readlocs(): ''%s'' format assumed from file extension\n', g.filetype); 

    g.format = { 'channum' 'theta' 'radius' 'labels' };
    g.skiplines = 0;

    array = load_file_or_array( filename, g.skiplines);

    % converting file
    % ---------------
    for indexcol = 1:min(size(array,2), length(g.format))
       [str ~] = checkformat(g.format{indexcol});
       for indexrow = 1:size( array, 1)
           eval ( [ 'eloc(indexrow).'  str '= array{indexrow, indexcol};' ]);
       end
    end

    % handling BESA coordinates
    % -------------------------
    eloc = convertlocs(eloc, 'topo2all');   %#ok<NODEF>

    % inserting labels if no labels
    % -----------------------------
    % remove trailing '.'
    for index = 1:length(eloc)
       if isstr(eloc(index).labels)
           tmpdots =  eloc(index).labels == '.' ;
           eloc(index).labels(tmpdots) = [];
       end
    end
end

% interpret the variable name
% ---------------------------
function array = load_file_or_array( varname, skiplines )
    array = loadtxt(varname,'verbose','off','skipline',skiplines,'blankcell','off');
end

% check field format
% ------------------
function [str, mult] = checkformat(str)
	mult = 1;
	if strcmpi(str, 'labels'),         str = lower(str); return; end;
	if strcmpi(str, 'channum'),        str = lower(str); return; end;
	if strcmpi(str, 'theta'),          str = lower(str); return; end;
	if strcmpi(str, 'radius'),         str = lower(str); return; end;
	if strcmpi(str, 'ignore'),         str = lower(str); return; end;
	if strcmpi(str, 'sph_theta'),      str = lower(str); return; end;
	if strcmpi(str, 'sph_phi'),        str = lower(str); return; end;
	if strcmpi(str, 'sph_radius'),     str = lower(str); return; end;
	if strcmpi(str, 'sph_theta_besa'), str = lower(str); return; end;
	if strcmpi(str, 'sph_phi_besa'),   str = lower(str); return; end;
	if strcmpi(str, 'gain'),           str = lower(str); return; end;
	if strcmpi(str, 'calib'),          str = lower(str); return; end;
	if strcmpi(str, 'type') ,          str = lower(str); return; end;
	if strcmpi(str, 'X'),              str = upper(str); return; end;
	if strcmpi(str, 'Y'),              str = upper(str); return; end;
	if strcmpi(str, 'Z'),              str = upper(str); return; end;
	if strcmpi(str, '-X'),             str = upper(str(2:end)); mult = -1; return; end;
	if strcmpi(str, '-Y'),             str = upper(str(2:end)); mult = -1; return; end;
	if strcmpi(str, '-Z'),             str = upper(str(2:end)); mult = -1; return; end;
	if strcmpi(str, 'custom1'), return; end;
	if strcmpi(str, 'custom2'), return; end;
	if strcmpi(str, 'custom3'), return; end;
	if strcmpi(str, 'custom4'), return; end;
    error(['readlocs(): undefined field ''' str '''']);
end   

function array = loadtxt( filename, varargin )
    g.convert = 'on';
    g.skipline = 0;
    g.verbose = 'off';
    g.uniformdelim = 'off';
    g.blankcell = 'off';
    g.delim = [9 32];
    g.nlines = Inf;
    
    if strcmpi(g.blankcell, 'off'), 
        g.uniformdelim = 'on'; 
    end;
    g.convert = lower(g.convert);
    g.verbose = lower(g.verbose);
    g.delim = char(g.delim);

    fid=fopen(filename,'r','ieee-le');

    inputline = fgetl(fid);
    linenb = 1;
    while isempty(inputline) | inputline~=-1
         colnb = 1;
         if ~isempty(inputline)
             tabFirstpos = 1;

             % convert all delimiter to the first one
             if strcmpi(g.uniformdelim, 'on')
                 for index = 2:length(g.delim)
                     inputline(inputline == g.delim(index)) = g.delim(1);
                 end;
             end;

             while ~isempty(deblank(inputline))
                 if strcmpi(g.blankcell,'off'), 
                     inputline = strtrim(inputline); 
                 end;
                 if tabFirstpos && length(inputline) > 1 && all(inputline(1) ~= g.delim), 
                     tabFirstpos = 0; 
                 end;
                 [tmp inputline tabFirstpos] = mystrtok(inputline, g.delim, tabFirstpos);
                 switch g.convert
                    case 'off', array{linenb, colnb} = tmp;
                    case 'on',  
                         tmp2 = str2double(tmp);
                         if isnan( tmp2 )  , array{linenb, colnb} = tmp;
                         else                array{linenb, colnb} = tmp2;
                         end;
                    case 'force', array{linenb, colnb} = str2double(tmp);
                 end;
                 colnb = colnb+1;
             end;
             linenb = linenb +1;
         end;
         inputline = fgetl(fid);
    end;        
    fclose(fid); 
end

% problem strtok do not consider tabulation
% -----------------------------------------
function [str, strout, tabFirstpos] = mystrtok(strin, delim, tabFirstpos)
    [str, strout] = strtok(strin, delim);
end

function chans = convertlocs(chans, command, varargin)
    % convert
    % -------         
    switch command
     case 'topo2sph',
       theta  = {chans.theta};
       radius = {chans.radius};
       indices = find(~cellfun('isempty', theta));
       [sph_phi sph_theta] = topo2sph( [ [ theta{indices} ]' [ radius{indices}]' ] );
       for index = 1:length(indices)
          chans(indices(index)).sph_theta  = sph_theta(index);
          chans(indices(index)).sph_phi    = sph_phi  (index);
       end;
       meanrad = 1;
       sph_radius(1:length(indices)) = {meanrad};
    case 'topo2all',
       chans = convertlocs(chans, 'topo2sph', varargin{:}); % search for spherical coords
       chans = convertlocs(chans, 'sph2sphbesa', varargin{:}); % search for spherical coords
       chans = convertlocs(chans, 'sph2cart', varargin{:}); % search for spherical coords
    case 'sph2cart',
       sph_theta  = {chans.sph_theta};
       sph_phi    = {chans.sph_phi};
       indices = find(~cellfun('isempty', sph_theta));
       sph_radius(1:length(indices)) = {1};
       inde = find(cellfun('isempty', sph_radius));
       [x y z] = sph2cart([ sph_theta{indices} ]'/180*pi, [ sph_phi{indices} ]'/180*pi, [ sph_radius{indices} ]');
       for index = 1:length(indices)
          chans(indices(index)).X = x(index);
          chans(indices(index)).Y = y(index);
          chans(indices(index)).Z = z(index);
       end;
    case 'sph2sphbesa',
       % using polar coordinates
       sph_theta  = {chans.sph_theta};
       sph_phi    = {chans.sph_phi};
       indices = find(~cellfun('isempty', sph_theta));
       [chan_num,angle,radius] = sph2topo([ones(length(indices),1)  [ sph_phi{indices} ]' [ sph_theta{indices} ]' ], 1, 2);
       [sph_theta_besa sph_phi_besa] = topo2sph([angle radius], 1, 1);
       for index = 1:length(indices)
          chans(indices(index)).sph_theta_besa  = sph_theta_besa(index);
          chans(indices(index)).sph_phi_besa    = sph_phi_besa(index);
       end;   
    end;
end

function [c, h] = topo2sph(eloc_locs,eloc_angles, method, unshrink)
    if nargin > 1 && ~isstr(eloc_angles)
        if nargin > 2
            unshrink = method;
        end;
        method = eloc_angles;
    else
        method = 2;
    end;

    E = eloc_locs;
    E = [ ones(size(E,1),1) E ];

    if method == 2
        t = E(:,2); % theta
        r = E(:,3); % radius
        h = -t;  % horizontal rotation
        c = (0.5-r)*180;
    else
        for e=1:size(E,1)
            % (t,r) -> (c,h)

            t = E(e,2); % theta
            r = E(e,3); % radius
            r = r*unshrink;
            if t>=0
                h(e) = 90-t; % horizontal rotation
            else
                h(e) = -(90+t);
            end
            if t~=0
                c(e) = sign(t)*180*r; % coronal rotation
            else
                c(e) = 180*r;
            end
        end;
        t = t';
        r = r';
    end;
end

function [channo,angle,radius] = sph2topo(input,factor, method)
    chans = size(input,1);
    angle = zeros(chans,1);
    radius = zeros(chans,1);

    channo = input(:,1);
    az = input(:,2);
    horiz = input(:,3);

    angle  = -horiz;
    radius = 0.5 - az/180;
end
