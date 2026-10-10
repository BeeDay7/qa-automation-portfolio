*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${LOGIN_EMAIL}       id=email
${LOGIN_PASSWORD}    id=password
${LOGIN_BUTTON}      id=login-submit
${OPEN_LOGIN}        id=open-login
${LOGOUT_BUTTON}     id=logout
${LOGIN_STATE}       id=login-state
${LOGIN_ERROR}       id=login-error

*** Keywords ***
Open Login Dialog
    Click Button    ${OPEN_LOGIN}

Sign In With Credentials
    [Arguments]    ${email}    ${password}
    Open Login Dialog
    Input Text        ${LOGIN_EMAIL}       ${email}
    Input Password    ${LOGIN_PASSWORD}    ${password}
    Click Button      ${LOGIN_BUTTON}
    Wait Until Element Is Not Visible    css=dialog[open]    timeout=5s

Login State Should Contain
    [Arguments]    ${expected}
    Wait Until Element Contains    ${LOGIN_STATE}    ${expected}    timeout=5s

Login Error Should Be Visible
    Wait Until Element Is Visible    ${LOGIN_ERROR}    timeout=5s

Logout Should Be Visible
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=5s

Logout Should Not Be Visible
    Wait Until Element Is Not Visible    ${LOGOUT_BUTTON}    timeout=5s
