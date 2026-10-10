*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${OPEN_CART}     id=open-cart
${CLOSE_CART}    id=close-cart
${CART_COUNT}    id=cart-count
${CART_TOTAL}    id=cart-total
${CHECKOUT}      id=checkout
${MESSAGE}       id=message
${CART_DRAWER}   id=cart-drawer

*** Keywords ***
Open Cart Drawer
    Click Button    ${OPEN_CART}
    Wait Until Element Is Visible    ${CART_DRAWER}    timeout=5s

Cart Count Should Be
    [Arguments]    ${expected}
    Wait Until Element Contains    ${CART_COUNT}    ${expected}    timeout=5s

Cart Total Should Be
    [Arguments]    ${expected}
    Wait Until Element Contains    ${CART_TOTAL}    ${expected}    timeout=5s

Click Checkout
    Click Button    ${CHECKOUT}

Checkout Message Should Contain
    [Arguments]    ${expected}
    Wait Until Element Contains    ${MESSAGE}    ${expected}    timeout=5s
