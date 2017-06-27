#!/bin/bash

# NOTE : If your Mac System backing time in 2013, try first to delete /Library/LaunchDaemons/com.lsreset.plist

# Uncomment for debug
#set -x

# Check if bad year
is_2013() {
 YEAR=$(sudo /usr/sbin/systemsetup -getdate | cut -d '/' -f 3)
 if [ $YEAR == "2013" ]; then return 0; else return 1; fi
}

http_date_ud() {
 # First method, update system time with "date" command	
 sudo date -f "%a, %d %b %Y %H:%M:%S %Z" "$1"

 # Second method, update system time with "systemsetup" command
 if is_2013 $1; then
  NDATE=$(date -j -f "%a, %d %b %Y %H:%M:%S %Z" "$1" "+%m:%d:%y")
  printf "$NDATE"
  NTIME=$(echo "$1" | cut -d' ' -f5)
  printf "$NTIME"
  sudo /usr/sbin/systemsetup -setusingnetworktime off
  sudo /usr/sbin/systemsetup -setdate $NDATE
  sudo /usr/sbin/systemsetup -settime $NTIME
  sudo /usr/sbin/systemsetup -setusingnetworktime on
 fi
}

# 1°/ Trying with ntpdate on Apple + NTP global time servers
if is_2013 $1; then ntpdate -t 4 -u time.apple.com; else exit 0; fi
if is_2013 $1; then ntpdate -t 4 -u pool.ntp.org; else exit 0; fi

# 2°/ Trying with sntp with Apple + NTP local time servers
if is_2013 $1; then sntp -s time.euro.apple.com; else exit 0; fi
if is_2013 $1; then sntp -s fr.pool.ntp.org; else exit 0; fi

# 3°/ Trying with HTTP header
HTTP_DATE=$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f4-9)
lc_tmp=$LC_ALL && LC_ALL=C
http_date_ud "$HTTP_DATE"
LC_ALL=lc_tmp