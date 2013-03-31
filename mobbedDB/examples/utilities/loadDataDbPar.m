function [fUUIDs, tElapsed] = loadDataDbPar(dbName, hostName,  ...
    userName, password, fUUIDs)
tStart = tic;
if ~isempty(fUUIDs)
    DB = Mobbed(dbName, hostName, userName, password, false);
    for k = 1:length(fUUIDs)
        smap.data_map_entity_uuid = fUUIDs{k};
        dmap = getdb(DB, 'data_maps', inf, smap);
        data = db2data(DB, dmap.data_map_def_uuid); %#ok<NASGU> % get the data
    end
    close(DB);
end
tElapsed = toc(tStart);
end