*** Settings ***
Documentation     Page Object for the Azam Trading Store journal.
...
...               Covers the journal index and the article view.
Library           SeleniumLibrary
Resource          ../common.resource

*** Variables ***
${JOURNAL_URL}              /journal
${JOURNAL_HEADING}          id=journal-heading
${JOURNAL_LIST}             css=.journal-list
${JOURNAL_ITEM_COUNT}       xpath=//ul[contains(@class,'journal-list')]/li
${ARTICLE_TITLE}            css=.journal-article-title
${ARTICLE_BODY}             css=.journal-prose
${ARTICLE_META}             css=.journal-article-meta

*** Keywords ***
Go To Journal Index
    [Documentation]    Navigate to /journal and wait for the index to render.
    Go To    ${BASE_URL}${JOURNAL_URL}
    Wait Until Element Is Visible    ${JOURNAL_HEADING}    timeout=5s

Journal Should Show Articles
    [Documentation]    Assert the journal index lists at least one article.
    Wait Until Element Is Visible    ${JOURNAL_LIST}    timeout=5s
    Wait Until Element Is Visible    ${JOURNAL_ITEM_COUNT}    timeout=5s

Open Journal Article
    [Documentation]    Click the article with the given title on the index.
    [Arguments]    ${title}
    ${locator}=    Set Variable
    ...    xpath=//a[contains(@class,'journal-item-link')][.//h2[contains(., '${title}')]]
    Click Safely    ${locator}
    Wait Until Element Is Visible    ${ARTICLE_TITLE}    timeout=5s

Article Title Should Be
    [Documentation]    Assert the article view shows the given title.
    [Arguments]    ${expected}
    Wait Until Element Contains    ${ARTICLE_TITLE}    ${expected}    timeout=5s

Article Should Have Body Content
    [Documentation]    Assert the article prose block is present and has text.
    Wait Until Element Is Visible    ${ARTICLE_BODY}    timeout=5s
    ${text}=    Get Text    ${ARTICLE_BODY}
    Should Not Be Empty    ${text}

Article Should Show Metadata
    [Documentation]    Assert the reading time and author are visible.
    Wait Until Element Is Visible    ${ARTICLE_META}    timeout=5s
    Wait Until Element Contains    ${ARTICLE_META}    minutes    timeout=5s

Other Notes Should Be Listed
    [Documentation]    Assert the "other notes" section appears below an article.
    Wait Until Element Is Visible    css=.journal-more    timeout=5s
