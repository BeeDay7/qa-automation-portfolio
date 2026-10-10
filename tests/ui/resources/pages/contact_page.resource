*** Settings ***
Documentation     Page Object for the Azam Trading Store contact page.
...
...               Clicks use the Click Safely keyword from common.resource.
Library           SeleniumLibrary
Resource          ../common.resource

*** Variables ***
${CONTACT_URL}              /contact
${CONTACT_HEADING}          id=contact-heading
${CONTACT_FORM}             id=contact-form
${CONTACT_NAME}             id=contact-name
${CONTACT_EMAIL}            id=contact-email
${CONTACT_SUBJECT}          id=contact-subject
${CONTACT_MESSAGE}          id=contact-message
${CONTACT_SUBMIT}           id=contact-submit
${CONTACT_STATUS}           id=contact-status

*** Keywords ***
Go To Contact Page
    [Documentation]    Navigate to /contact and wait for the page to render.
    Go To    ${BASE_URL}${CONTACT_URL}
    Wait Until Element Is Visible    ${CONTACT_HEADING}    timeout=5s

Contact Page Should Show Form
    [Documentation]    Assert the form and its four fields are visible.
    Wait Until Element Is Visible    ${CONTACT_FORM}    timeout=5s
    Wait Until Element Is Visible    ${CONTACT_NAME}    timeout=5s
    Wait Until Element Is Visible    ${CONTACT_EMAIL}    timeout=5s
    Wait Until Element Is Visible    ${CONTACT_MESSAGE}    timeout=5s

Fill Contact Form
    [Documentation]    Populate the form with the given values.
    [Arguments]    ${name}    ${email}    ${subject}    ${message}
    Input Text        ${CONTACT_NAME}     ${name}
    Input Text        ${CONTACT_EMAIL}    ${email}
    Input Text        ${CONTACT_SUBJECT}  ${subject}
    Input Text        ${CONTACT_MESSAGE}  ${message}

Submit Contact Form
    [Documentation]    Click the submit button.
    Click Safely    ${CONTACT_SUBMIT}

Contact Status Should Contain
    [Documentation]    Assert the status message contains the given text.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${CONTACT_STATUS}    ${expected}    timeout=5s

Contact Page Should Show Opening Hours
    [Documentation]    Assert the opening hours are visible somewhere on the page.
    Wait Until Page Contains    Monday to Saturday    timeout=5s

Contact Status Should Not Contain Success
    [Documentation]    Assert the status message does not contain the success text.
    ${text}=    Get Text    ${CONTACT_STATUS}
    Should Not Contain    ${text}    Your note has reached the shop
