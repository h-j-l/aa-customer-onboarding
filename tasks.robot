*** Settings ***
Documentation       Automation Anywhere Labs - Customer Onboarding

Library             RPA.Browser.Selenium
Library             RPA.FileSystem
Library             RPA.HTTP
Library             RPA.Tables


*** Variables ***
${BUTTON_DOWNLOADCSV}       css:div > p > a[class="btn btn-orange"]
${CSV_FILE}                 ${OUTPUT_DIR}${/}MissingCustomers.csv
${SCORE_FILE}               ${OUTPUT_DIR}${/}score.txt
${URL}
...                         https://developer.automationanywhere.com/challenges/automationanywherelabs-customeronboarding.html


*** Tasks ***
Do the challenge
    Open the challenge page
    Download the csv file
    Input data
    Read and save the score
    [Teardown]    End challenge


*** Keywords ***
Open the challenge page
    Open Available Browser    ${URL}
    Maximize Browser Window

Download the csv file
    Wait Until Page Contains Element    ${BUTTON_DOWNLOADCSV}
    ${url_csv}=    Get Element Attribute    ${BUTTON_DOWNLOADCSV}    attribute=href
    Download    url=${url_csv}    target_file=${CSV_FILE}    overwrite=True

Input data
    ${customers}=    Read table from CSV    ${CSV_FILE}
    # The page is reloaded to reset the timer.
    Reload Page
    Wait Until Page Contains Element    id:submit_button
    FOR    ${row}    IN    @{customers}
        Input one row    ${row}
    END

Input one row
    [Arguments]    ${row}
    Input Text    id:customerName    ${row}[Company Name]
    Input Text    id:customerID    ${row}[Customer ID]
    Input Text    id:primaryContact    ${row}[Primary Contact]
    Input Text    id:street    ${row}[Street Address]
    Input Text    id:city    ${row}[City]
    Select From List By Value    id:state    ${row}[State]
    Input Text    id:zip    ${row}[Zip]
    Input Text    id:email    ${row}[Email Address]
    # Active Discount Offered?
    IF    "${row}[Offers Discounts]" == "YES"
        Click Element    id:activeDiscountYes
    ELSE
        Click Element    id:activeDiscountNo
    END
    # Non-Disclosure Agreement
    IF    "${row}[Non-Disclosure On File]" == "YES"    Select Checkbox    id:NDA
    Click Button    id:submit_button

Read and save the score
    Wait Until Page Contains Element    id:processing-time
    ${time}=    Get Text    id:processing-time
    ${accuracy}=    Get Text    id:accuracy
    Create File    ${SCORE_FILE}    overwrite=True    content=Time: ${time}${\n}Accuracy: ${accuracy}

End challenge
    Close Browser
