% storeDataDbPar    wrapper for calling storeDataDb by worker threads
function [fUUIDs, tElapsed] = storedatadbpar(dbName, hostName,  ...
                      userName, password, fPaths, modality, dataType, uniqueEvents)
  tStart = tic;
  if ~isempty(fPaths)
     DB = Mobbed(dbName, hostName, userName, password, false);                            
     fUUIDs = storedatadb(DB, fPaths, modality, dataType, uniqueEvents);
     close(DB);
  end
  tElapsed = toc(tStart);
end