%% Publish the documentation in this directory
%


%% Set up for the scripts:
baseDirectory = pwd;
publish_options.outputDir = baseDirectory;
publish_options.maxHeight = 300;
scriptNames = {'mobbed_features', ...
               'mobbed_functions_by_cat', ...
               'mobbed_product_page', ...
               'mobbed_getting_started', ...
               'mobbed_release_notes', ...
               'mobbed_system_requirements', ...
               'mobbed_user_guide'};

for k = 1:length(scriptNames)
   publish([scriptNames{k} '.m'], publish_options);
end
close all
clear all

%% Publish the function scripts
baseDirectory = pwd;
publish_options.outputDir = baseDirectory;
publish_options.maxHeight = 300;
topLevelScripts = { ...
              'data2db_help', ...
              'mat2db_help', ...
              };
          
for k = 1:length(topLevelScripts)
   publish([topLevelScripts{k} '.m'], publish_options);
end
close all
clear all

