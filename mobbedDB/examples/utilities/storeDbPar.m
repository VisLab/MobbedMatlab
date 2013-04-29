% storeDbPar       wrapper to call storeDb by an independent worker thread
function [fUUIDs, uniqueEvents, tElapsed] = storedbpar(dbName, hostName, ...
                                  userName, password, fPaths, modality, ...
                                  nameSpace, dataName, uniqueEvents)
  tStart = tic;
  fUUIDs = {};
  if ~isempty(fPaths)
     DB = Mobbed(dbName, hostName, userName, password, false);                            
     [fUUIDs, uniqueEvents] = storedb(DB, fPaths, modality, ...
                                      nameSpace, dataName, uniqueEvents);
     close(DB);
  end
  tElapsed = toc(tStart);
end