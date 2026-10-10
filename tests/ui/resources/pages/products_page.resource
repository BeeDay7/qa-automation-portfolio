*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${SEARCH_INPUT}    id=search
${PRODUCT_LIST}    id=product-list
${NO_PRODUCTS}     id=no-products
${PRODUCT_COUNT}   id=product-count

*** Keywords ***
Search For Product
    [Arguments]    ${query}
    Input Text    ${SEARCH_INPUT}    ${query}

Product Card Should Be Visible
    [Arguments]    ${name}
    Wait Until Element Is Visible    xpath=//li[@data-name='${name}']    timeout=5s

Product Card Should Not Be Visible
    [Arguments]    ${name}
    Wait Until Element Is Not Visible    xpath=//li[@data-name='${name}']    timeout=5s

Add Product To Cart
    [Arguments]    ${name}
    Click Button    xpath=//li[@data-name='${name}']//button[contains(@class,'add')]

Catalogue Should Report Count
    [Arguments]    ${expected}
    Wait Until Element Contains    ${PRODUCT_COUNT}    ${expected}    timeout=5s
