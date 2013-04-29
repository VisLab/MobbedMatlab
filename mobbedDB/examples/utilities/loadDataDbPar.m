function [fUUIDs, tElapsed] = loaddatadbpar(dbName, hostName,  ...
    userName, password, fUUIDs)
tStart = tic;
if ~isempty(fUUIDs)
    DB = Mobbed(dbName, hostName, userName, password, false);
    for k = 1:length(fUUIDs)
        smap.datamap_entity_uuid = fUUIDs{k};
        dmap = getdb(DB, 'datamaps', inf, smap);
        data = db2data(DB, dmap); %#ok<NASGU> % get the data
    end
    close(DB);
end
tElapsed = toc(tStart);
end