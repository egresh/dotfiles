# start up an ssh-agent listening process so that it's not necessary
# to type in a password for ssh keys
AGENT_FILE=~/.ssh/ssh-agent

if [ -e $AGENT_FILE ]; then

    AGENT_PID=`grep AGENT_PID $AGENT_FILE | awk '{ print $1 }' | \
               cut -d'=' -f2 | cut -d';' -f1`

    if  ps ux | grep $AGENT_PID | grep ssh-agent > /dev/null 2>&1; then
        # We found an ssh-agent process running with the PID
        # identified in the ~/.ssh/ssh-agent file and this
        # process is owned by this usera. Just bail.
        source $AGENT_FILE
    fi
else
    ssh-agent > $AGENT_FILE
    perl -pi -e 's/echo.*//' $AGENT_FILE
    source $AGENT_FILE
fi
