#!/bin/bash
# Variables:
machineip=
masterip=
releasetag=

# Functions:
function get_machine_ip(){
    ifconfig | grep -oP "inet addr:\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}" | grep -oP "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}" | sort | head -n 1
}

function install_osh(){
    releaseurl="https://api.github.com/repos/openebs/maya/releases"

    # Update apt and get dependencies
    sudo apt-get update
    sudo apt-get install -y unzip curl wget

    # Install docker and K8s
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF >/dev/null
    deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
    sudo apt-get update
    # Install docker if you don't have it already.
    sudo apt-get install -y docker.io

    # Install Maya binaries
    if [ -z "$releasetag" ]; then
        wget $(curl -sS $releaseurl | grep "browser_download_url" | awk '{print $2}' | tr -d '"' | head -n 2 | tail -n 1)
    else
        wget https://github.com/openebs/maya/releases/download/$releasetag/maya-linux_amd64.zip
    fi
    unzip maya-linux_amd64.zip
    sudo mv maya /usr/bin
    rm -rf maya-linux_amd64.zip
}

function setup_osh(){
    maya setup-osh -self-ip=$machineip -omm-ips=$masterip
}

function prepare_osh() {
    sudo docker pull openebs/jiva:latest
}

function show_help() {
    cat << EOF
    Usage : $(basename "$0") --releasetag=[OpenEBS Maya Release Version]
    Installs the OpenEBS Maya Version 
    
    -h|--help                           Display this help and exit.
    -i|--masterip                       Maya Master IP
    -r|--release                        Maya Release Version
EOF
}

# Code:
 
if (($# == 0)); then
    show_help
    exit 2
fi

while :; do
    case $1 in
        -h|-\?|--help)  # Call a "show_help" function to display a synopsis, then exit.
                        show_help
                        exit
                        ;;
        
        -i|--masterip)  # Takes an option argument, ensuring it has been specified.
                        if [ -n "$2" ]; then
                            masterip=$2
                            shift
                        else
                            printf 'ERROR: "--masterip" requires a non-empty option argument.\n' >&2
                            exit 1
                        fi
                        ;;
        
        --masterip=?*)  # Delete everything up to "=" and assign the remainder.
                        masterip=${1#*=} 
                        ;;
        
        --masterip=)    # Handle the case of an empty --masterip=
                        printf 'ERROR: "--masterip" requires a non-empty option argument.\n' >&2
                        exit 1
                        ;;

        -r|--releasetag) # Takes an option argument, ensuring it has been specified.
                        if [ -n "$2" ]; then
                            releasetag=$2
                            shift
                        else
                            printf 'ERROR: "--token" requires a non-empty option argument.\n' >&2
                            exit 1
                        fi
                        ;;
        
        --releasetag=?*) # Delete everything up to "=" and assign the remainder.
                        releasetag=${1#*=} 
                        ;;
        
        --releasetag=)  # Handle the case of an empty --token=
                        printf 'ERROR: "--releasetag" requires a non-empty option argument.\n' >&2
                        exit 1
                        ;;
        
        --)             # End of all options.
                        shift
                        break
                        ;;
        
        -?*)
                        printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
                        ;;

        *)              # Default case: If no more options then break out of the loop.
                        break
    esac
shift
done

if [ -z "$masterip" ]; then
    echo "MasterIP is mandatory."
    show_help
    exit    
fi

#Get the ip of the machine
machineip=`get_machine_ip`

#Install OpenEBS Maya Components
echo Installing OpenEBS on Host...
install_osh

#Join the Cluster
echo Setting up the Host using IPAddress: $machineip
setup_osh

#Prepare for VSMs
echo Downloading latest VSM image
prepare_osh
