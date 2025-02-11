#!/bin/bash

echo "Forensic.bash for forensics in a Linux environment"
echo "by Team_Bocchi_The_Forensic"
echo "Version 0.04c"
echo

# Create a Timestamp
timestamp=$(date +"%Y-%m-%d %T")
echo "Timestamp : $timestamp" > ../mnt2/Forensic_Info.txt
echo "Timestamp has been saved in Forensic_Info.txt"
echo

# Enter name, description and hostname of the task
read -p "Enter your name : " name
read -p "Enter a description of the task to be performed : " task_desc
hostname=$(hostname)

# Write the user name, task description, timestamp, and hostname(device name) to the file
echo "Name : $name" >> ../mnt2/Forensic_Info.txt
echo "Task Description : $task_desc" >> ../mnt2/Forensic_Info.txt
echo "Hostname : $hostname" >> ../mnt2/Forensic_Info.txt
echo "Name, task description and hostname has been saved"
echo
cat ../mnt2/Forensic_Info.txt
echo

# Permission for scripts and hash value program
sudo chmod +x *.bash
sudo chmod +x Active_Scripts/*.bash
sudo chmod +x Inactive_Scripts/*.bash
sudo chmod 777 hash.exe

# Check if the OS is Ubuntu
if [ -f "/etc/lsb-release" ]; then
	sudo ./Ubuntu_Forensic.bash
# Check if the OS is CentOS
elif [ -f "/etc/centos-release" ]; then
        sudo ./RedHat_Forensic.bash
else
    echo "Unsupported OS"
fi

