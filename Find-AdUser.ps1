# Returns UserPrincipalName, First Name and Display Name as $Upn, $FName and $DName to be used elsewhere in a script
Function Find-AdUser ($Uinput) { 
	If (-not ($UInput) ){
		# Enter part of name
		$Uinput = Read-Host -prompt "Enter part of a users name to find"
	}
	# Display results
	[array]$users = Get-ADUser -Filter {anr -like $Uinput} -properties emailAddress
	# If no matches found
	If ($users.count -lt 1) {
		Write-Host `t"Sorry, no matching users found" -fore red
		$choice = Read-Host -prompt "Try again? [Yes] or No"
		while ("y", "yes", "n", "no", ""  -notcontains $choice) {
			$choice = Read-Host "Please enter yes or no"
		}
		if ("y", "yes", "" -contains $choice) {
			. Find-AdUser
		}
		ElseIf ("n", "no" -contains $choice) {return}
	}
	Else {
		# If multiple matches found
		If ($users.count -gt 1) {
			# Loop through them and add to an object
			$results = Foreach ($u in $users) {
				[pscustomobject]@{
					Number = ([array]::indexof($users, $u))+1
					Name = $u.name
					Email = $u.emailAddress				
				}
			}
			# Output the results using a custom format
			$originalColor = $Host.UI.RawUI.ForegroundColor
			Write-Host `n"Found the following possible matches:" -fore green
			$format = 	@{Label="Number"; Expression={If($_.number % 2){[console]::ForegroundColor="white";$_.number}Else{[console]::ForegroundColor="cyan";$_.number}}; width=15; Alignment="center"},
					@{Label="Name"; Expression={$_.name}; width=30},
					@{Label="Email Address"; Expression={$_.email}; width=50}
			$results | ft $format
			$Host.UI.RawUI.ForegroundColor = $originalColor
			# Prompt for a choice from the above results
			$Uchoice = Read-Host -prompt `n"Enter a number from above"
			If (1..$users.count -notcontains $Uchoice) {
				Write-Host "Nice try, now enter a number from above"
				Do {
					$Uchoice = Read-Host -prompt "Number"
				}
				Until (1..$users.count -contains $Uchoice)
			}
			Write-Host `n`t"$($users[[int]$Uchoice -1].name) ($($users[[int]$Uchoice -1].userPrincipalName)) " -nonewline
			Write-Host "selected"`n -fore green
			$Upn = $($users[[int]$Uchoice -1].userPrincipalName)
			$FName = $($users[[int]$Uchoice -1].givenName)
			$DName = $($users[[int]$Uchoice -1].name)
		}
		# If only one match was found
		Else {
			$Uchoice = 0
			Write-Host `n`t"$($users[[int]$Uchoice].name) ($($users[[int]$Uchoice].userPrincipalName))" -nonewline
			Write-Host "selected"`n -fore green
			$Upn = $($users[[int]$Uchoice].userPrincipalName)
			$FName = $($users[[int]$Uchoice -1].givenName)
			$DName = $($users[[int]$Uchoice -1].name)
		}
	}
}
