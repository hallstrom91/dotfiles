#!/usr/bin/env bash
#  date +'%A, %d %B'  ===  Day, 10, Month
#  date +'%Y, %m, %d' === year-month-day
#  date +'%d/%m-%Y' === day-month-year

# LC_TIME=sv_SE.UTF.8 # use eng ?

printf '%s\n%s' "$(date +%H:%M)" "$(date +'%Y-%m-%d')"
