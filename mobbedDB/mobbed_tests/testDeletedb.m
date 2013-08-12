function test_suite = testDeletedb %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'hostname', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);
try
    tStruct.DB = Mobbed(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, false);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    tStruct.DB = Mobbed(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, false);
end

% Function executed after each test
function teardown(~) %#ok<DEFNU>
try
    Mobbed.closeAll();
catch ME %#ok<NASGU>
end

function testNotExist(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for deleting a database that does not exists:\n');
fprintf(['It should throw an exception when deleting a database that' ...
    ' does not exist\n']);
fprintf(['--It should throw an exception and a database should not be' ...
    ' deleted\n'])
tStruct.DB.close();
Mobbed.deletedb(tStruct.name, tStruct.hostname, tStruct.user, ...
    tStruct.password, false);
assertExceptionThrown(...
    @() error(Mobbed.deletedb(tStruct.name, tStruct.hostname, ...
    tStruct.user, tStruct.password, false)), ...
    'MATLAB:maxlhs');
