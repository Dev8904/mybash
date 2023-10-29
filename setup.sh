##################################################################################################################
#Author  : Jonathan Marshall
#Github  : https://github.com/Dev8904
###########################################################################################################################

#Declaring our installed directory
installed_dir=$(dirname "$(readlink -f "$(basename "$(pwd)")")")

##################################################################################################################
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

command_exists () {
    command -v $1 >/dev/null 2>&1;
}

checkEnv() {
    ## Check for requirements.
    REQUIREMENTS='curl groups sudo'
    if ! command_exists ${REQUIREMENTS}; then
        echo -e "${CER}To run me, you need: ${REQUIREMENTS}${CNT}"
        exit 1
    fi

    ## Check Package Handeler
    PACKAGEMANAGER='apt pacman'
    for pgm in ${PACKAGEMANAGER}; do
        if command_exists ${pgm}; then
            PACKAGER=${pgm}
            echo -e "Using ${pgm}"
        fi
    done

    if [ -z "${PACKAGER}" ]; then
        echo -e "${CER}Can't find a supported package manager"
        exit 1
    fi


    ## Check if the current directory is writable.
    if [[ ! -w ${INSTALLED_DIR} ]]; then
        echo -e "${CER}Can't write to ${INSTALLED_DIR}${CNT}"
        exit 1
    fi

    ## Check SuperUser Group
    SUPERUSERGROUP='wheel sudo root'
    for sug in ${SUPERUSERGROUP}; do
        if groups | grep ${sug}; then
            SUGROUP=${sug}
            echo -e "Super user group ${SUGROUP}"
        fi
    done

    ## Check if member of the sudo group.
    if ! groups | grep ${SUGROUP} >/dev/null; then
        echo -e "${CER}You need to be a member of the sudo group to run me!"
        exit 1
    fi
    
}

installDepend() {
    ## Check for dependencies.
    DEPENDENCIES='autojump bash bash-completion tar bat'
    echo -e "${CAC}Installing dependencies...${CNT}"
    if [[ $PACKAGER == "pacman" ]]; then
        if ! command_exists yay; then
            echo "Installing yay..."
            sudo ${PACKAGER} --noconfirm -S base-devel
            $(cd /opt && sudo git clone https://aur.archlinux.org/yay-git.git && sudo chown -R ${USER}:${USER} ./yay-git && cd yay-git && makepkg --noconfirm -si)
        else
            echo "Command yay already installed"
        fi
    	yay --noconfirm -S ${DEPENDENCIES}
    else 
    	sudo ${PACKAGER} install -yq ${DEPENDENCIES}
    fi
}

installStarship(){
    if command_exists starship; then
        echo "Starship already installed"
        return
    fi

    if ! curl -sS https://starship.rs/install.sh|sh;then
        echo -e "${CER}Something went wrong during starship install!${CNT}"
        exit 1
    fi
}

linkConfig() {
    ## Get the correct user home directory.
    USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${USER_HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]]; then
        echo -e "${CAC}Moving old bash config file to ${USER_HOME}/.bashrc.bak${CNT}"
        if ! mv ${OLD_BASHRC} ${USER_HOME}/.bashrc.bak; then
            echo -e "${CER}Can't move the old bash config file!${CNT}"
            exit 1
        fi
    fi

    echo -e "${CAC}Linking new bash config file...${CNT}"
    ## Make symbolic link.
    ln -svf ${INSTALLED_DIR}/.bashrc ${USER_HOME}/.bashrc
    ln -svf ${INSTALLED_DIR}/starship.toml ${USER_HOME}/.config/starship.toml
}

checkEnv
installDepend
installStarship
if linkConfig; then
    echo -e "${COK}Done!\nrestart your shell to see the changes.${CNT}"
else
    echo -e "${CER}Something went wrong!${CNT}"
fi
