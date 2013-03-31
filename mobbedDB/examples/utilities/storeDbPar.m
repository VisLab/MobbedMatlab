% storeDbPar       wrapper to call storeDb by an independent worker thread
function [fUUIDs, uniqueEvents, tElapsed] = storeDbPar(dbName, hostName, ...
                                  userName, password, fPaths, modality, ...
                                  nameSpace, dataName, uniqueEvents)
  tStart = tic;
  fUUIDs = {};
  if ~isempty(fPaths)
     DB = Mobbed(dbName, hostName, userName, password, false);                            
     [fUUIDs, uniqueEvents] = storeDb(DB, fPaths, modality, ...
                                      nameSpace, dataName, uniqueEvents);
     close(DB);
  end
  tElapsed = toc(tStart);
end