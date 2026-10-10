*** Settings ***
Documentation     Page Object for the Azam Trading Store login dialog.
...
...               Every test that interacts with authentication must go
...               through this resource. If a selector changes, it changes
...               here once, not in every test case.
...
...               Clicks use the Click Safely keyword from common.resource,
...               which dispatches click events via JavaScript. This bypasses
...               a known Chrome headless coordinate bug that otherwise
...               intercepts WebDriver clicks.
Library           SeleniumLibrary
Resource          ../common.resource

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
    Click Safely    ${OPEN_LOGIN}
    Wait Until Element Is Visible    ${LOGIN_DIALOG}    timeout=5s

Close Login Dialog
    [Documentation]    Dismiss the modal via its close button.
    Click Safely    ${CLOSE_DIALOG}
    Wait Until Element Is Not Visible    ${LOGIN_DIALOG}    timeout=5s

Fill Login Form
    [Documentation]    Populate the email and password fields without
    ...                submitting.
    [Arguments]    ${email}    ${password}
    Input Text        ${LOGIN_EMAIL}       ${email}
    Input Password    ${LOGIN_PASSWORD}    ${password}

Submit Login Form
    [Documentation]    Click the submit button.
    Click Safely    ${LOGIN_BUTTON}

Sign In With Credentials
    [Documentation]    Complete login flow in one call.
    [Arguments]    ${email}    ${password}
    Open Login Dialog
    Fill Login Form    ${email}    ${password}
    Submit Login Form

Login State Should Contain
    [Documentation]    Assert the header auth badge contains the given text.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${LOGIN_STATE}    ${expected}    timeout=5s

Login Error Should Be Visible
    [Documentation]    Assert the inline error message is rendered.
    Wait Until Element Is Visible    ${LOGIN_ERROR}    timeout=5s

Login Error Should Contain
    [Documentation]    Assert the inline error message contains specific text.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${LOGIN_ERROR}    ${expected}    timeout=5s

Logout Should Be Visible
    [Documentation]    Assert the header "Sign out" button is visible.
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=5s

Logout Should Not Be Visible
    [Documentation]    Assert the header "Sign out" button is hidden.
    Wait Until Element Is Not Visible    ${LOGOUT_BUTTON}    timeout=5s

Logout
    [Documentation]    Click the header "Sign out" button.
    Click Safely    ${LOGOUT_BUTTON}
