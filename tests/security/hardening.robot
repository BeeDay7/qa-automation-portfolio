*** Settings ***
Documentation     API-level checks of the security controls added to the
...               fixtures: account enumeration, brute-force throttling,
...               session handling, cookie flags, security headers, caching,
...               security logging and object-level access control.
...
...               Each test cites the OWASP ASVS 4.0.3 requirement (or OWASP
...               WSTG test) it verifies. This suite checks that specific
...               controls behave as designed. It is NOT a penetration test;
...               see docs/LIMITATIONS.md.
Library           RequestsLibrary
Library           Collections
Library           String
Test Tags         security    hardening    api    portfolio

*** Variables ***
${SECURE_URL}        http://127.0.0.1:8002
${STORE_URL}         http://127.0.0.1:8001
${ADMIN_USER}        qa_admin
${ADMIN_PASS}        LocalOnly!234
${PROBE_USER}        throttle_probe
${STORE_CUSTOMER}    customer@example.com
${STORE_CUST_PASS}   Customer!2026
${STORE_ADMIN}       admin@azamtradingstore.com
${STORE_ADMIN_PASS}  AzamAdmin!2026
${MAX_FAILURES}      5

*** Test Cases ***
SEC-011 Login Does Not Reveal Whether An Account Exists
    [Documentation]    An unknown user and a wrong password for a real user
    ...                receive the same status and body (WSTG-IDNT-04).
    [Tags]    enumeration    priority-high
    Create Session    enum    ${SECURE_URL}
    ${unknown}=    POST On Session    enum    /api/login
    ...    json=${{ {"username": "no_such_user", "password": "x"} }}    expected_status=401
    ${wrong}=      POST On Session    enum    /api/login
    ...    json=${{ {"username": "qa_viewer", "password": "wrong"} }}    expected_status=401
    Should Be Equal    ${unknown.text}    ${wrong.text}

SEC-012 Repeated Failed Logins Are Throttled
    [Documentation]    After five failures in five minutes the account is
    ...                throttled with HTTP 429 and a Retry-After header
    ...                (ASVS V2.2.1, anti-automation).
    [Tags]    brute-force    priority-high
    Create Session    brute    ${SECURE_URL}
    FOR    ${i}    IN RANGE    ${MAX_FAILURES}
        POST On Session    brute    /api/login
        ...    json=${{ {"username": "${PROBE_USER}", "password": "guess-${i}"} }}
        ...    expected_status=401
    END
    ${resp}=    POST On Session    brute    /api/login
    ...    json=${{ {"username": "${PROBE_USER}", "password": "guess-final"} }}
    ...    expected_status=429
    Should Be Equal    ${resp.json()}[error]    too_many_attempts
    ${retry}=    Get From Dictionary    ${resp.headers}    Retry-After
    Should Be True    0 < int(${retry}) <= 300

SEC-013 Throttling Applies Per Account
    [Documentation]    Throttling one account does not block a different,
    ...                legitimate account.
    [Tags]    brute-force    availability
    Create Session    other    ${SECURE_URL}
    POST On Session    other    /api/login
    ...    json=${{ {"username": "${ADMIN_USER}", "password": "${ADMIN_PASS}"} }}
    ...    expected_status=200

SEC-014 Logout Ends The Session
    [Documentation]    After logout the same client can no longer call the
    ...                admin API (ASVS V3.3.1).
    [Tags]    session    priority-high
    Create Session    logout    ${SECURE_URL}
    POST On Session    logout    /api/login
    ...    json=${{ {"username": "${ADMIN_USER}", "password": "${ADMIN_PASS}"} }}
    ...    expected_status=200
    GET On Session     logout    /api/admin/records    expected_status=200
    POST On Session    logout    /api/logout    expected_status=200
    GET On Session     logout    /api/admin/records    expected_status=403

SEC-015 Session Cookie Is HttpOnly And SameSite Strict
    [Documentation]    The session cookie cannot be read by scripts and is
    ...                not sent on cross-site requests (ASVS V3.4.2, V3.4.3).
    [Tags]    session    cookies    priority-high
    Create Session    cookie    ${SECURE_URL}
    ${resp}=    POST On Session    cookie    /api/login
    ...    json=${{ {"username": "${ADMIN_USER}", "password": "${ADMIN_PASS}"} }}
    ...    expected_status=200
    ${cookie}=    Get From Dictionary    ${resp.headers}    Set-Cookie
    ${cookie}=    Convert To Lower Case    ${cookie}
    Should Contain    ${cookie}    httponly
    Should Contain    ${cookie}    samesite=strict

