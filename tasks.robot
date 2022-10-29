*** Settings ***
Documentation       Automation Anywhere Labs - Customer Onboarding

Library             RPA.Browser.Selenium
Library             RPA.FileSystem
Library             RPA.HTTP
Library             RPA.Tables


*** Variables ***
${CSV_FILE}             ${OUTPUT_DIR}${/}MissingCustomers.csv
${SCORE_FILE}           ${OUTPUT_DIR}${/}score.txt
${SCORE_SCREENSHOT}     ${OUTPUT_DIR}${/}score.png
${URL}
...                     https://developer.automationanywhere.com/challenges/automationanywherelabs-customeronboarding.html


*** Tasks ***
Do the challenge
    Open the challenge page
    Download the csv file
    Input data
    Save the score
    [Teardown]    End challenge


*** Keywords ***
Open the challenge page
    Open Available Browser    ${URL}    maximized=True

Download the csv file
    ${downloadCsvButton}=    Set Variable    //p[@class='lead']/a[@class='btn btn-orange']
    Wait Until Page Contains Element    ${downloadCsvButton}
    ${url_csv}=    Get Element Attribute    ${downloadCsvButton}    attribute=href
    Download    url=${url_csv}    target_file=${CSV_FILE}    overwrite=True

Input data
    ${customers}=    Read table from CSV    ${CSV_FILE}
    # The page is reloaded to reset the timer.
    Reload Page
    FOR    ${row}    IN    @{customers}
        Input one row    ${row}
    END

Input one row
    [Arguments]    ${row}
    Execute Javascript
    ...    document.querySelector("input[id='customerName']").value = "${row}[Company Name]";
    ...    document.querySelector("input[id='customerID']").value = "${row}[Customer ID]";
    ...    document.querySelector("input[id='primaryContact']").value = "${row}[Primary Contact]";
    ...    document.querySelector("input[id='street']").value = "${row}[Street Address]";
    ...    document.querySelector("input[id='city']").value = "${row}[City]";
    ...    document.querySelector("select[id='state']").value = "${row}[State]";
    ...    document.querySelector("input[id='zip']").value = "${row}[Zip]";
    ...    document.querySelector("input[id='email']").value = "${row}[Email Address]";
    ...    # Active Discount Offered?
    ...    if ("${row}[Offers Discounts]" == "YES") {document.querySelector("input[id='activeDiscountYes']").click();}
    ...    else {document.querySelector("input[id='activeDiscountNo']").click();}
    ...    # Non-Disclosure Agreement
    ...    if ("${row}[Non-Disclosure On File]" == "YES") {document.querySelector("input[id='NDA']").checked = true;}
    ...    # Register
    ...    document.querySelector("button[id='submit_button']").click();

Save the score
    Wait Until Page Contains Element    id:processing-time
    ${time}=    Get Text    id:processing-time
    ${accuracy}=    Get Text    id:accuracy
    Create File    ${SCORE_FILE}    overwrite=True    content=Time: ${time}${\n}Accuracy: ${accuracy}
    Screenshot    //div[@class='modal-body']    ${SCORE_SCREENSHOT}

End challenge
    Close Browser
