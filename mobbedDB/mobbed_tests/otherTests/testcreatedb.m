function test_suite = testcreatedb %#ok<STOUT>
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

function testNewDB(tStruct) %#ok<DEFNU>
fprintf('\nUnit test createdb function:\n');
fprintf('It should create a database that does not exist\n');
fprintf('An established connection should be made to the created database');
assertTrue(~isempty(tStruct.DB.getConnection()));

function testDBAlreadyExist(tStruct) %#ok<DEFNU>
fprintf('\nUnit test createdb function:\n');
fprintf('An exception should be thrown when creating a database that already exists');
assertExceptionThrown(...
    @() error(Mobbed.createdb(tStruct.name, tStruct.hostname, tStruct.user, ...
    tStruct.password, 'mobbed.sql', false)), 'MATLAB:maxlhs');