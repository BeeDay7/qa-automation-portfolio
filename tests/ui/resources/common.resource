*** Settings ***
Documentation     Shared setup and keywords for the UI suites.
Library           SeleniumLibrary
Library           qa_portfolio.libraries.DataLoader       root=${EXECDIR}
Library           qa_portfolio.libraries.EvidenceHelper   evidence_dir=${EXECDIR}/evidence/screenshots

*** Variables ***
${BASE_URL}          http://127.0.0.1:8001
${BROWSER}           chrome
${IMPLICIT_WAIT}     5s

*** Keywords ***
Open Storefront
    [Documentation]    Launch the browser and load the fixture.
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Wait Until Page Contains Element    css=header.site-header

Close Storefront
    [Documentation]    Close every open browser.
    Close All Browsers
