*** Setting ***
Library    RequestsLibrary
Library    ExampleLibrary.py
Library    Collections
Library    String

*** Variables ***
#Moved common test variables to a single place
&{HEADERS}    x-api-key=DEMO-API-KEY
${BASE_URL}    https://api.thecatapi.com/v1

*** Test Cases ***
#I tried to make keyword definitions very close to original requriements (some BDD-style)
#Also tried to tie keyword names to API buisness logic and not just HTTP methods' names

First scenario
    ${response}    Get votes by /votes
    Save ${response.json()} as response_data
    ${response} has status 200
    ${response} body has more than 0 items

Second Scenario
    ${item}    Get random item from ${response_data}
    ${response}    Get votes by /votes/${item}[id]
    ${response} has status 200
    ${response} body is not empty
    ${response} fields match the corresponding fields in ${item}

Third scenario
    ${random_image_id}    Generate Random String
    ${response}    Post vote data    url=/votes
    ...                              image_id=${random_image_id}    sub_id=test_user    value=100
    ${response} has status 200
    ${response} has value SUCCESS in field message
    ${response} has field id
    Save ${response.json()}[id] as vote_id

Fourth scenario
    ${response}    Get votes by /votes/${vote_id}
    ${response} has status 200
    ${response} body is not empty
    ${response} has value ${vote_id} in field id

Fifth scenario
    ${response}    Delete vote by /votes/${vote_id}
    ${response} has status 200
    ${response} has value SUCCESS in field message

Sixth scenario
    ${response}    Get votes by /votes/${vote_id}
    ${response} has status 404
    ${response} has value NOT_FOUND in field message

*** Keywords ***
#I could also move these keywords to a Python file, but decided it will be overkill for this task
Get votes by ${url}
    ${response}    GET    ${BASE_URL}${url}    headers=${HEADERS}    expected_status=any
    [Return]    ${response}

Post vote data
    [Arguments]    ${url}    &{data}
    ${response}    POST    ${BASE_URL}${url}    headers=${HEADERS}    json=${data}
    [Return]    ${response}

Delete vote by ${url}
    ${response}    DELETE    ${BASE_URL}${url}    headers=${HEADERS}
    [Return]    ${response}

#With this keyword we can save data to a global variable to access it later
Save ${data} as ${alias}
    Set suite variable    $${alias}    ${data}

${response} has status ${status}
    Status Should Be    ${status}    ${response}

${response} body has more than ${count} items
    ${count}    Convert To Integer    ${count}
    ${length}    Get Length    ${response.json()}
    Log    ${response.json()}
    Log    ${length}
    Should Be True     ${length}>${count}

${response} body is not empty
    Should Not Be Empty    ${response.json()}

#The simpliest way to check that all fields and its values from reference match the fields in the actual response
#Note that in this case response can also have new fields which are not present in the reference - if this
# an undesired befavior, we should use "equals"
${response} fields match the corresponding fields in ${reference}
    Dictionary should contain sub dictionary    ${response.json()}    ${reference}

${response} has value ${value} in field ${field}
    Dictionary should contain item    ${response.json()}    ${field}    ${value}

${response} has field ${field}
    Dictionary should contain key    ${response.json()}    ${field}
