% storeDataDbPar    wrapper for calling storeDataDb by worker threads
function [fUUIDs, tElapsed] = storeDataDbPar(dbName, hostName,  ...
                      userName, password, fPaths, modality, dataType, uniqueEvents)
  tStart = tic;
  if ~isempty(fPaths)
     DB = Mobbed(dbName, hostName, userName, password, false);                            
     fUUIDs = storeDataDb(DB, fPaths, modality, dataType, uniqueEvents);
     close(DB);
  end
  tElapsed = toc(tStart);
end