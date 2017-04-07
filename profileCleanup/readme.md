This script will remove profiles older than XX days (60 by default) from a windows machine.

Configurable Variables:
  $numDaysOld = How many days since the last modify/login date.
  $IgnoreList = SID of the account(s) you wish to ignore.
  $logFile    = Path to a log file that will track what computers it has been ran on and how many profiles were removed.
        tip: Granting access to the "Domain Computers" group on a shared network folder will allow this to be deployed and still      gather statistics.
