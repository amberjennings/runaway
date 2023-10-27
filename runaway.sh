#!/bin/bash
# Amber Jennings - 2023

## Potential Improvements: ##
# - Add a specific timeout for unreachable hosts
# - Add some level of interactivity
# - Add better error handling
# - Have the option to run checks only on specific hosts

# Check if there is an existing Kerberos ticket, generate one if not. 
krenew || until kinit; do sleep 1; done

# Iterate through netgrouplist for machines in the group linux-login-sys
readarray -t machines <<< "$(netgrouplist linux-login-sys)"

# Loop through output
for machine in "${machines[@]}"; do
    machine=$(echo "$machine" | tr -d '\n')
    echo "Checking machine: $machine"
    ssh "$machine" 'ps ax -o user,group,pcpu,pmem,etimes,pid,comm' | grep them | awk -v machine="$machine" '
        {
            # Check for certain criteria
            if ( ($5 > 3600) && (($3 > 40) || ($4 > 30)) ) {
                # Print processes that meet said criteria
                print "Machine:", machine, "User:", $1, "PID:", $6, "Group:", $2, "CPU%:", $3, "Memory%:", $4, "Time(seconds):", $5, "Process Name:", $7
            }
        }' & # Run all the SSH processes at once to speed up the script significantly

done
wait

