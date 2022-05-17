*** Setting ***
Library    RequestsLibrary
Library    ExampleLibrary.py
Library    Collections
Library    String

*** Variables ***
&{HEADERS}    x-api-key=DEMO-API-KEY
${BASE_URL}    https://api.thecatapi.com/v1

*** Test Cases ***
First scenario
    ${response}    Send request to ${BASE_URL}/votes and save response
    ${response} has status 200
    ${response} body has more than 0 items
    Set suite variable    $response_data    ${response.json()}

Second Scenario
    ${item}    Get random item from ${RESPONSE_DATA}
    ${id}    Set Variable    ${item}[id]
    ${response}    Send request to ${BASE_URL}/votes/${id} and save response
    ${response} has status 200
    ${response} body is not empty
    Dictionary should contain sub dictionary    ${response.json()}    ${item}

Third scenario
    ${random_image_id}    Generate Random String
    ${response}    Post data and save response    url=${BASE_URL}/votes
    ...                                           image_id=${random_image_id}    sub_id=test_user    value=100
    ${response} has status 200
    Dictionary should contain item    ${response.json()}    message    SUCCESS
    Dictionary should contain key    ${response.json()}    id
    Set Suite Variable    $vote_id    ${response.json()}[id]

Fourth scenario
    ${response}    Send request to ${BASE_URL}/votes/${vote_id} and save response
    ${response} has status 200
    ${response} body is not empty
    Dictionary should contain item    ${response.json()}    id    ${vote_id}

Fifth scenario
    ${response}    DELETE    ${BASE_URL}/votes/${vote_id}    headers=${HEADERS}
    ${response} has status 200
    Dictionary should contain item    ${response.json()}    message    SUCCESS

Sixth scenario
    ${response}    Send request to ${BASE_URL}/votes/${vote_id} and save response
    ${response} has status 404
    Dictionary should contain item    ${response.json()}    message    NOT_FOUND


*** Keywords ***
Send request to ${url} and save response
    ${response}    GET    ${url}    headers=${HEADERS}    expected_status=any
    [Return]    ${response}

Post data and save response
    [Arguments]    ${url}    &{data}
    ${response}    POST    ${url}    headers=${HEADERS}    json=${data}
    [Return]    ${response}

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

