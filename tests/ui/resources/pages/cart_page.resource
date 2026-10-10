*** Settings ***
Documentation     Page Object for the Azam Trading Store cart drawer.
...
...               Clicks use the Click Safely keyword from common.resource,
...               which dispatches click events via JavaScript.
Library           SeleniumLibrary
Resource          ../common.resource

*** Variables ***
${OPEN_CART}      id=open-cart
${CLOSE_CART}     id=close-cart
${CART_DRAWER}    id=cart-drawer
${CART_COUNT}     id=cart-count
${CART_TOTAL}     id=cart-total
${CHECKOUT}       id=checkout
${MESSAGE}        id=message
${CART_EMPTY}     id=cart-empty

*** Keywords ***
Open Cart Drawer
    [Documentation]    Click the header cart button and wait for the drawer
    ...                to slide into view.
    Click Safely    ${OPEN_CART}
    Wait Until Element Is Visible    ${CART_DRAWER}    timeout=5s
    Wait Until Keyword Succeeds    3s    200ms    Cart Drawer Should Be Open

Close Cart Drawer
    [Documentation]    Click the drawer close button and wait for it to close.
    Click Safely    ${CLOSE_CART}
    Wait Until Keyword Succeeds    3s    200ms    Cart Drawer Should Be Closed

Cart Drawer Should Be Open
    [Documentation]    Assert the drawer reports aria-hidden="false".
    Element Attribute Value Should Be    ${CART_DRAWER}    aria-hidden    false

Cart Drawer Should Be Closed
    [Documentation]    Assert the drawer reports aria-hidden="true".
    Element Attribute Value Should Be    ${CART_DRAWER}    aria-hidden    true

Cart Count Should Be
    [Documentation]    Assert the cart item counter equals the expected value.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${CART_COUNT}    ${expected}    timeout=5s

Cart Total Should Be
    [Documentation]    Assert the cart total equals the expected value.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${CART_TOTAL}    ${expected}    timeout=5s

Click Checkout
    [Documentation]    Click the checkout button inside the cart drawer.
    Click Safely    ${CHECKOUT}

Checkout Message Should Contain
    [Documentation]    Assert the checkout status message contains expected
    ...                text.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${MESSAGE}    ${expected}    timeout=5s

Cart Should Be Empty
    [Documentation]    Assert the drawer's empty-cart message is visible.
    Wait Until Element Is Visible    ${CART_EMPTY}    timeout=5s
