#! /bin/bash
sudo apt update

sudo apt install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
#sudo echo jenkins_admin_password="admin" >> /etc/environment
sudo apt install jenkins -y
sudo apt install xmlstarlet
sudo apt install python3-pip -y
pip3 install py-bcrypt
set -x
jenkins_admin_password="admin"

function wait_for_jenkins
{
  while (( 1 )); do
      echo "waiting for Jenkins to launch on port [8080] ..."

      nc -zv 127.0.0.1 8080
      if (( $? == 0 )); then
          break
      fi

      sleep 10
  done

  echo "Jenkins launched"
}


unction updating_jenkins_master_password
{
  cat > /tmp/jenkinsHash.py <<EOF
import bcrypt
import sys

if not sys.argv[1]:
  sys.exit(10)
plaintext_pwd=sys.argv[1]
encrypted_pwd=bcrypt.hashpw(plaintext_pwd, bcrypt.gensalt(10))
isCorrect=bcrypt.checkpw(plaintext_pwd, encrypted_pwd)
if not isCorrect:
  sys.exit(20);

print ("{}".format(encrypted_pwd))
EOF

  chmod +x /tmp/jenkinsHash.py

  # Wait till /var/lib/jenkins/users/admin* folder gets created
  sleep 10

  cd /var/lib/jenkins/users/admin*
  pwd
  while (( 1 )); do
      echo "Waiting for Jenkins to generate admin user's config file ..."

      if [[ -f "./config.xml" ]]; then
          break
      fi

      sleep 10
  done

  echo "Admin config file created"
  #sleep 100
  admin_password=$(python3 /tmp/jenkinsHash.py ${jenkins_admin_password} 2>&1)

  # Please do not remove alter quote as it keeps the hash syntax intact or else while substitution, $<character> will be replaced by null
  xmlstarlet -q ed --inplace -u "/user/properties/hudson.security.HudsonPrivateSecurityRealm_-Details/passwordHash" -v '#jbcrypt:'"$admin_password" config.xml
# Restart
  systemctl restart jenkins
  sleep 10
}

wait_for_jenkins

updating_jenkins_master_password

echo "Done"
exit 0


