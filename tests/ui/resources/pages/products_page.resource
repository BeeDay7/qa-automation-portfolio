*** Settings ***
Documentation     Page Object for the Azam Trading Store product catalogue.
...
...               Clicks use the Click Safely keyword from common.resource,
...               which dispatches click events via JavaScript.
Library           SeleniumLibrary
Resource          ../common.resource

*** Variables ***
${SEARCH_INPUT}     id=search
${PRODUCT_LIST}     id=product-list
${NO_PRODUCTS}      id=no-products
${PRODUCT_COUNT}    id=product-count

*** Keywords ***
Search For Product
    [Documentation]    Type a query into the catalogue search field.
    [Arguments]    ${query}
    Input Text    ${SEARCH_INPUT}    ${query}

Clear Search
    [Documentation]    Empty the search field and wait for the full catalogue
    ...                to reappear.
    Clear Element Text    ${SEARCH_INPUT}
    Wait Until Element Is Visible    xpath=//li[@data-name='Wireless Mouse']    timeout=5s

Product Card Should Be Visible
    [Documentation]    Assert that a product card with the given data-name
    ...                attribute is visible.
    [Arguments]    ${name}
    Wait Until Element Is Visible    xpath=//li[@data-name='${name}']    timeout=5s

Product Card Should Not Be Visible
    [Documentation]    Assert that a product card with the given data-name
    ...                attribute is hidden.
    [Arguments]    ${name}
    Wait Until Element Is Not Visible    xpath=//li[@data-name='${name}']    timeout=5s

Add Product To Cart
    [Documentation]    Click the Add-to-cart button on the named product card.
    [Arguments]    ${name}
    ${locator}=    Set Variable    xpath=//li[@data-name='${name}']//button[contains(@class,'add')]
    Click Safely    ${locator}

Empty State Should Be Visible
    [Documentation]    Assert that the "no products matched" message is
    ...                displayed.
    Wait Until Element Is Visible    ${NO_PRODUCTS}    timeout=5s

Catalogue Should Report Count
    [Documentation]    Assert the catalogue counter shows the expected number.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${PRODUCT_COUNT}    ${expected}    timeout=5s
