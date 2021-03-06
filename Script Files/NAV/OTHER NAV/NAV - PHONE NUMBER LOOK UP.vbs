'This script can be used to look up clients in the REPT/ACTV. This could be useful when checking voicemails if the client garbles their name or has a difficult name to look up or if you just want an easier way of checking your REPT screens.

'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "NAV - PHONE NUMBER LOOK UP"
start_time = timer

''LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN 'Shouldn't load FuncLib if it already loaded once
	 IF run_locally = FALSE or run_locally = "" THEN 'If the scripts are set to run locally, it skips this and uses an FSO below.
		 IF default_directory = "C:\DHS-MAXIS-Scripts\Script Files\" THEN 'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			 FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		 ELSEIF beta_agency = "" or beta_agency = True then 'If you're a beta agency, you should probably use the beta branch.
			 FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/BETA/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		 Else 'Everyone else should use the release branch.
			 FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		 End if
			 SET req = CreateObject("Msxml2.XMLHttp.6.0") 'Creates an object to get a FuncLib_URL
			 req.open "GET", FuncLib_URL, FALSE 'Attempts to open the FuncLib_URL
			 req.send 'Sends request
			 IF req.Status = 200 THEN '200 means great success
			 Set fso = CreateObject("Scripting.FileSystemObject") 'Creates an FSO
			 Execute req.responseText 'Executes the script code
		 ELSE 'Error message, tells user to try to reach github.com, otherwise instructs to contact Veronica with details (and stops script).
			 MsgBox "Something has gone wrong. The code stored on GitHub was not able to be reached." & vbCr &_
			 vbCr & _
			 "Before contacting Veronica Cary, please check to make sure you can load the main page at www.GitHub.com." & vbCr &_
			 vbCr & _
			 "If you can reach GitHub.com, but this script still does not work, ask an alpha user to contact Veronica Cary and provide the following information:" & vbCr &_
			 vbTab & "- The name of the script you are running." & vbCr &_
			 vbTab & "- Whether or not the script is ""erroring out"" for any other users." & vbCr &_
			 vbTab & "- The name and email for an employee from your IT department," & vbCr & _
			 vbTab & vbTab & "responsible for network issues." & vbCr &_
		 	vbTab & "- The URL indicated below (a screenshot should suffice)." & vbCr &_
		 	vbCr & _
		 	"Veronica will work with your IT department to try and solve this issue, if needed." & vbCr &_
		 	vbCr &_
		 	"URL: " & FuncLib_URL
			 script_end_procedure("Script ended due to error connecting to GitHub.")
		 END IF
	 ELSE
		 FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		 Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		 Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		 text_from_the_other_script = fso_command.ReadAll
		 fso_command.Close
		 Execute text_from_the_other_script
	 END IF
END IF


BeginDialog search_dialog, 0, 0, 186, 135, "Client Look Up"
  EditBox 120, 10, 55, 15, phone_look_up
  EditBox 120, 65, 55, 15, case_load_look_up
  DropListBox 115, 90, 60, 15, "REPT/ACTV"+chr(9)+"REPT/INAC"+chr(9)+"REPT/PND1"+chr(9)+"REPT/PND2"+chr(9)+"REPT/REVW", search_where
  ButtonGroup ButtonPressed
    OkButton 45, 115, 50, 15
    CancelButton 95, 115, 50, 15
  Text 5, 10, 105, 25, "Phone number to search. 10 Digit format(including area code). Do not include spaces or dashes"
  Text 5, 70, 115, 10, "Worker/Team Number (x######):"
  Text 5, 45, 160, 15, "NOTE: Leave the following edit box BLANK to search your own case load."
  Text 5, 90, 100, 10, "Where to search:"
EndDialog


EMConnect ""

CALL check_for_MAXIS(TRUE)

call find_variable("User: ", user_number, 7)

DO
  DIALOG search_dialog
  IF ButtonPressed = 0 THEN stopscript
  IF len(case_load_look_up) = 3 THEN case_load_look_up = worker_county_code & case_load_look_up
LOOP UNTIL case_load_look_up = "" OR (len(case_load_look_up) = 7 AND (ucase(LEFT(case_load_look_up, 1) = "X") or lcase(LEFT(case_load_look_up, 1) = "x")))

phone_look_up = replace(phone_look_up, " ", "")
phone_look_up = replace(phone_look_up, "-", "")



'========== Checks REPT/ACTV ==========
IF search_where = "REPT/ACTV" THEN 
  Call navigate_to_MAXIS_screen("rept", "actv")
  IF case_load_look_up <> "" and ucase(user_number) <> ucase(case_load_look_up) THEN
    EMWriteScreen case_load_look_up, 21, 13
    transmit
  END IF
  Do
	MAXIS_row = 7
	EMReadScreen last_page_check, 21, 24, 2
	Do
		EMReadScreen case_number, 8, MAXIS_row, 12
		If case_number = "        " then exit do
		case_number = replace(case_number, " ", "")
		case_number_array = case_number_array & " " & case_number
		MAXIS_row = MAXIS_row + 1
	Loop until MAXIS_row = 19
	PF8
  Loop until last_page_check = "THIS IS THE LAST PAGE"
END IF

