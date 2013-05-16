function test_suite = testGenericTestClass %#ok<STOUT>
initTestSuite;


function testNormalConstructorOnlyElements %#ok<DEFNU>
% Unit test for genericTestClass normal constructor only elements
fprintf('\nUnit test for genericTestClass constructor with only elements:\n');

fprintf('It should create a valid object with only elements\n');
g = genericTestClass(5, 0, [], 0, 0);
assertTrue(isvalid(g));
fprintf('--The object data should only have an element field\n');
assertEqual(1, length(fieldnames(g.data)));
assertTrue(isfield(g.data, 'element'));

fprintf('The object should have the right number of elements\n');
assertEqual(5, length(g.data.element));
fprintf('--The elements should have the right number of fields\n');
assertEqual(3, length(fieldnames(g.data.element)));

g1 = genericTestClass(5, 0, [], 0, 3);
fprintf('--The object should have the correct number of extra fields\n');
assertTrue(isfield(g1.data, 'element'));
assertTrue(~isfield(g1.data, 'event'));
a = g1.data.element;
assertEqual(length(a), 5);
assertEqual(length(fieldnames(a)), 6);

function testNormalConstructorElementsAndEvents %#ok<DEFNU>
% Unit test for genericTestClass normal constructor for elements and events
fprintf('\nUnit test for genericTestClass constructor with elements and events:\n');

fprintf('It should create a valid object with elements and events\n');
g2 = genericTestClass(5, 4, [], 0, 3);
assertTrue(isvalid(g2));
fprintf('--The object should have the correct number of extra fields\n');
assertTrue(isfield(g2.data, 'element'));
assertTrue(isfield(g2.data, 'event'));
a = g2.data.event;
assertEqual(length(a), 4);
assertEqual(length(fieldnames(a)), 8);

function testNormalConstructorElementsEventsAndMetadata %#ok<DEFNU>
% Unit test for genericTestClass normal constructor: elements, events, metdata
fprintf('\nUnit test for genericTestClass constructor with elements, events and metadata:\n');

fprintf('It should create a valid object with elements, events and metadata\n');
g = genericTestClass(5, 4, [], 2, 3);
assertTrue(isvalid(g));
fprintf('--The object should have the correct number of fields\n');
assertTrue(isfield(g.data, 'element'));
assertTrue(isfield(g.data, 'event'));
assertTrue(isfield(g.data, 'metadata'));
a = g.data.metadata;
assertEqual(length(fieldnames(a)), 3);
