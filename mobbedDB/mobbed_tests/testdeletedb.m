function test_suite = testdeletedb %#ok<STOUT>
initTestSuite;

function tStruct = setup %#ok<DEFNU>
tStruct = struct('name', 'testdb', 'hostname', 'localhost', ...
    'user', 'postgres', 'password', 'admin', 'DB', []);
try
    tStruct.DB = Mobbed(tStruct.name, tStruct.hostname, tStruct.user, tStruct.password);
catch ME %#ok<NASGU>
    Mobbed.createdb(tStruct.name, tStruct.hostname, tStruct.user, ...
        tStruct.password, 'mobbed.sql', false);
    tStruct.DB = Mobbed(tStruct.name, tStruct.hostname, tStruct.user, tStruct.password);
end

function teardown(tStruct) %#ok<DEFNU>
% Function executed after each test
try
    tStruct.DB.close();
catch ME %#ok<NASGU>
end

function testExisitingDB(tStruct) %#ok<DEFNU>
fprintf('\nUnit test createdb function:\n');
fprintf('It should delete a database that already exists\n');
tStruct.DB.close();
Mobbed.deletedb(tStruct.name, tStruct.hostname, tStruct.user, ...
    tStruct.password);

function testDBDoesNotExist(tStruct) %#ok<DEFNU>
fprintf('\nUnit test createdb function:\n');
fprintf('An exception should be thrown when deleting a database that does not exist');
assertExceptionThrown(...
    @() error(Mobbed.createdb(tStruct.name, tStruct.hostname, tStruct.user, ...
    tStruct.password, 'mobbed.sql', false)), 'MATLAB:maxlhs');