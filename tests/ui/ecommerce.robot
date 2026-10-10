*** Settings ***
Documentation     Functional UI test suite for the Azam Trading Store
...               storefront.
...
...               Scope: browser-driven functional tests against a locally
...               hosted FastAPI fixture. Every interaction is initiated by
...               Selenium against http://127.0.0.1:8001.
...
...               Test isolation: Reset Storefront Session runs before every
...               test, clearing all cookies and storage so that no test
...               depends on or contaminates another.
...
...               Evidence: failures trigger an automatic screenshot into
...               evidence/screenshots/. Robot-native report.html, log.html,
...               and output.xml are written to evidence/ui/.
...
...               Status: self-directed portfolio work.
Resource          resources/common.resource
Resource          resources/pages/login_page.resource
Resource          resources/pages/products_page.resource
Resource          resources/pages/cart_page.resource
Suite Setup       Open Storefront
Suite Teardown    Close Storefront
Test Setup        Reset Storefront Session
Test Teardown     Run Keyword If Test Failed    Capture On Failure
Test Tags         ui    storefront    portfolio

*** Variables ***
${USERS_FILE}    tests/ui/data/users.yaml

*** Test Cases ***
DM-001 Valid Login Shows Signed In State
    [Documentation]    A registered user signing in with correct credentials
    ...                sees the signed-in indicator and the logout control.
    [Tags]    smoke    functional    priority-high    auth
    ${users}=    Load Yaml File    ${USERS_FILE}
    ${u}=        Set Variable    ${users}[valid_user]
    Sign In With Credentials    ${u}[email]    ${u}[password]
    Login State Should Contain    Signed in
    Logout Should Be Visible

DM-002 Invalid Login Is Rejected
    [Documentation]    Wrong credentials display a visible error and do not
    ...                grant a session. The dialog remains open by design so
    ...                the user can retry.
    [Tags]    smoke    negative    priority-high    auth
    ${users}=    Load Yaml File    ${USERS_FILE}
    ${u}=        Set Variable    ${users}[invalid_user]
    Open Login Dialog
    Fill Login Form    ${u}[email]    ${u}[password]
    Submit Login Form
    Login Error Should Be Visible
    Logout Should Not Be Visible

DM-003 Login Dialog Can Be Dismissed
    [Documentation]    The user can open the login modal and close it without
    ...                submitting anything. No session should be established.
    [Tags]    functional    priority-medium    auth
    Open Login Dialog
    Close Login Dialog
    Login State Should Contain    Signed out
    Logout Should Not Be Visible

DM-004 Checkout Requires Authentication
    [Documentation]    An anonymous user who attempts to check out receives
    ...                an explicit sign-in prompt.
    [Tags]    negative    priority-high    cart
    Open Cart Drawer
    Click Checkout
    Checkout Message Should Contain    Please sign in before checkout.

DM-005 Adding A Product Updates Cart Total
    [Documentation]    Adding one Wireless Mouse ($19.99) updates both the
    ...                header badge and the drawer total.
    [Tags]    smoke    functional    priority-high    cart
    Add Product To Cart    Wireless Mouse
    Cart Count Should Be    1
    Open Cart Drawer
    Cart Total Should Be    19.99

DM-006 Cart Accumulates Multiple Distinct Products
    [Documentation]    Adding two different products shows count=2 and the
    ...                correct combined total ($19.99 + $34.50 = $54.49).
    [Tags]    functional    priority-high    cart
    Add Product To Cart    Wireless Mouse
    Add Product To Cart    USB-C Hub
    Cart Count Should Be    2
    Open Cart Drawer
    Cart Total Should Be    54.49

DM-007 Search Filters The Catalogue
    [Documentation]    A partial-name search shows only matching product
    ...                cards and hides non-matching ones.
    [Tags]    functional    priority-medium    search
    Search For Product    USB-C
    Product Card Should Be Visible        USB-C Hub
    Product Card Should Not Be Visible    Wireless Mouse

DM-008 Empty Search Shows Empty State
    [Documentation]    A search that matches nothing displays the empty-state
    ...                message rather than an empty list.
    [Tags]    negative    priority-medium    search
    Search For Product    zzz-no-such-product-zzz
    Empty State Should Be Visible
    Product Card Should Not Be Visible    Wireless Mouse

DM-009 Out-Of-Stock Product Is Not Addable
    [Documentation]    A product with zero stock renders a disabled Add-to-cart
    ...                button.
    [Tags]    negative    priority-medium    catalogue
    Page Should Contain Element    xpath=//li[@data-name='Mechanical Keyboard']//button[@disabled]

DM-010 Logout Clears Session And Cart
    [Documentation]    After signing in and adding an item, logging out resets
    ...                both the session and the cart.
    [Tags]    functional    priority-high    auth    cart
    ${users}=    Load Yaml File    ${USERS_FILE}
    ${u}=        Set Variable    ${users}[valid_user]
    Sign In With Credentials    ${u}[email]    ${u}[password]
    Logout Should Be Visible
    Add Product To Cart    Wireless Mouse
    Cart Count Should Be    1
    Logout
    Logout Should Not Be Visible
    Login State Should Contain    Signed out

DM-011 Cart Persists Across Page Reload
    [Documentation]    Cart state is stored server-side in a signed session
    ...                cookie. Reloading the page must preserve it.
    [Tags]    functional    priority-medium    cart
    Add Product To Cart    USB-C Hub
    Cart Count Should Be    1
    Reload Storefront
    Cart Count Should Be    1
    Open Cart Drawer
    Cart Total Should Be    34.50
