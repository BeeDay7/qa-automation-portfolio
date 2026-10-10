*** Settings ***
Documentation     Functional UI tests for the DemoMart storefront fixture.
...               Every test target is served locally; no external systems are
...               contacted. Self-directed portfolio work.
Resource          resources/common.resource
Resource          resources/pages/login_page.resource
Resource          resources/pages/products_page.resource
Resource          resources/pages/cart_page.resource
Suite Setup       Open Storefront
Suite Teardown    Close Storefront
Test Setup        Go To    ${BASE_URL}
Test Teardown     Run Keyword If Test Failed    Capture On Failure
Test Tags         ui    storefront    portfolio

*** Variables ***
${USERS_FILE}    tests/ui/data/users.yaml

*** Test Cases ***
DM-001 Valid Login Shows Signed In State
    [Documentation]    A registered user signing in with correct credentials
    ...                sees the signed-in indicator and logout control.
    [Tags]    smoke    priority-high
    ${users}=    Load Yaml File    ${USERS_FILE}
    ${u}=        Set Variable    ${users}[valid_user]
    Sign In With Credentials    ${u}[email]    ${u}[password]
    Login State Should Contain    Signed in
    Logout Should Be Visible

DM-002 Invalid Login Is Rejected
    [Documentation]    Wrong credentials display a visible error and do not
    ...                grant a session.
    [Tags]    smoke    negative    priority-high
    ${users}=    Load Yaml File    ${USERS_FILE}
    ${u}=        Set Variable    ${users}[invalid_user]
    Sign In With Credentials    ${u}[email]    ${u}[password]
    Login Error Should Be Visible
    Logout Should Not Be Visible

DM-003 Checkout Requires Authentication
    [Documentation]    Anonymous users cannot complete checkout.
    [Tags]    negative    priority-high
    Open Cart Drawer
    Click Checkout
    Checkout Message Should Contain    Please sign in before checkout.

DM-004 Adding A Product Updates Cart Total
    [Documentation]    Adding one Wireless Mouse updates the cart count to 1
    ...                and the total to 19.99.
    [Tags]    smoke    priority-high
    Add Product To Cart    Wireless Mouse
    Cart Count Should Be    1
    Cart Total Should Be    19.99

DM-005 Search Filters The Catalogue
    [Documentation]    Searching for a partial name hides non-matching cards.
    [Tags]    priority-medium
    Search For Product    USB-C
    Product Card Should Be Visible        USB-C Hub
    Product Card Should Not Be Visible    Wireless Mouse

DM-006 Out-Of-Stock Product Is Not Addable
    [Documentation]    A product with zero stock shows a disabled button.
    [Tags]    negative    priority-medium
    Page Should Contain Element    xpath=//li[@data-name='Mechanical Keyboard']//button[@disabled]
