# PowerShell Script to check for Dormant Accounts in MS AD Domain
# Created by Mohamed Al-Shabrawy
#
# It requires PowerShell AD Tools module to be installed 
#
# Use below command line to install under Administrator privilege
#
# "dism /online /enable-feature /all /featurename:ActiveDirectory-PowerShell"
#
# Script will generate 4 files:
#   - List of disabled accounts
#   - List of inactive accounts
#   - List of old password accounts
#   - Log file
# All files will be overwritten everytime script is executed.
# Calculations is based on 45 Days period.
