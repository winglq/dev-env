export sess_name=$1
export host=$2

if [ -z $sess_name ]; then
        sess_name='dev'
fi

tmux new -s $sess_name -d
tmux rename-window -t $sess_name:0 "code"
tmux new-window -t $sess_name:1 -n "log"
tmux select-window -t $sess_name:0

if [ -z $host ]; then
        tmux attach -t $sess_name
        exit
fi
tmux send-keys "ssh root@$host" C-m
tmux select-window -t $sess_name:1
tmux send-keys "ssh root@$host" C-m
tmux select-window -t $sess_name:0
tmux attach -t $sess_name
