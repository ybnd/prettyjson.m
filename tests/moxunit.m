function test_suite=moxunit
    try 
        % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch 
        % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function assert_parsing(ugly, description)
    function indent_disp(value, indent=1)
        lines = strsplit(value, '\n');
        for i =  1:length(lines)
            fprintf('%s%s\n', repmat('  ', 1, indent), lines{i});
        end
    end

    fprintf('\n%s\n', description);
    indent_disp(ugly);

    pretty = prettyjson(ugly);
    indent_disp(pretty);

    assert(isequal(jsondecode(ugly), jsondecode(pretty)), 'Prettified JSON does not parse correctly!')
end

function test_basics
    assert_parsing(
        '{}',
        'Empty object (results in a redundant newline, but also not that important)'
    );
    assert_parsing(
        '{"a":"b"}', 
        'Object w/ string property'
    );
    assert_parsing(
        '{"a":123}', 
        'Object w/ number property'
    );
    assert_parsing(
        '{"a":null}', 
        'Object w/ null property'
    );
    assert_parsing(
        '{"a":{"b":{"c":{"d":{}}}}}', 
        'Nested objects'
    );
end

function test_arrays
    assert_parsing(
        '[]',
        'Empty array'
    );
    assert_parsing(
        '[1,2,3,4,5,6,7,8,9,10]',
        'Short 1d array'
    );
    assert_parsing(  % todo: this doesn't look right!
        '["first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth"]',
        'Long 1d array'
    );
    assert_parsing(
        '[[1,2],[3,4],[5,6],[7,8],[9,10]]',
        'Short 2d array'
    );
    assert_parsing(  % todo: this doesn't look right!
        '[["first","second"],["third","fourth"],["fifth","sixth"],["seventh","eighth"],["ninth","tenth"]]',
        'Long 2d array w/ short subarrays'
    );
        assert_parsing(  % todo: this doesn't look right!
        '[["first","second","third","fourth","fifth"],["sixth","seventh","eighth","ninth","tenth"]]',
        'Short 2d array w/ long subarrays'
    );
    assert_parsing(
        '{"a":[1,2,3,4,5,6,7,8,9,10]}', 
        'Object w/ short 1d array property'
    );
    assert_parsing(
        '{"a":["first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth"]}', 
        'Object w/ long 1d array property'
    );
    assert_parsing(
        '{"a":[[1,2],[3,4],[5,6],[7,8],[9,10]]}', 
        'Object w/ short 2d array property'
    );
    assert_parsing(  % todo: this doesn't look right!
        '{"a":[["first","second"],["third","fourth"],["fifth","sixth"],["seventh","eighth"],["ninth","tenth"]]}', 
        'Object w/ long 2d array property'
    );
end

function test_problematic_characters_in_strings
    assert_parsing(
        '{"a": ":stuff:"}',
        'Colons in strings'
    );
    assert_parsing(
        '{"a": "[[[stuff]]]"}',
        'Brackets'
    );

    % todo: currently, no distinction is made between "JSON braces/brackets" & braces/brackets within strings, so the following cases get mangled, resulting in invalid JSON
    % assert_parsing(
    %     '{"a": "[short arrays are kept on one line for readability, this one has way more stuff so that it triggers array splitting/indentation]"}',
    %     'Brackets w/ long contents'
    % );
    % assert_parsing(
    %     '{"a": "{{{stuff}}}"}',
    %     'Braces'
    % );
    % assert_parsing(
    %     '{"a": "{[{[{stuff}]}]}"}',
    %     'Braces & brackets'
    % );
    % assert_parsing(
    %     '{"a": "{{{stuff]]]"}',
    %     'Unbalanced braces & brackets'
    % );
end