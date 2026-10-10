*** Settings ***
Documentation     Page Object for the Azam Trading Store login dialog.
...
...               Every test that interacts with authentication must go
...               through this resource. If a selector changes, it changes
...               here once, not in every test case.
Library    SeleniumLibrary

*** Variables ***
${LOGIN_DIALOG}      id=login-dialog
${OPEN_LOGIN}        id=open-login
${LOGIN_EMAIL}       id=email
${LOGIN_PASSWORD}    id=password
${LOGIN_BUTTON}      id=login-submit
${LOGIN_ERROR}       id=login-error
${LOGIN_STATE}       id=login-state
${LOGOUT_BUTTON}     id=logout
${CLOSE_DIALOG}      css=dialog#login-dialog button[data-close]

*** Keywords ***
Open Login Dialog
    [Documentation]    Click the header "Sign in" button and wait for the
    ...                modal to appear.
    Click Button    ${OPEN_LOGIN}
    Wait Until Element Is Visible    ${LOGIN_DIALOG}    timeout=5s

Close Login Dialog
    [Documentation]    Dismiss the modal via its close button. Used to verify
    ...                the dialog can be abandoned without triggering a login.
    Click Element    ${CLOSE_DIALOG}
    Wait Until Element Is Not Visible    ${LOGIN_DIALOG}    timeout=5s

Fill Login Form
    [Documentation]    Populate the email and password fields without
    ...                submitting. Separated from submission so tests can
    ...                inspect field state before triggering a request.
    [Arguments]    ${email}    ${password}
    Input Text        ${LOGIN_EMAIL}       ${email}
    Input Password    ${LOGIN_PASSWORD}    ${password}

Submit Login Form
    [Documentation]    Click the submit button. Does not wait for the outcome —
    ...                callers assert the result they expect.
    Click Button    ${LOGIN_BUTTON}

Sign In With Credentials
    [Documentation]    Complete login flow in one call. On invalid credentials
    ...                the dialog deliberately remains open so the user can
    ...                retry, so negative tests should call Open/Fill/Submit
    ...                directly instead.
    [Arguments]    ${email}    ${password}
    Open Login Dialog
    Fill Login Form    ${email}    ${password}
    Submit Login Form

Login State Should Contain
    [Documentation]    Assert the header auth badge contains the given text.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${LOGIN_STATE}    ${expected}    timeout=5s

Login Error Should Be Visible
    [Documentation]    Assert the inline error message is rendered after a
    ...                failed login attempt.
    Wait Until Element Is Visible    ${LOGIN_ERROR}    timeout=5s

Login Error Should Contain
    [Documentation]    Assert the inline error message contains specific text.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${LOGIN_ERROR}    ${expected}    timeout=5s

Logout Should Be Visible
    [Documentation]    Assert the header "Sign out" button is visible — i.e.
    ...                the current session is authenticated.
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=5s

Logout Should Not Be Visible
    [Documentation]    Assert the header "Sign out" button is hidden — i.e.
    ...                the current session is anonymous.
    Wait Until Element Is Not Visible    ${LOGOUT_BUTTON}    timeout=5s

Logout
    [Documentation]    Click the header "Sign out" button.
    Click Button    ${LOGOUT_BUTTON}
