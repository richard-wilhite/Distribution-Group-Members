# Distribution Group Members

### Summary
Pulls a listing of groups from Exchange Online and adds a listing of members.

### Optional Configuration Steps
* Line 4 "outputFields" can be updated to include any other properties from the Exchange Group object.
* Lines 32 & 49 "memberCollection.Add" can also be updated to include more information from the Group Members object.

You may also need to adjust the authentication mechanism. I created this to be used with a service account, but if you are using MFA you will need to run the Connect-EXOPSession command and then just use the code after 'Write-Host "Retrieving Exchange Groups"'.
