$Temp_folder = $env:TEMP
$Windir_folder = $env:windir
$Deployment_Logs = "$Windir_folder\Temp\DeploymentLogs"
$Results_File = "$Deployment_Logs\Results.xml"

$System_Root = $env:SystemRoot;
$System_Drive = $env:SystemDrive;

$SMSTSLog_folder = "$Temp_folder\SMSTSLog"

$Panther_folder = "$System_Root\Panther"
$DISM_folder = "$System_Root\Logs\DISM"
$Debug_folder = "$System_Root\debug"

$OSD_Logs_Folder = "C:\OSD_Logs"
$Deploy_Logs_Folder = "$OSD_Logs_Folder\Deploy_Logs"
$System_Logs_Folder = "$OSD_Logs_Folder\System_Logs"
$EVTX_Logs_Folder = "$System_Logs_Folder\Events_Logs"


While (!(test-path $Results_File))
{	
	write-host "No result file"
	sleep 2
}


[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}


########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
#																		 VARIABLES DEFINITION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################

$object = New-Object -comObject Shell.Application  
$User = $env:USERNAME
$Date = get-date -format "dd/MM/yyyy hh:mm:ss"
$Global:Current_Folder =(get-location).path 

########################################################################################################################################################################################################	
#*******************************************************************************************************************************************************************************************************
# 																		BUTTONS AND LABELS INITIALIZATION 
#*******************************************************************************************************************************************************************************************************
########################################################################################################################################################################################################


###################################################################################################################################
# Part to the GUI display
###################################################################################################################################

If ((Test-path $Results_File))
	{
		$Input_Status = [xml] (Get-Content $Results_File)		
		foreach ($data in $Input_Status.selectNodes("Results"))		
			{			
				$Global:Errors_NB = $data.Errors
				$Global:Warnings_NB = $data.Warnings
				$Global:RetVal_Value = $data.RetVal
				$Global:DeploymentType_Value = $data.DeploymentType
				$Global:Messages_Value = $data.Messages
			}	

		# Set the background color based on the return code
		If (($RetVal_Value -eq 0) -or ($RetVal_Value -eq ""))
			{
				$XamlMainWindow=LoadXml("Summary_OK.xaml")
				$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
				$Form=[Windows.Markup.XamlReader]::Load($Reader)	
				
				If (($Errors_NB -gt 0) -or ($Warnings_NB -gt 0))
					{
						$Error_Warning_Resume = $Form.findname("Error_Warning_Resume") 
						$Block_Message = $Form.findname("Block_Message") 
						$Message_Error_Warning = $Form.findname("Message_Error_Warning") 	
						
						$Error_Warning_Resume.Foreground = "Orange"
						$Error_Warning_Resume.FontWeight = "Bold"	 						
						
						If ($Messages_Value -ne "")
							{								
								$Block_Message.Visibility = "Visible"
								$Message_Error_Warning.Text = $Messages_Value.innertext								
							}
						Else
							{
								$Block_Message.Visibility = "Collapsed"													
							}
					}
				Else
					{
						$Error_Warning_Resume = $Form.findname("Error_Warning_Resume")
						$Block_Message = $Form.findname("Block_Message") 
						$Block_Message.Visibility = "Collapsed"						
					}							
			}
		Else
			{
				# Load MainWindow
				$XamlMainWindow=LoadXml("Summary_KO.xaml")
				$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
				$Form=[Windows.Markup.XamlReader]::Load($Reader)	

				$Temp_folder = $env:TEMP
				$Windir_folder = $env:windir
				$Deployment_Logs = "$Windir_folder\Temp\DeploymentLogs"
				$Results_File = "$Temp_folder\Results.xml"
				$Global:Test_Results_File = test-path $Results_File				
			}

		$Main_Title = $Form.findname("Main_Title") 
		$Description_title = $Form.findname("Description_title") 
		$Error_Warning_Resume = $Form.findname("Error_Warning_Resume") 

		$View_Logs = $Form.findname("View_Logs") 
		$Finish = $Form.findname("Finish") 
		$Message_Error_Warning = $Form.findname("Message_Error_Warning") 
		$ExpanderControl = $Form.findname("ExpanderControl") 
		$Summary_Resume = $Form.findname("Summary_Resume") 	
			
	}
