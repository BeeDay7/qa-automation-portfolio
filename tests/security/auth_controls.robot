*** Settings ***
Documentation     UI- and API-level authentication-control checks against the
...               SecurePortal fixture. This suite verifies user-facing
...               behaviour and one server-side role boundary. It is NOT a
...               penetration test; see docs/LIMITATIONS.md.
...
...               UI clicks use Click Safely from the shared resources. This
...               bypasses a Chrome headless coordinate bug that otherwise
...               intercepts WebDriver clicks on positioned elements.
Library           SeleniumLibrary
Library           RequestsLibrary
Library           Collections
Resource          ../ui/resources/common.resource
Suite Setup       Open Secure Portal
Suite Teardown    Close All Browsers
Test Setup        Go To    ${SECURE_URL}
Test Tags         security    auth    portfolio

*** Variables ***
${SECURE_URL}        http://127.0.0.1:8002
${ADMIN_USER}        qa_admin
${ADMIN_PASS}        LocalOnly!234
${VIEWER_USER}       qa_viewer
${VIEWER_PASS}       ViewerOnly!234
${BAD_USER}          attacker
${BAD_PASS}          wrong-password
${CHROME_OPTIONS}    add_argument("--headless=new");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080")

*** Test Cases ***
SEC-001 Invalid Credentials Are Rejected In UI
    [Documentation]    Submitting bad credentials shows a failure message and
    ...                does not navigate to the dashboard.
    [Tags]    smoke    negative    priority-high
    Input Text        id=username    ${BAD_USER}
    Input Password    id=password    ${BAD_PASS}
    Click Safely      id=signin
    Wait Until Element Contains    id=result    Authentication failed    timeout=5s
    Location Should Be    ${SECURE_URL}/

SEC-002 Admin Login Succeeds
    [Documentation]    A valid admin session is redirected to /dashboard and
    ...                the session badge reports the admin role.
    [Tags]    smoke    priority-high
    Input Text        id=username    ${ADMIN_USER}
    Input Password    id=password    ${ADMIN_PASS}
    Click Safely      id=signin
    Wait Until Location Contains    /dashboard    timeout=5s
    Wait Until Element Contains    id=session-badge    admin    timeout=5s

SEC-003 Viewer Login Succeeds But Lacks Admin Role
    [Documentation]    A viewer authenticates but receives HTTP 403 when
    ...                calling the admin API.
    [Tags]    priority-high
    Create Session    viewer    ${SECURE_URL}    verify=False
    ${login}=    POST On Session    viewer    /api/login
    ...    json=${{ {"username": "${VIEWER_USER}", "password": "${VIEWER_PASS}"} }}
    ...    expected_status=200
    ${resp}=    GET On Session    viewer    /api/admin/records    expected_status=403
    Should Be Equal    ${resp.json()}[error]    forbidden

SEC-004 Anonymous Access To Admin API Is Forbidden
    [Documentation]    No session means the admin endpoint refuses the call.
    [Tags]    smoke    negative    priority-high
    Create Session    anon    ${SECURE_URL}    verify=False
    ${resp}=    GET On Session    anon    /api/admin/records    expected_status=403
    Should Be Equal    ${resp.json()}[error]    forbidden

SEC-005 Admin API Succeeds For Admin Session
    [Documentation]    A server-side admin session receives HTTP 200 and the
    ...                expected record count.
    [Tags]    smoke    priority-high
    Create Session    admin    ${SECURE_URL}    verify=False
    ${login}=    POST On Session    admin    /api/login
    ...    json=${{ {"username": "${ADMIN_USER}", "password": "${ADMIN_PASS}"} }}
    ...    expected_status=200
    ${resp}=    GET On Session    admin    /api/admin/records    expected_status=200
    Should Be Equal As Integers    ${resp.json()}[count]    2

*** Keywords ***
Open Secure Portal
    Open Browser    ${SECURE_URL}    chrome    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Set Selenium Implicit Wait    5s
    Wait Until Element Is Visible    id=signin    timeout=5s
