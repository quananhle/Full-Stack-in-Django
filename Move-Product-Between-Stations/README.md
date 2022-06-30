# Move Products Between Sections

![image](https://user-images.githubusercontent.com/35042430/175477730-364c4a53-3452-4799-a9b2-e39e6b1f524a.png)

* [Review List](#review-list)
* [Requirement](#requirement)
	* [Change Request (Document)](#change-request-document)
	* [Req Analysis (IT Assessment)](#req-analysis-IT-assessment)
		* [Frontend](#frontend)
		* [Datalayer](#datalayer)
		* [Backend](#backend)
	* [Low Level Design](#low-level-design)
* [Changes](#changes)
	* [Change Summary](#change-summary)
		* [Back-end](#back-end)
		* [Front-end](#front-end)
		* [Database](#database)
	* [Change Details](#change-details)
* [Testing](#testing)
	* [Summary](#summary)
	* [Cases](#cases)

## Requirement
### Change Request (Document)
<sup>Insert change request document<sup>
 
![image](https://user-images.githubusercontent.com/35042430/176091518-3fc939ae-aa3e-4c77-9dda-3b9302b442d9.png)
![image](https://user-images.githubusercontent.com/35042430/176091581-f8d3079a-69a4-4c53-8adf-773cbc8517c3.png)

### Req Analysis (IT Assessment)
<sup>Developer’s Analisys of the change request. (Include ITA Document if exists)<sup>
	
<a target="_blank" href="https://icons8.com/icon/q1Qnao8NDQqg/microsoft-word-2019"><img src="https://img.icons8.com/clouds/100/000000/microsoft-word-2019.png"/></a>
	
#### Frontend

1.	Create new front-end template for Change SN Station tool and create new JavaScript for UX to receive input, display data to info cards, tracking table, station drop-down list, and confirm button.
2.	Create new front-end template for prompting credentials to get BPL Approval 

#### Datalayer

1.	Create new stored procedure mfg_change_sn_station_validation to validate the serial number input from users
2.	Create new stored procedure mfg_change_sn_station to update station, tracking records, and pack records
3.	Create new function tls_get_sn_info to retrieve details of serial number
4.	Create new function mfg_prd_flow_get_station to retrieve list of stations in the route where serial number belongs

#### Backend

1.	Create new class ChangeStationView to validate input value, retrieve info details, and populate data to info cards, tracking table, and station drop-down.


### Low Level Design 
<sup>Developer’s approach and design. Which parts of the system this change consists of. Back end, Front end, db layer<sup>

1.	**Database:** 
	
	a.	Create store procedures that validate the serial number _mfg_change_sn_station_validation_, and change serial number station _mfg_change_sn_station_
	
	- _mfg_change_sn_station_ (serial number, requested to change event, requestor info, name of station)
	- _mfg_change_sn_station_validation_ (serial number, requested to change event, name of station)
	
	b.	Create functions to retrieve detailed info of serial number _tls_get_sn_info_, list of stations where serial number has passed _mfg_prd_flow_get_station_, and error messages should BPL approval is failed to achieve _mfg_qa_approval_ath_fn_

	- _tls_get_sn_info_ _(serial number)_
	- _mfg_prd_flow_get_station_ _(serial number, route ID)_
	- _mfg_qa_approval_ath_fn (transtype, username)_
	
	c.	Validate all the edge cases:

	- Serial Number Not Found
	- Input Not Found
	- Model ID Not Found
	- SN Already Disassembled
	- SN Already Shipped
	- Work Order Already Canceled
	- Serial Number On Hold
	- Serial Number in Repair Station
	- Serial Number has Failed Status
	- Route ID Not Found for WO
	- Event not Found in Route ID
	- Requested to Change Event Is the Same As Current Event
	- Serial Number Has Not Passed The Requested to Change Event
	- New Station in UDE List
	
	d.	Handle all scenarios:
	
	i. Move SN from Pack to previously passed stations
	
		• Pack is Closed
			* Pack is in a Pallet
				- Raise exception "Users should use the Reverse Pre-Ship tool"
			* Pack is not in a Pallet
				- Pack is Single
					+ Delete Pack record in Pack table
					+ Delete record in Pack Serial Number table
				- Pack is Bulk
					+ Remove Serial Number record from Pack Serial Number table
					+ Update Pack quantity less 1 in Pack table 
					+ Update Pack status to 0
			* Update station ID to new station, last station ID to current station, updater, update time records in Serial Number table
		• Pack is Open
			* Pack is Single
				- Delete Pack record in Pack table
				- Delete record in Pack Serial Number table
			* Pack is Bulk
				- Remove Serial Number record from Pack Serial Number table
				- Update Pack quantity less 1 in Pack table 
			* Update station ID to new station, last station ID to current station, updater, update time records in Serial Number table
	
	ii. Move SN forward
	
		• If no Testing station appears between the current station and the new station
			* Update station ID, last station ID, updater, update time records in Serial Number table
		• If Testing station appears between the current station and the new station
			* Raise exception "Inform user about the closest testing station to move Serial Number to"
		• If new Station is after FINISH station
			* Raise exception "Inform user to move the Serial Number to FINISH station"
		• Update station ID to new station, last station ID to current station, Fresh product status, updater, update time records in Serial Number table
	
	iii. New Station in UDE list
	
		• New station appears in control value of Control Values table
			* Raise exception "Inform user to update the UDE list or select different station"
	
	iv. SAP
	
		• SN is confirmed in SAP
			* Prompt BPL Approval
			* Delete all records of station after FINISH station of the SN in Serial Number Track table
			* SAP Confirmed Work Order quantity
				- Confirmed quantity is 1
					+ Delete Confirmed Work Order record in SAP Upload Process table and SAP Upload Data table
				- Confirmed quantity is more than 1
					+ Update total quantity, updater, update time of SAP Value in SAP Upload Process table
			* Work Order finished quantity
				- Finished quantity is 1
					+ Update Work Order status to Started, updater, update time in Work Order table
				- Finished quantity is more than 1
					+ Update finished quantity less 1, Work Order status to Started, updater, update time in Work Order table
			* Update station ID to new station, last station ID to current station, Started SN status, Fresh product status, updater, update time records in Serial Number table
	
		• SN is not yet confirmed in SAP
			* Delete all records of station after FINISH station of the SN in Serial Number Track table
			* Work Order finished quantity
				- Finished quantity is 1
					+ Update Work Order status to Started, updater, update time in Work Order table
				- Finished quantity is more than 1
					+ Update finished quantity less 1, Work Order status to Started, updater, update time in Work Order table
			* Update station ID to new station, last station ID to current station, Started SN status, Fresh product status, updater, update time records in Serial Number table
	
2.	**Front-end:**
	
	a. Create new HTML template for Change SN Station in Tools
	
	b. Develop the JavaScripts functions to define the behaviors
	
	c. Create new HTML template to prompt BPL credentials to get BPL Approval Modal 
	
3.	**Back-end**
	
	a. Create new views for Change SN Station in Tools
	
	b. Require users to input Serial Number. Call serialnumber_validation stored procedure to validate the input
	
	c. After users hit Enter, display associated information of the Serial Number
	
	d. Users can select the Station to move the Serial Number to from a drop-down
	
	e. After users clicked on the button Confirm, call mfg_change_sn_station stored procedure in database layer to update the database

![image](https://user-images.githubusercontent.com/35042430/176121490-a1f9f36c-e4ae-4109-9205-04853befdd49.png)

## Changes

### Change Summary
	
#### Back-end
	
1.	tls/urls.py
2.	tls/views.py
	
#### Front-end
	
1.	tls/templates/change_sn_station/change_station.html
2.	static/apps/change_sn_station/change_sn_station.js
3.	tls/templates/change_sn_station/bpl_approval_modal.html
	
#### Database
	
1.	sadmin_submodules table 
2.	mfg_change_sn_station stored procedure
3.	mfg_change_sn_station_validation stored procedure
4.	tls_get_sn_info function
5.	mfg_prd_flow_get_station function
6.	mfg_qa_approval_ath_fn function

### Change Details

__Table  Modifications__
<sup>Get the latest version of the DB by refreshing your schema.<sup>

* _sadmin_submodules_
	
	• Insert new submodule name, icon, url name, and module ID.
	
* _sadmin_syscontrolvalues_
	
	• Insert new control name, control value

__Stored Procedures__
<sup>Get the latest version of the DB by refreshing your schema<sup>

* _mfg_change_sn_station_
	
	• Update the station, last station, tracking records, and pack details.
	
* _mfg_change_sn_station_validation_
	
	• Validate serial number input.

__User Defined Functions__
<sup>Get the latest version of the DB by refreshing your schema<sup>

* _tls_get_sn_info_
	
	• Retrieve serial number details: workorder ID, station, last station, model ID, production version, route ID, status, row ID, passed stations, action, scan date, scan person.
	
* _mfg_prd_flow_get_station_
	
	• Retrieve list of stations where serial number has passed.
	
* _mfg_qa_approval_ath_fn_
	
	• Retrieve list of stations where serial number has passed.

__Front-End__
<sup>Get the latest version of the project<sup>

* _tls/templates/change_sn_station/change_station.html_

	• Template for change SN station tool
* _tls/templates/change_sn_station/bpl_approval_modal.html_

	• Template for BPL Approval modal
	
* _static/apps/change_sn_station/change_sn_station.js_

__Back-End__
<sup>Get the latest version of the project<sup>

* _tls/urls.py_

	• change_sn_station

* _tls/views.py

	• ChangeStationView class

	- dispatch
	- get
	- populate
	- confirm
	- approval

## Testing
<sup>(create your test cases and fill the following format after each step record screen shots as evidence)<sup>

### Summary

|Case No|P	|N	|R	|Description								|Result					|
|--	|--	|--	|--	|--									|--					|
|1	|X	|	|	|Move SN from Assy 6 to Assy 4						|Move SN Successfully			|
|2	|X	|	|	|Move SN from CK PMDU to Pack						|Move SN Successfully			|
|3	|X	|	|	|Move SN from closed Pack to CK PMDU					|Move SN Successfully			|
|4	|X	|	|	|Move SN from open Pack to OBA FINAL					|Move SN Successfully			|
|5	|X	|	|	|Move SAP confirmed SN to Assy						|Move SN Successfully			|
|6	|X	|	|	|Move SN at Finish station to Assy					|Move SN Successfully			|
|7	|	|X	|	|Serial Number Not Found						|SN Failed to Move.Display error message|
|8	|	|X	|	|Input Not Found							|SN Failed to Move.Display error message|
|9	|	|X	|	|Model ID Not Found							|SN Failed to Move.Display error message|
|10	|	|X	|	|SN In Palletize or Preship						|SN Failed to Move.Display error message|
|11	|	|X	|	|SN Already Shipped							|SN Failed to Move.Display error message|
|12	|	|X	|	|Work Order Already Canceled						|SN Failed to Move.Display error message|
|13	|	|X	|	|Serial Number On Hold							|SN Failed to Move.Display error message|
|14	|	|X	|	|Serial Number in Repair Station					|SN Failed to Move.Display error message|
|15	|	|X	|	|Serial Number has Failed Status					|SN Failed to Move.Display error message|
|16	|	|X	|	|Route ID Not Found for WO						|SN Failed to Move.Display error message|
|17	|	|X	|	|Event not Found in Route ID						|SN Failed to Move.Display error message|
|18	|	|X	|	|Requested to Change Event Is the Same As Current Event			|SN Failed to Move.Display error message|
|19	|	|X	|	|Serial Number Has Not Passed The Requested to Change Event		|SN Failed to Move.Display error message|
|20	|	|X	|	|New Station in UDE List						|SN Failed to Move.Display error message|
|21	|	|X	|	|Pack is Closed in Pallet						|SN Failed to Move.Display error message|
|22	|	|X	|	|Testing Station Between New and Current Station When Moving SN Forward	|SN Failed to Move.Display error message|
|23	|	|X	|	|New Station After FINISH Station					|SN Failed to Move.Display error message|
|24	|	|X	|	|Wrong BPL Approval							|SN Failed to Move.Display error message|

### Cases

__Test Case No: 1__
	
|Step Name	|Description			|Expected Result												|
|--		|--				|--														|
|Step 1		|Enter SN currently at Assy 6	|Display SN details in info cards, tracking info in tracking table, and list of station SN previously passed	|
|Step 2		|Select Assy 4 from station drop-down in Change Station section	| Display success message. Display updated details in info cards.		|

Step 1:
	
![image](https://user-images.githubusercontent.com/35042430/176097806-e16791af-eb25-4e15-8c0c-910d397d98d4.png)

Step 2:
 
![image](https://user-images.githubusercontent.com/35042430/176097823-65958268-3556-4bab-a9aa-263dc986e6b0.png)
![image](https://user-images.githubusercontent.com/35042430/176097838-b762d771-122b-4d38-af1f-d86856718678.png)

__Test Case No: 2__
	
|Step Name	|Description			|Expected Result												|
|--		|--				|--														|
|Step 1		|Enter SN currently at CK PMDU	|Display SN details in info cards, tracking info in tracking table, and list of station SN previously passed	|
|Step 2		|Select Pack from station drop-down in Change Station section	| Display success message. Display updated details in info cards.		|

Step 1:
	
![image](https://user-images.githubusercontent.com/35042430/176098011-2ed53f8f-e9da-48fb-b829-ca71d1a64359.png)

Step 2:
 
![image](https://user-images.githubusercontent.com/35042430/176098030-fb52ee5d-5067-48e0-b124-2261a4027e20.png)
![image](https://user-images.githubusercontent.com/35042430/176098039-0d30cc9c-78d4-4fe5-b9d0-0c69dba2459d.png)
 

__Test Case No: 3__
	
	
|Step Name	|Description			|Expected Result												|
|--		|--				|--														|
|Step 1		|Enter SN currently at closed Pack which is not existed in a Pallet	|Display SN details in info cards, tracking info in tracking table, and list of station SN previously passed	|
|Step 2		|Select CK PMDU from station drop-down in Change Station section	|Display success message. Display updated details in info cards. Update records in Pack table and delete record from Pack Serial Number table	|

Step 1:
	
![image](https://user-images.githubusercontent.com/35042430/176098328-df0c3ecd-3c84-4570-b2c4-7705a5c0eea7.png)
![image](https://user-images.githubusercontent.com/35042430/176098344-43cf71f6-9442-4d9f-904e-305f1b901eb6.png)
![image](https://user-images.githubusercontent.com/35042430/176098354-38bc14b3-0a14-4048-993a-61fef5a9a8ef.png)

Step 2:

![image](https://user-images.githubusercontent.com/35042430/176098366-f72accdd-58ea-42d9-b8ff-e291741f8b68.png)
![image](https://user-images.githubusercontent.com/35042430/176098381-b9254546-08c7-4f97-ad1f-8ee87821b8fb.png)
![image](https://user-images.githubusercontent.com/35042430/176098374-5fdf11b7-e534-4301-889e-16f70695300b.png)


__Test Case No: 4__

|Step Name	|Description						|Expected Result			|	
|--		|--							|--					|
|Step 1		|Enter SN currently at open Pack			|Display SN details in info cards, tracking info in tracking table, and list of station SN previously passed |
|Step 2		|Select CK PMDU from station drop-down in Change Station section |Display success message. Display updated details in info cards. Update records in Pack table and delete record from Pack Serial Number table	|

Step 1:

![image](https://user-images.githubusercontent.com/35042430/176121618-9472a9c8-279c-4cdf-a196-cd6bd2c38b19.png)
![image](https://user-images.githubusercontent.com/35042430/176121627-a33206fc-a750-4a46-9106-3b9ce49581b1.png)
![image](https://user-images.githubusercontent.com/35042430/176121642-f9b78923-fb63-4a14-8fbc-18c007ae6a6f.png)

Step 2:

![image](https://user-images.githubusercontent.com/35042430/176121666-dab7806d-a3a8-4094-886e-3e997ecb9dcc.png)
![image](https://user-images.githubusercontent.com/35042430/176121679-1bcc745a-0eca-49e2-ad1e-e202bc09db6a.png)
![image](https://user-images.githubusercontent.com/35042430/176121691-5ac1d7f0-0c19-4f93-b710-a345701cfa58.png)

__Test Case No: 5__

|Step Name	|Description						|Expected Result			|	
|--		|--							|--					|
|Step 1		|Enter SN from an SAP Confirmed WO			|Display SN details in info cards, tracking info in tracking table, and list of station SN previously passed |
|Step 2		|Select ASSY 5 from station drop-down in Change Station section	|Display BPL Approval dialog 	|
|Step 3		|Enter BPL credentials and click on Approve button 	|Display success message. Display full name of BPL. Update records in SN Tracking Confirmation table, Work Order table, SAP Upload Process table, SAP Upload Data table, Serial Number table, Serial Number track table	|

Step 1: 
![image](https://user-images.githubusercontent.com/35042430/176122092-6164ae19-d076-44b6-9373-a1c7df5134a5.png)
![image](https://user-images.githubusercontent.com/35042430/176122106-c3acc0fb-0036-42db-94be-2d91bf7759d6.png)
![image](https://user-images.githubusercontent.com/35042430/176122127-25371ac1-dfa0-457c-ad29-5c3aa90a73d7.png)
![image](https://user-images.githubusercontent.com/35042430/176122146-9d9380f4-39c1-4553-9dc8-f5bca4359b2e.png)
![image](https://user-images.githubusercontent.com/35042430/176122169-d6ab7ce8-5669-4c65-b169-991c4aec5343.png)
![image](https://user-images.githubusercontent.com/35042430/176122180-36b9ee5e-290a-4f8b-9689-3c1d3de1bc87.png)
![image](https://user-images.githubusercontent.com/35042430/176122188-0f8a7d5a-b2d7-4a31-a664-1d7db9611dee.png)
![image](https://user-images.githubusercontent.com/35042430/176122197-72594345-2859-4365-97aa-cc1835f8d082.png)

Step 2:

![image](https://user-images.githubusercontent.com/35042430/176122287-c891966d-4538-4b02-b141-1c8765d45069.png)

Step 3:

![image](https://user-images.githubusercontent.com/35042430/176122324-7cc1a878-524c-4c7b-8903-e0a4209e1cc5.png)
![image](https://user-images.githubusercontent.com/35042430/176122344-b8e6e21e-d28a-4317-a1fd-c905f664269b.png)
![image](https://user-images.githubusercontent.com/35042430/176122366-502113fa-d393-44e1-b004-45980e29adf6.png)
![image](https://user-images.githubusercontent.com/35042430/176122378-84cbc9b2-29c7-4402-be03-11ac7ada0f9e.png)
![image](https://user-images.githubusercontent.com/35042430/176122392-4165d7aa-2d7b-470b-b916-bb8910e3fc35.png)
![image](https://user-images.githubusercontent.com/35042430/176122396-058aff99-478b-4f5e-8d67-1ae7ce29bb39.png)

__Test Case No: 6__

|Step Name	|Description						|Expected Result			|	
|--		|--							|--					|
|Step 1		|Enter SN currently at a FINISH station			|Display SN details in info cards, tracking info in tracking table, and list of station SN previously passed |
|Step 2		|Select ASSY 1 from station drop-down in Change Station section	|Display success message. Display full name of BPL. Update records in SN Tracking Confirmation table, Work Order table, SAP Upload Process table, SAP Upload Data table, Serial Number table,  Serial Number track table 	|
	
Step 1: 

![image](https://user-images.githubusercontent.com/35042430/176122827-12aa3280-74af-4cbd-b713-d65784aebf0f.png)
![image](https://user-images.githubusercontent.com/35042430/176122839-46ae818d-22d4-4d45-858c-b75b6a307f62.png)
![image](https://user-images.githubusercontent.com/35042430/176122845-92467abe-2fd1-46dc-b9dd-2d6ed8c1c9c9.png)
![image](https://user-images.githubusercontent.com/35042430/176122879-f8222d94-bd3a-47a0-b4bd-a8741189fa7e.png)
![image](https://user-images.githubusercontent.com/35042430/176122909-f020671f-2b43-45d7-ac92-8980c0cfc37a.png)
![image](https://user-images.githubusercontent.com/35042430/176122921-2e0572a9-5a4b-4538-87a4-3d02d184378c.png)
![image](https://user-images.githubusercontent.com/35042430/176122933-16ced23b-c513-40dd-90c4-679c3ed2e0c1.png)

Step 2:

![image](https://user-images.githubusercontent.com/35042430/176123004-9c2ab65c-9064-4b65-aefc-c87dab16d8b5.png)
![image](https://user-images.githubusercontent.com/35042430/176123012-ffa862ad-9f9c-4e0b-81dc-a3557f5f6256.png)
![image](https://user-images.githubusercontent.com/35042430/176123023-b76a5418-2fe2-4c39-aa6b-1a88f8b332e5.png)
![image](https://user-images.githubusercontent.com/35042430/176123051-1a1f76bf-6d3d-4edc-9434-94d5b97389fc.png)
![image](https://user-images.githubusercontent.com/35042430/176123058-3d635b23-92a7-4c60-b984-c61208a996d0.png)
![image](https://user-images.githubusercontent.com/35042430/176123076-ed6b7443-ddaf-4962-8864-32bf3cf60c71.png)

__Test Case No: 7 - 24__

__Test Case No: 7 - No Serial Number in record__

![image](https://user-images.githubusercontent.com/35042430/176123369-a7e782f9-c03a-4bdb-a34a-f06e4a29c18f.png)
	
_Test Case No: 8 – Input is Empty_
	
![image](https://user-images.githubusercontent.com/35042430/176123560-901c73c9-a6f0-43ae-aa3d-04114adf14f1.png)
	
_Test Case No: 10 – SN Currently in Palletize/Preship Station_

![image](https://user-images.githubusercontent.com/35042430/176123630-f36a9a0c-a271-4a8d-b732-bbaff6d50d56.png)
	
_Test Case No: 11 – SN Already Shipped_

![image](https://user-images.githubusercontent.com/35042430/176123728-c23022cc-6d93-4047-b029-5862208ae461.png)

_Test Case No: 13 – SN Currently On Hold_
	
![image](https://user-images.githubusercontent.com/35042430/176123806-cfef21ca-000d-4da5-97a0-cf4261f146c7.png)

_Test Case No: 14 – SN Currently in Repair_
	
![image](https://user-images.githubusercontent.com/35042430/176123892-7a0e47d1-acfe-42f7-a8dd-1dbc4b0b267f.png)

_Test Case No: 15 – SN Currently in Repair_

![image](https://user-images.githubusercontent.com/35042430/176123955-c20e5626-57b4-4ccb-bc2e-3ba3313d1161.png)
	
_Test Case No: 18 – New Station is Same as Current Station_
	
![image](https://user-images.githubusercontent.com/35042430/176123999-f2fc986c-aebe-4f9e-b389-f10ebbad89b2.png)
	
_Test Case No: 20 – New Station Appears in UDE List_
	
![image](https://user-images.githubusercontent.com/35042430/176124052-4c43b359-7c4d-4559-80aa-c349a3ae934b.png)
	
_Test Case No: 21 – Closed Pack in Pallet_
	
![image](https://user-images.githubusercontent.com/35042430/176124150-c232b17b-634a-4291-a530-1a4c29146d0c.png)
	
_Test Case No: 22 – Testing Station Between New Station and Current Station_

![image](https://user-images.githubusercontent.com/35042430/176124251-4e131038-9e9b-4664-932a-471063302ca5.png)
	
_Test Case No: 23 – New Station After FINISH Station_
	
![image](https://user-images.githubusercontent.com/35042430/176124298-5c2f5f7d-711b-4e15-94ef-325d0ad11490.png)
	
_Test Case No: 24 – Wrong BPL Approval_

![image](https://user-images.githubusercontent.com/35042430/176124389-ebfedd81-6c6f-427b-afb7-a5f65c219501.png)

![image](https://user-images.githubusercontent.com/35042430/176124388-570682de-17c2-4be6-9aac-ca14bd0472d9.png)

	

	

![image](https://user-images.githubusercontent.com/35042430/175477730-364c4a53-3452-4799-a9b2-e39e6b1f524a.png)