'========== Checks REPT/INAC ==========
IF search_where = "REPT/INAC" THEN
  Call navigate_to_MAXIS_screen("rept", "inac")
  IF case_load_look_up <> "" and ucase(user_number) <> ucase(case_load_look_up) THEN
    EMWriteScreen case_load_look_up, 21, 16
    transmit
  END IF

  DO
    MAXIS_row = 7
    DO
	  EMReadScreen case_number, 8, MAXIS_row, 3
	  If case_number = "        " then exit do
	  case_number = replace(case_number, " ", "")
	  case_number_array = case_number_array & " " & case_number
        MAXIS_row = MAXIS_row + 1
    LOOP UNTIL MAXIS_row = 19
    PF8
    EMReadScreen last_page_check, 21, 24, 2
  LOOP UNTIL last_page_check = "THIS IS THE LAST PAGE"
END IF

'========== Checks REPT/PND1 ==========
IF search_where = "REPT/PND1" THEN
  Call navigate_to_MAXIS_screen("rept", "pnd1")
  IF case_load_look_up <> "" and ucase(user_number) <> ucase(case_load_look_up) THEN
    EMWriteScreen case_load_look_up, 21, 13
    transmit
  END IF

  DO
    MAXIS_row = 7
    DO
        EMReadScreen case_number, 8, MAXIS_row, 3
	  If case_number = "        " then exit do
	  case_number = replace(case_number, " ", "")
	  case_number_array = case_number_array & " " & case_number
        MAXIS_row = MAXIS_row + 1
    LOOP UNTIL MAXIS_row = 19
    PF8
    EMReadScreen last_page_check, 21, 24, 2	
  LOOP UNTIL last_page_check = "THIS IS THE LAST PAGE"
END IF

'========== Checks REPT/PND2 ==========
IF search_where = "REPT/PND2" THEN
  Call navigate_to_MAXIS_screen("rept", "pnd2")
  IF case_load_look_up <> "" and ucase(user_number) <> ucase(case_load_look_up) THEN
    EMWriteScreen case_load_look_up, 21, 13
    transmit
  END IF

  DO
    MAXIS_row = 7
    DO
        EMReadScreen case_number, 8, MAXIS_row, 5
	  If case_number = "        " then exit do
	  case_number = replace(case_number, " ", "")
	  case_number_array = case_number_array & " " & case_number
        MAXIS_row = MAXIS_row + 1
    LOOP UNTIL MAXIS_row = 19
    PF8
    EMReadScreen last_page_check, 21, 24, 2	
  LOOP UNTIL last_page_check = "THIS IS THE LAST PAGE"
END IF

'========== Checks REPT/REVW ==========
IF search_where = "REPT/REVW" THEN
  Call navigate_to_MAXIS_screen("rept", "REVW")
  IF case_load_look_up <> "" and ucase(user_number) <> ucase(case_load_look_up) THEN
    EMWriteScreen case_load_look_up, 21, 6
    transmit
  END IF

  DO
    MAXIS_row = 7
    DO
        EMReadScreen case_number, 8, MAXIS_row, 6
	  If case_number = "        " then exit do
	  case_number = replace(case_number, " ", "")
	  case_number_array = case_number_array & " " & case_number
        MAXIS_row = MAXIS_row + 1
    LOOP UNTIL MAXIS_row = 19
    PF8
    EMReadScreen last_page_check, 21, 24, 2
  LOOP UNTIL last_page_check = "THIS IS THE LAST PAGE"
END IF

'========== Checking ADDR against reported phone number =====================
'cleaning up array
case_number_array = TRIM(case_number_array)
case_number_array = SPLIT(case_number_array)

FOR EACH case_number in case_number_array
	back_to_self
	EMwritescreen "          ", 18, 43
	EMwritescreen case_number, 18, 43
	CALL navigate_to_MAXIS_screen("STAT", "ADDR")
	row = 1
	col = 1
	EMSearch "PRIVILEGED", row, col
	IF row <> 0 THEN msgbox case_number
	IF row = 0 THEN
		EMReadscreen area_code_1, 3, 17, 45
		EMReadscreen addr_phone_number_1, 8, 17, 51
		EMReadscreen area_code_2, 3, 18, 45
		EMReadscreen addr_phone_number_2, 8, 18, 51
		EMReadscreen area_code_3, 3, 19, 45
		EMReadscreen addr_phone_number_3, 8, 19, 51
		complete_phone_1 = area_code_1 & replace(addr_phone_number_1, " ", "")
		complete_phone_2 = area_code_2 & replace(addr_phone_number_2, " ", "")
		complete_phone_3 = area_code_3 & replace(addr_phone_number_3, " ", "")
		IF complete_phone_1 = phone_look_up OR complete_phone_2 = phone_look_up OR complete_phone_3 = phone_look_up then script_end_procedure(case_number & " contains requested phone number " & phone_look_up & ".")
		CALL navigate_to_MAXIS_screen("STAT", "AREP")
		EMReadscreen arep_area_code_1, 3, 8, 34
		EMReadscreen arep_phone_number_1, 8, 8, 40
		EMReadscreen arep_area_code_2, 3, 9, 34
		EMReadscreen arep_phone_number_2, 8, 9, 40
		arep_complete_phone_1 = arep_area_code_1 & replace(arep_phone_number_1, " ", "")
		arep_complete_phone_2 = arep_area_code_2 & replace(arep_phone_number_2, " ", "")
		IF arep_complete_phone_1 = phone_look_up OR arep_complete_phone_2 = phone_look_up then script_end_procedure("AREP on case " & case_number & " contains requested phone number " & phone_look_up & ".")

	
	END IF
NEXT

script_end_procedure(phone_look_up & " was not found in selected REPT. Feel free to try another REPT list, change your footer month, or verify that the number you entered is correct")
