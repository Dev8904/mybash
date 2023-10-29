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

checkEnv(){
    ## Check if the current directory is writable.
    if [[ ! -w ${installed_dir} ]];then
        echo -e "${CER}Can't write to ${installed_dir}${CNT}"
        exit 1
    fi

    ## Check for requirements.
    REQUIREMENTS='curl yay sudo'
    if ! which ${REQUIREMENTS}>/dev/null;then
        echo -e "${CER}To run me,https://github.com/fearlessgeekmedia/mybash you need: ${REQUIREMENTS}${CNT}"
        exit 1
    fi

    ## Check if member of the wheel group.
    if ! groups|grep wheel>/dev/null;then
        echo -e "${CER}You need to be a member of the wheel to run me!"
        exit 1
    fi
}

installDepend(){
    ## Check for dependencies.
    # For some reason, if I put autojump in the original DEPENDENCIES variable, 
    # it skips the installation and just does bash and bash completion. So I
    # put autojump in a separate variable and separate yay command.
    DEPENDENCIES1='bash bash-completion'
    DEPENDENCIES2='autojump'
    DEPENDENCIES2='autojump-git'
    echo -e "${CAC}Installing dependencies...${CNT}"
    yay -S ${DEPENDENCIES1}
    yay -S ${DEPENDENCIES2}
    yay -S ${DEPENDENCIES3}
    sudo mkdir /usr/local/bin/autojump
    sudo ln -s /etc/profile.d/autojump.sh /usr/share/autojump/autojump.sh
}

installStarship(){
    if ! curl -sS https://starship.rs/install.sh|sh;then
        echo -e "${CER}Something went wrong during starship install!${CNT}"
        exit 1
    fi
}

linkConfig(){
    ## Check if a bashrc file is already there.
    OLD_BASHRC="${HOME}/.bashrc"
    if [[ -e ${OLD_BASHRC} ]];then
        echo -e "${CAC}Moving old bash config file to ${HOME}/.bashrc.bak${CNT}"
        if ! mv ${OLD_BASHRC} ${HOME}/.bashrc.bak;then
            echo -e "${CER}Can't move the old bash config file!${CNT}"
            exit 1
        fi
    fi

    echo -e "${CAC}Linking new bash config file...${CNT}"
    ## Make symbolic link.
    ln -svf ${installed_dir}/.bashrc ${HOME}/.bashrc
    ln -svf ${installed_dir}/starship.toml ${HOME}/.config/starship.toml
}

checkEnv
installDepend
installStarship
if linkConfig;then
    echo -e "${COK}Done!\nrestart your shell to see the changes.${CNT}"
else
    echo -e "${CER}Something went wrong!${CNT}"
fi
