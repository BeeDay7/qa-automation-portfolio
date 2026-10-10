*** Settings ***
Documentation     Shared setup, teardown, and utility keywords for every UI
...               suite in this project.
...
...               Design rationale: Selenium reuses one browser instance across
...               all tests in a suite, and browsers persist cookies between
...               page loads. Without an explicit reset, an authenticated test
...               silently contaminates the session for every test that follows.
...               Reset Storefront Session guarantees every test begins in a
...               known state: no cookies, no local storage, empty cart, signed
...               out.
...
...               Chrome runs headless so the suite is portable between a local
...               desktop and a Linux CI runner. The flags below are the
...               standard set required by GitHub Actions: --no-sandbox and
...               --disable-dev-shm-usage prevent the chromedriver crash that
...               occurs inside containerised runners with limited shared
...               memory.
Library           SeleniumLibrary
Library           qa_portfolio.libraries.DataLoader       root=${EXECDIR}
Library           qa_portfolio.libraries.EvidenceHelper   evidence_dir=${EXECDIR}/evidence/screenshots

*** Variables ***
${BASE_URL}          http://127.0.0.1:8001
${BROWSER}           chrome
${IMPLICIT_WAIT}     5s
${PAGE_LOAD_WAIT}    10s
${CHROME_OPTIONS}    add_argument("--headless=new");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage");add_argument("--disable-gpu");add_argument("--window-size=1920,1080")

*** Keywords ***
Open Storefront
    [Documentation]    Launch the browser and load the fixture root. Called
    ...                once per suite via Suite Setup.
    Open Browser    ${BASE_URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Set Selenium Implicit Wait    ${IMPLICIT_WAIT}
    Set Selenium Timeout    ${PAGE_LOAD_WAIT}
    Wait Until Page Contains Element    css=header.site-header

Close Storefront
    [Documentation]    Close every open browser. Called once per suite via
    ...                Suite Teardown.
    Close All Browsers

Reset Storefront Session
    [Documentation]    Return the browser to a pristine, anonymous state.
    ...
    ...                Steps: navigate, clear every cookie, clear both web
    ...                storage areas, reload the fixture, and wait for the
    ...                catalogue to render. Safe to call as Test Setup for
    ...                every test — idempotent and fast.
    Go To    ${BASE_URL}
    Delete All Cookies
    Execute JavaScript    window.localStorage.clear();
    Execute JavaScript    window.sessionStorage.clear();
    Go To    ${BASE_URL}
    Wait Until Page Contains Element    css=header.site-header
    Wait Until Page Contains Element    id=product-list
    Wait Until Element Is Visible       xpath=//li[@data-name='Wireless Mouse']

Reload Storefront
    [Documentation]    Reload the current page and wait for the catalogue to
    ...                render. Used to verify state persistence across
    ...                navigations (cookies, session, cart).
    Reload Page
    Wait Until Page Contains Element    id=product-list
    Wait Until Element Is Visible       xpath=//li[@data-name='Wireless Mouse']
