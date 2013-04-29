% loadDbPar       wrapper to allow db2mat to be called by worker threads
function [fUUIDs, tElapsed] = loaddbpar(dbName, hostName,  ...
                              userName, password, fUUIDs)
  tStart = tic;
  if ~isempty(fUUIDs)
      DB = Mobbed(dbName, hostName, userName, password, false);
      for k = 1:length(fUUIDs)
          dataset = db2mat(DB, fUUIDs{k});  %#ok<NASGU>
          % Do stuff to this dataset
      end
      close(DB);
  end
  tElapsed = toc(tStart);
end