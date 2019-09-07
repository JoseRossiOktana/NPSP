*** Variables ***
${database_url} =    
${persistent_org} =     ${False}

${data_generation_task} =       tasks.generate_bdi_CO_data.GenerateBDIData_CO

*** Settings ***

Resource  cumulusci/robotframework/CumulusCI.robot
Resource        robot/Cumulus/resources/NPSP.robot
Resource        robot/Cumulus/resources/Data.robot
Resource        robot/Cumulus/resources/BDI_API.robot
Suite Setup       Workaround Bug

*** Keywords ***
Clear Generated Records
    Python Display  Clearing Generated Records
    # Organized in dependency order
    Delete     DataImport__c, CustomObject1__c, CustomObject2__c, CustomObject3__c
    Delete     Account_Soft_Credit__c     where=Account__r.BillingCountry\='Tuvalu' OR Opportunity__r.Primary_Contact__r.Title\='HRH'
    Delete     Allocation__c        where=Opportunity__r.Primary_Contact__r.Title\='HRH' OR Opportunity__r.Account.BillingCountry\='Tuvalu'
    Delete     npe01__OppPayment__c     where=npe01__Opportunity__r.Primary_Contact__r.Title\='HRH' OR npe01__Opportunity__r.Account.BillingCountry\='Tuvalu'
    Delete     Opportunity     where=Primary_Contact__r.Title\='HRH' OR Account.BillingCountry\='Tuvalu'
    Delete     Account     where=BillingCountry\='Tuvalu'
    Delete     Contact     where=Title\='HRH'

Generate Data
    [Arguments]    ${count}
    ${count} =  Convert To Integer	${count}
    # ${data_generation_task} =     Set Variable If         "${field_mapping_method}"=="Help Text"  tasks.generate_bdi_data.generate_bdi_data         tasks.generate_bdi_CO_data.GenerateBDIData_CO

    Run Task Class   tasks.generate_and_load_data.GenerateAndLoadData
    ...                 num_records=${count}
#    ...                 database_url=sqlite:////tmp/temp_db.db  # turn this on to look at the DB for debugging
    ...                 mapping=datasets/bdi_benchmark/mapping-CO.yml
    ...                 data_generation_task=${data_generation_task}

Setup BDI
    [Arguments]     ${field_mapping_method}
    Configure BDI     ${field_mapping_method}

    Run Keyword If    '${field_mapping_method}'=='Data Import Field Mapping'
    ...               Ensure Custom Metadata Was Deployed

Report BDI
    ${result} =   Row Count      DataImport__c  
    ...           Status__c=Imported

    Python Display  DataImport__c imported    ${result}

    ${result} =   Row Count     CustomObject3__c  

    Python Display  CustomObject3__c imported    ${result}

    ${result} =   Row Count  Account  
    ...           BillingCountry=Tuvalu

    Python Display  Accounts imported    ${result}

    ${result} =   Row Count     Contact  
    ...           Title=HRH

    Python Display  Contacts imported    ${result}

Workaround Bug
    Return From Keyword If      ${persistent_org}   # persistent orgs don't have this bug
    Generate Data   4
    Setup BDI       Data Import Field Mapping
    Batch Data Import   1000

Validate Data
    [Arguments]     ${count}
    ${result} =    Check Row Count    ${count}     DataImport__c       Status__c=Imported
    Run Keyword Unless   "${result}"=="PASS"      Display BDI Failures
    Should be Equal     ${result}      PASS

Setup For Test
    [Arguments]                 ${count}    ${bdi_mode}
    Clear Generated Records
    Setup BDI                   ${bdi_mode}
    Generate Data               ${count}

*** Test Cases ***
BGE/BDI Import - NoMatch - 1000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payment,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    1000    Data Import Field Mapping
    [Teardown]     Validate Data      1000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 1000 / 250 - Help Text - 3.5 Objs/DI - 1Acc,0.5Contact,1Payment,1 Opp
    [Setup]     Setup For Test    1000    Help Text
    [Teardown]     Validate Data      1000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 10000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payments,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    10000    Data Import Field Mapping
    [Teardown]     Validate Data      10000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 10000 / 250 - Help Text - 3.5 Objs/DI - 1Acc,0.5Contact,1Payment,1 Opp
    [Setup]     Setup For Test    10000    Help Text
    [Teardown]     Validate Data      10000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 20000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payments,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    20000    Data Import Field Mapping
    [Teardown]     Validate Data      20000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 40000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payments,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    40000    Data Import Field Mapping
    [Teardown]     Validate Data      40000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 80000 / 250 - Help Text - 3.5 Objs/DI - 1Acc,0.5Contact,1Payment,1 Opp
    [Setup]     Setup For Test    80000    Help Text
    [Teardown]     Validate Data      80000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 80000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payments,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    80000    Data Import Field Mapping
    [Teardown]     Validate Data      80000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 120000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payments,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    120000    Data Import Field Mapping
    [Teardown]     Validate Data      120000
    Batch Data Import   250

BGE/BDI Import - NoMatch - 200000 / 250 - 7.5 Objs/DI - 1Acc,0.5Con,1CO1,0.5CO2,1CO3,1Payments,1Allocation,0.5ASC,1 Opp
    [Setup]     Setup For Test    200000    Data Import Field Mapping
    [Teardown]     Validate Data      200000
    Batch Data Import   250
