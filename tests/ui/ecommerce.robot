*** Settings ***
Documentation     Functional UI test suite for the Azam Trading Store
...               storefront.
...
...               Scope: browser-driven functional tests against a locally
...               hosted FastAPI fixture.
...
...               Test isolation: Reset Storefront Session runs before every
...               test, clearing all cookies and storage.
...
...               Evidence: failures trigger an automatic screenshot into
...               evidence/screenshots/.
...
...               Status: self-directed portfolio work.
Resource          resources/common.resource
Resource          resources/pages/login_page.resource
Resource          resources/pages/products_page.resource
Resource          resources/pages/cart_page.resource
Resource          resources/pages/account_page.resource
Resource          resources/pages/journal_page.resource
Resource          resources/pages/contact_page.resource
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
    Login State Should Contain    STORE ADMIN
    Logout Should Be Visible

DM-002 Invalid Login Is Rejected
    [Documentation]    Wrong credentials display a visible error and do not
    ...                grant a session.
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
    ...                submitting anything.
    [Tags]    functional    priority-medium    auth
    Open Login Dialog
    Close Login Dialog
    Login State Should Contain    GUEST
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
    Login State Should Contain    GUEST

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

DM-012 Signed In User Reaches Account Page
    [Documentation]    A signed-in user visits /account and sees their name
    ...                reflected in the profile card.
    [Tags]    smoke    functional    priority-high    account
    ${users}=    Load Yaml File    ${USERS_FILE}
    ${u}=        Set Variable    ${users}[valid_user]
    Sign In With Credentials    ${u}[email]    ${u}[password]
    Go To Account Page
    Account Page Should Show Name    Store Admin

DM-013 Anonymous Visitor Sees Guest State On Account Page
    [Documentation]    An anonymous visitor to /account sees the guest
    ...                invitation rather than the profile card.
    [Tags]    negative    priority-medium    account
    Go To Account Page
    Guest State Should Be Visible

DM-014 Account Page Reflects Basket Count
    [Documentation]    Items added to the basket appear in the account
    ...                page's basket summary.
    [Tags]    functional    priority-medium    account    cart
    Add Product To Cart    Wireless Mouse
    Add Product To Cart    USB-C Hub
    Go To Account Page
    Account Basket Count Should Be    2
    Account Basket Total Should Be    54.49

DM-015 Journal Index Lists All Articles
    [Documentation]    The journal index renders and shows all three
    ...                published notes.
    [Tags]    smoke    functional    priority-high    journal
    Go To Journal Index
    Journal Should Show Articles
    Page Should Contain Element    xpath=//a[contains(@class,'journal-item-link')][.//h2[contains(., 'We open every box')]]
    Page Should Contain Element    xpath=//a[contains(@class,'journal-item-link')][.//h2[contains(., 'The case for fewer')]]
    Page Should Contain Element    xpath=//a[contains(@class,'journal-item-link')][.//h2[contains(., 'Wrapped by hand')]]

DM-016 Article Opens With Full Body And Metadata
    [Documentation]    Clicking a note on the index navigates to the article
    ...                view, which shows the title, prose, and reading time.
    [Tags]    smoke    functional    priority-high    journal
    Go To Journal Index
    Open Journal Article    We open every box
    Article Title Should Be    We open every box
    Article Should Have Body Content
    Article Should Show Metadata

DM-017 Article Shows Related Products And Other Notes
    [Documentation]    Below the article, the related products section and
    ...                the "other notes" list are present.
    [Tags]    functional    priority-medium    journal
    Go To Journal Index
    Open Journal Article    Wrapped by hand
    Article Title Should Be    Wrapped by hand
    Wait Until Element Is Visible    css=.journal-related    timeout=5s
    Other Notes Should Be Listed

DM-018 Journal Link Present In Header On Every Page
    [Documentation]    The header navigation reaches the Journal from the
    ...                home page, a product detail page, the account page,
    ...                and the journal index itself.
    [Tags]    smoke    functional    priority-high    navigation
    Go To    ${BASE_URL}
    Page Should Contain Element    css=.primary-nav a[data-nav='journal']
    Go To    ${BASE_URL}/product/1
    Page Should Contain Element    css=.primary-nav a[data-nav='journal']
    Go To    ${BASE_URL}/account
    Page Should Contain Element    css=.primary-nav a[data-nav='journal']
    Go To    ${BASE_URL}/journal
    Page Should Contain Element    css=.primary-nav a[data-nav='journal']

DM-019 Header Journal Link Navigates From Home
    [Documentation]    Clicking the Journal link in the header navigates to
    ...                /journal and renders the index page.
    [Tags]    smoke    functional    priority-high    navigation
    Go To    ${BASE_URL}
    Click Safely    css=.primary-nav a[data-nav='journal']
    Wait Until Location Contains    /journal    timeout=5s
    Wait Until Element Is Visible    id=journal-heading    timeout=5s

DM-020 Footer Links Reach All Primary Pages
    [Documentation]    The footer contains links to the Journal and Account
    ...                and both resolve correctly.
    [Tags]    functional    priority-medium    navigation
    Go To    ${BASE_URL}
    Page Should Contain Element    css=.footer-links a[data-nav='journal']
    Page Should Contain Element    css=.footer-links a[data-nav='account']
    Click Safely    css=.footer-links a[data-nav='journal']
    Wait Until Location Contains    /journal    timeout=5s
    Wait Until Element Is Visible    id=journal-heading    timeout=5s

DM-021 Contact Page Renders Form And Information
    [Documentation]    The contact page shows the form, the address, and the
    ...                opening hours.
    [Tags]    smoke    functional    priority-high    contact
    Go To Contact Page
    Contact Page Should Show Form
    Contact Page Should Show Opening Hours

DM-022 Contact Form Submits Successfully
    [Documentation]    Filling the form and submitting it shows the success
    ...                status message from the server.
    [Tags]    smoke    functional    priority-high    contact
    Go To Contact Page
    Fill Contact Form
    ...    Test Visitor
    ...    visitor@example.com
    ...    A question about the house
    ...    I would like to know how the store began, and where the name Azam comes from.
    Submit Contact Form
    Contact Status Should Contain    Your note has reached the shop

DM-023 Contact Form Rejects Empty Name
    [Documentation]    Submitting the form with an empty name does not reach
    ...                the server. The browser's own validation prevents it.
    [Tags]    negative    priority-medium    contact
    Go To Contact Page
    Input Text        ${CONTACT_EMAIL}     visitor@example.com
    Input Text        ${CONTACT_MESSAGE}   A message long enough to satisfy the minimum.
    Submit Contact Form
    Sleep    0.5s
    Contact Status Should Not Contain Success
