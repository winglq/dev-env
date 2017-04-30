export sess_name="dev"
tmux new -s $sess_name -d
tmux rename-window -t $sess_name:0 "code"
tmux new-window -t $sess_name:1 -n "log"
tmux select-window -t $sess_name:0