Else
	{
		$XamlMainWindow=LoadXml("Summary_KO.xaml")
		$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
		$Form=[Windows.Markup.XamlReader]::Load($Reader)	

		$Main_Title = $Form.findname("Main_Title") 
		$Description_title = $Form.findname("Description_title") 
		$Error_Warning_Resume = $Form.findname("Error_Warning_Resume") 	

		$View_Logs = $Form.findname("View_Logs") 
		$Finish = $Form.findname("Finish") 
		$Message_Error_Warning = $Form.findname("Message_Error_Warning") 
		$ExpanderControl = $Form.findname("ExpanderControl") 
		$Summary_Resume = $Form.findname("Summary_Resume") 	
	}
	



###################################################################################################################################
# Part to change text
###################################################################################################################################

# Load the results
If (Test-path $Results_File)
	{
		If (($RetVal_Value -eq 0) -or ($RetVal_Value -eq ""))
			{
				# If this is a replace, then modifiy the title
				If ($DeploymentType_Value -eq "REPLACE")
					{
						$Main_Title.Content = "The user state capture was completed successfully."
						$Main_Title.FontSize="16"
						$Main_Title.Foreground="Green"
						$Main_Title.FontWeight="Bold"
						
						$Description_title.Content = "The computer is now ready to use"
						$Description_title.FontSize="14"
					
						$Error_Warning_Resume.Content = "During the deployment process, $Errors_NB errors and $Warnings_NB warnings were reported"	
						$Error_Warning_Resume.FontSize = "14"					
					}
				Else
					{
						$Main_Title.Content = "Installation completed successfully"
						$Main_Title.FontSize="16"
						$Main_Title.Foreground="Green"
						$Main_Title.FontWeight="Bold"	

						$Description_title.Content = "The computer is now ready to use"
						$Description_title.FontSize="14"
					
						$Error_Warning_Resume.Content = "During the deployment process, $Errors_NB errors and $Warnings_NB warnings were reported"	
						$Error_Warning_Resume.FontSize = "14"	
					}	
			}
			
		Else
			{
				# If this is a replace, then modifiy the title
				If ($DeploymentType_Value -eq "REPLACE")
					{
						$Main_Title.Content = "The user state capture did not complete successfully."
						$Main_Title.FontSize="16"
						$Main_Title.Foreground="Red"
						$Main_Title.FontWeight="Bold"
						
						$Description_title.Content = "Please review the log files to determine the cause of the problem."
						$Description_title.FontSize="14"
					
						$Error_Warning_Resume.Content = "During the deployment process, $Errors_NB errors and $Warnings_NB warnings were reported"	
						$Error_Warning_Resume.FontSize = "14"		

						$Message_Error_Warning.FontSize = "14" 	
						
						If ($Messages_Value -eq "")
							{
								$Message_Error_Warning.Text = "No messages"		
								$Message_Error_Warning.FontSize = "15" 			
								$Message_Error_Warning.Text = "No messages"	
								$Message_Error_Warning.HorizontalAlignment = "Center"
								$Message_Error_Warning.Margin = "0,50,0,0"	
								$Message_Error_Warning.FontWeight = "Bold"								
							}
						Else
							{
								$Message_Error_Warning.Text = $Messages_Value.innertext														
							}
					}
				Else
					{
						$Main_Title.Content = "Installation did not complete successfully."
						$Main_Title.FontSize="16"
						$Main_Title.Foreground="Red"
						$Main_Title.FontWeight="Bold"	

						$Description_title.Content = "Please review the log files to determine the cause of the problem."
						$Description_title.FontSize="14"
					
						$Error_Warning_Resume.Content = "During the deployment process, $Errors_NB errors and $Warnings_NB warnings were reported"	
						$Error_Warning_Resume.FontSize = "14"	
						
						$Message_Error_Warning.FontSize = "14" 	
						
						If ($Messages_Value -eq "")
							{
								$Message_Error_Warning.Text = "No messages"			
								$Message_Error_Warning.FontSize = "15" 			
								$Message_Error_Warning.Text = "No messages"	
								$Message_Error_Warning.HorizontalAlignment = "Center"
								$Message_Error_Warning.Margin = "0,50,0,0"	
								$Message_Error_Warning.FontWeight = "Bold"								
							}
						Else
							{
								$Message_Error_Warning.Text = $Messages_Value.innertext														
							}												
					}					
			}
	}
