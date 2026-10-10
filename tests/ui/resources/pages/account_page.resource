*** Settings ***
Documentation     Page Object for the Azam Trading Store account page.
...
...               Clicks use the Click Safely keyword from common.resource.
Library           SeleniumLibrary
Resource          ../common.resource

*** Variables ***
${ACCOUNT_URL}              /account
${ACCOUNT_TITLE}            id=account-heading
${ACCOUNT_NAME}             xpath=//h1[@id='account-heading']
${ACCOUNT_EMAIL}            xpath=//dd[text()='store admin']/preceding-sibling::dt[text()='Email']/following-sibling::dd
${ACCOUNT_BASKET_COUNT}     id=account-basket-count
${ACCOUNT_BASKET_TOTAL}     id=account-basket-total
${ACCOUNT_LOGOUT}           id=account-logout
${ACCOUNT_SIGN_IN}          id=account-sign-in
${GUEST_TITLE}              id=guest-heading

*** Keywords ***
Go To Account Page
    [Documentation]    Navigate to /account and wait for the page to load.
    Go To    ${BASE_URL}${ACCOUNT_URL}
    Wait Until Page Contains Element    css=main#main

Account Page Should Show Name
    [Documentation]    Assert the account heading mentions the given name.
    [Arguments]    ${name}
    Wait Until Page Contains    ${name}    timeout=5s
    Wait Until Element Is Visible    ${ACCOUNT_TITLE}    timeout=5s

Account Basket Count Should Be
    [Documentation]    Assert the account page's basket count.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${ACCOUNT_BASKET_COUNT}    ${expected}    timeout=5s

Account Basket Total Should Be
    [Documentation]    Assert the account page's basket subtotal.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${ACCOUNT_BASKET_TOTAL}    ${expected}    timeout=5s

Guest State Should Be Visible
    [Documentation]    Assert the anonymous visitor sees the guest invitation.
    Wait Until Element Is Visible    ${GUEST_TITLE}    timeout=5s

Click Account Sign In
    [Documentation]    Click the guest state's "Sign the register" button.
    Click Safely    ${ACCOUNT_SIGN_IN}

Click Account Logout
    [Documentation]    Click the account page's "Sign out" button.
    Click Safely    ${ACCOUNT_LOGOUT}

Click Inbox Refresh
    [Documentation]    Click the "Load messages" button on the admin inbox.
    Click Safely    id=inbox-refresh

Inbox Should Show Message From
    [Documentation]    Assert the inbox contains a message from the given name.
    [Arguments]    ${name}
    Wait Until Element Contains    id=inbox-list    ${name}    timeout=5s
