function test_suite = testCreatedb %#ok<STOUT>
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
    Mobbed.closeall();
catch ME %#ok<NASGU>
end

function testAlreadyExist(tStruct) %#ok<DEFNU>
fprintf('\nUnit test for creating a database that already exits\n');
fprintf(['--It should throw an exception and a database should not be' ...
    ' created\n'])
assertExceptionThrown(...
    @() error(Mobbed.createdb(tStruct.name, tStruct.hostname, ...
    tStruct.user, tStruct.password, 'mobbed.sql', false)), ...
    'MATLAB:maxlhs');