Else
	{
		$Main_Title.Content = "Unable to locate the Results.xml file needed to determine the deployment results."
		$Main_Title.FontSize = "16"
		$Main_Title.Foreground = "Red"

		$Description_title.Content = "(This may be the result of mismatched script versions.  Ensure all boot images have been updated.)"
		$Description_title.FontSize="14"		
				
		$Errors_NB = "0"
		$Warnings_NB = "1"		
		
		$Message_Error_Warning.FontSize = "15" 			
		$Message_Error_Warning.Text = "Can not find the Results.xml file"	
		$Message_Error_Warning.HorizontalAlignment = "Center"
		$Message_Error_Warning.Margin = "0,50,0,0"	
		$Message_Error_Warning.FontWeight = "Bold"
	}


	
$View_Logs.Add_Click({	
	invoke-item $Deployment_Logs		
})	



$Finish.Add_Click({	
	New-item $OSD_Logs_Folder -type directory -force
	New-item $Deploy_Logs_Folder -type directory -force
	New-item $EVTX_Logs_Folder -type directory -force
	
	# Copy deployment logs in the W10_Deployment_Logs folder
	copy-item $Deployment_Logs $Deploy_Logs_Folder -force -recurse
	copy-item $SMSTSLog_folder $Deploy_Logs_Folder -force -recurse

	# copy System logs in the System_logs folder
	copy-item $Panther_folder $System_logs_folder -force -recurse
	copy-item $DISM_folder $System_logs_folder -force -recurse
	copy-item $Debug_folder $System_logs_folder -force -recurse	
	
	# generate EVTX
	wevtutil epl system "$EVTX_Logs_Folder\System_logs.evtx"
	wevtutil epl Application "$EVTX_Logs_Folder\Application_logs.evtx"			
	wevtutil epl Setup "$EVTX_Logs_Folder\Setup_logs.evtx"	
	
	$Form.Close()	
})	


$Form.Add_Closing({
	New-item $OSD_Logs_Folder -type directory -force
	New-item $Deploy_Logs_Folder -type directory -force
	New-item $EVTX_Logs_Folder -type directory -force
	
	# Copy deployment logs in the W10_Deployment_Logs folder
	copy-item $Deployment_Logs $Deploy_Logs_Folder -force -recurse
	copy-item $SMSTSLog_folder $Deploy_Logs_Folder -force -recurse

	# copy System logs in the System_logs folder
	copy-item $Panther_folder $System_logs_folder -force -recurse
	copy-item $DISM_folder $System_logs_folder -force -recurse
	copy-item $Debug_folder $System_logs_folder -force -recurse	
	
	# generate EVTX
	wevtutil epl system "$EVTX_Logs_Folder\System_logs.evtx"
	wevtutil epl Application "$EVTX_Logs_Folder\Application_logs.evtx"			
	wevtutil epl Setup "$EVTX_Logs_Folder\Setup_logs.evtx"	
	
	$Form.Close()	
})	

$Form.ShowDialog() | Out-Null
