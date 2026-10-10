*** Settings ***
Documentation     Page Object for the order confirmation page.
Library           SeleniumLibrary
Resource          ../common.resource

*** Variables ***
${ORDER_TITLE}          id=order-heading
${ORDER_SLIP}           css=.order-slip
${ORDER_NUMBER}         css=.order-slip-number
${ORDER_ITEMS}          css=.order-items
${ORDER_TOTAL_FINAL}    css=.order-total-final
${LEDGER_LIST}          css=.ledger-list
${LEDGER_FIRST_LINK}    css=.ledger-entry-link

*** Keywords ***
Order Page Should Be Visible
    [Documentation]    Assert the order confirmation page has rendered.
    Wait Until Element Is Visible    ${ORDER_TITLE}    timeout=5s
    Wait Until Element Is Visible    ${ORDER_SLIP}    timeout=5s

Order Number Should Be
    [Documentation]    Assert the order number in the slip matches.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${ORDER_NUMBER}    #${expected}    timeout=5s

Order Should Contain Product
    [Documentation]    Assert the order items list mentions the product.
    [Arguments]    ${name}
    Wait Until Element Contains    ${ORDER_ITEMS}    ${name}    timeout=5s

Order Total Should Be
    [Documentation]    Assert the final total equals the expected value.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${ORDER_TOTAL_FINAL}    ${expected}    timeout=5s

Ledger Should Be Visible
    [Documentation]    Assert the account ledger list is present.
    Wait Until Element Is Visible    ${LEDGER_LIST}    timeout=5s

Open First Ledger Entry
    [Documentation]    Click the newest order in the account ledger.
    Click Safely    ${LEDGER_FIRST_LINK}
    Wait Until Element Is Visible    ${ORDER_TITLE}    timeout=5s
