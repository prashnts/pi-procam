#!/bin/bash
sudo apt update
sudo apt install git supervisor -y

# Setting up the repo

mkdir -p ~/procam/pi-procam  # Where we'd deploy the working copy
git init --bare ~/procam/_bare_pi-procam.git
# Add git hook
cat << 'EOF' > ~/procam/_bare_pi-procam.git/hooks/post-receive
#!/bin/bash
TARGET="/home/pi/procam/pi-procam"
GIT_DIR="/home/pi/procam/_bare_pi-procam.git.git"
BRANCH="master"

while read oldrev newrev ref
do
	# only checking out the master (or whatever branch you would like to deploy)
	if [ "$ref" = "refs/heads/$BRANCH" ];
	then
		echo "Ref $ref received. Deploying ${BRANCH} branch to production..."
		git --work-tree=$TARGET --git-dir=$GIT_DIR checkout -f $BRANCH
        echo "=> Restarting services"
        sudo supervisorctl restart all
        echo "=> Deployed!"
	else
		echo "Ref $ref received. Doing nothing: only the ${BRANCH} branch may be deployed on this server."
	fi
done
EOF
chmod +x ~/procam/_bare_pi-procam.git/hooks/post-receive

echo "=> Setup of git repo complete. Pulling the default branch."

cd ~/procam/pi-procam
git clone https://github.com/prashnts/pi-procam.git .
