*** Settings ***
Documentation     Contract and regression tests against the mock product API.
Library           RequestsLibrary
Library           Collections
Suite Setup       Create API Session
Test Tags         api    regression    portfolio

*** Variables ***
${API_URL}    http://127.0.0.1:8003

*** Test Cases ***
API-001 Health Endpoint Reports Ok
    [Documentation]    /health returns 200 and status=ok.
    [Tags]    smoke    priority-high
    ${resp}=    GET On Session    api    /health    expected_status=200
    Should Be Equal    ${resp.json()}[status]    ok
    Should Be Equal    ${resp.json()}[version]    1.0.0

API-002 List Returns All Products
    [Documentation]    The list endpoint returns every product in the catalogue.
    [Tags]    smoke    priority-high
    ${resp}=    GET On Session    api    /api/v1/products    expected_status=200
    ${body}=    Set Variable    ${resp.json()}
    Should Be Equal As Integers    ${body}[count]    4
    ${first}=    Set Variable    ${body}[items][0]
    Should Be Equal As Integers    ${first}[id]    1
    Should Be Equal    ${first}[name]    Wireless Mouse

API-003 Filter By In-Stock Returns Subset
    [Documentation]    in_stock=true filters out the out-of-stock item.
    [Tags]    priority-medium
    ${resp}=    GET On Session    api    /api/v1/products    params=in_stock=true    expected_status=200
    ${body}=    Set Variable    ${resp.json()}
    Should Be Equal As Integers    ${body}[count]    3
    FOR    ${item}    IN    @{body}[items]
        Should Be True    ${item}[stock] > 0
    END

API-004 Filter By Category Works
    [Documentation]    category filter returns only matching products.
    [Tags]    priority-medium
    ${resp}=    GET On Session    api    /api/v1/products    params=category=Accessories    expected_status=200
    ${body}=    Set Variable    ${resp.json()}
    Should Be Equal As Integers    ${body}[count]    2

API-005 Product Detail Matches Contract
    [Documentation]    Individual product response matches the expected schema.
    [Tags]    smoke    priority-high
    ${resp}=    GET On Session    api    /api/v1/products/1    expected_status=200
    ${body}=    Set Variable    ${resp.json()}
    Should Be Equal    ${body}[name]    Wireless Mouse
    Should Be Equal As Numbers    ${body}[price]    19.99
    Should Be Equal    ${body}[sku]    WM-001

API-006 Unknown Product Returns 404
    [Documentation]    Unknown product IDs produce a structured 404.
    [Tags]    smoke    negative    priority-high
    ${resp}=    GET On Session    api    /api/v1/products/9999    expected_status=404
    Should Be Equal    ${resp.json()}[detail]    not_found

API-007 Invalid Path Returns 404
    [Documentation]    Unknown paths produce 404, not 500.
    [Tags]    negative    priority-medium
    GET On Session    api    /api/v1/nonexistent    expected_status=404

*** Keywords ***
Create API Session
    Create Session    api    ${API_URL}    verify=False