SEC-016 Pages Send Defensive Security Headers
    [Documentation]    Content Security Policy, MIME-sniffing protection,
    ...                anti-framing and referrer policy are present on both
    ...                applications (ASVS V14.4.3, V14.4.4, V14.4.6, V14.4.7).
    [Tags]    headers    priority-high
    FOR    ${base}    IN    ${SECURE_URL}    ${STORE_URL}
        Create Session    hdr    ${base}
        ${resp}=    GET On Session    hdr    /    expected_status=200
        ${csp}=    Get From Dictionary    ${resp.headers}    Content-Security-Policy
        Should Contain    ${csp}    script-src 'self'
        Should Contain    ${csp}    frame-ancestors 'none'
        Should Contain    ${csp}    object-src 'none'
        Dictionary Should Contain Item    ${resp.headers}    X-Content-Type-Options    nosniff
        Dictionary Should Contain Item    ${resp.headers}    X-Frame-Options    DENY
        Dictionary Should Contain Item    ${resp.headers}    Referrer-Policy    no-referrer
    END

SEC-017 API Responses Are Not Cached
    [Documentation]    Responses that may carry session or account data are
    ...                marked no-store (ASVS V8.2.1).
    [Tags]    headers    caching
    Create Session    cache    ${SECURE_URL}
    ${resp}=    GET On Session    cache    /api/session    expected_status=200
    Dictionary Should Contain Item    ${resp.headers}    Cache-Control    no-store

SEC-018 Failed And Throttled Logins Are Logged
    [Documentation]    Authentication failures and throttling decisions appear
    ...                in the auth log for monitoring (ASVS V7.2.1).
    [Tags]    logging    priority-medium
    Create Session    audit    ${SECURE_URL}
    POST On Session    audit    /api/login
    ...    json=${{ {"username": "${ADMIN_USER}", "password": "${ADMIN_PASS}"} }}
    ...    expected_status=200
    ${resp}=    GET On Session    audit    /api/auth/log    expected_status=200
    ${reasons}=    Evaluate
    ...    [e["reason"] for e in $resp.json()["events"] if e["username"] == "${PROBE_USER}"]
    Should Contain    ${reasons}    throttled
    Should Contain    ${reasons}    unknown_user

SEC-019 Order Receipts Are Private To The Buyer
    [Documentation]    Object-level access control: an order page is visible
    ...                only to the customer who placed it. Another signed-in
    ...                user and an anonymous visitor both get 404, so the
    ...                order ID cannot be probed (ASVS V4.2.1, IDOR).
    [Tags]    idor    access-control    priority-high
    Create Session    buyer    ${STORE_URL}
    POST On Session    buyer    /api/login
    ...    json=${{ {"email": "${STORE_CUSTOMER}", "password": "${STORE_CUST_PASS}"} }}
    ...    expected_status=200
    POST On Session    buyer    /api/cart/items    json=${{ {"product_id": 1} }}    expected_status=200
    ${order}=    POST On Session    buyer    /api/checkout    expected_status=200
    ${order_id}=    Set Variable    ${order.json()}[order_id]
    GET On Session    buyer    /order/${order_id}    expected_status=200
    Create Session    intruder    ${STORE_URL}
    POST On Session    intruder    /api/login
    ...    json=${{ {"email": "${STORE_ADMIN}", "password": "${STORE_ADMIN_PASS}"} }}
    ...    expected_status=200
    GET On Session    intruder    /order/${order_id}    expected_status=404
    Create Session    anonymous    ${STORE_URL}
    GET On Session    anonymous    /order/${order_id}    expected_status=404

SEC-020 Contact Inbox Is Restricted To Admins
    [Documentation]    A signed-in customer cannot read the admin contact
    ...                inbox; the store admin can (ASVS V4.1.1).
    [Tags]    access-control    priority-medium
    Create Session    cust    ${STORE_URL}
    POST On Session    cust    /api/login
    ...    json=${{ {"email": "${STORE_CUSTOMER}", "password": "${STORE_CUST_PASS}"} }}
    ...    expected_status=200
    GET On Session    cust    /api/contact/log    expected_status=403
    Create Session    store_admin    ${STORE_URL}
    POST On Session    store_admin    /api/login
    ...    json=${{ {"email": "${STORE_ADMIN}", "password": "${STORE_ADMIN_PASS}"} }}
    ...    expected_status=200
    GET On Session    store_admin    /api/contact/log    expected_status=200
