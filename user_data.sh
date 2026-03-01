#!/bin/bash

# Add Mongo repo
cat <<'REPO' | tee /etc/yum.repos.d/mongodb-org.repo >/dev/null
[mongodb-org]
name=MongoDB Repo
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/5.0/x86_64/
gpgcheck=0
enabled=1
REPO

yum -y install mongodb-org
systemctl enable mongod
systemctl start mongod

# Wait until Mongo is ready
until mongosh --quiet --eval "db.runCommand({ ping: 1 })" >/dev/null 2>&1; do
  sleep 2
done

# Create admin user
mongosh --quiet --eval "db=db.getSiblingDB('admin'); if (db.getUser('${MONGO_USER}')==null) { db.createUser({user:'${MONGO_USER}', pwd:'${MONGO_PASS}', roles:[{role:'root', db:'admin'}]}); }"

# Enable authentication
echo -e "\nsecurity:\n  authorization: enabled" | tee -a /etc/mongod.conf >/dev/null

systemctl restart mongod

yum -y install awscli

# backup script
cat > /usr/local/bin/mongo_backup.sh <<EOF
#!/bin/bash
DATE=\$(date +%F-%H-%M)
mongodump --username ${MONGO_USER} --password ${MONGO_PASS} --authenticationDatabase admin --out /tmp/backup-\$DATE
tar -czf /tmp/backup-\$DATE.tgz /tmp/backup-\$DATE
aws s3 cp /tmp/backup-\$DATE.tgz s3://${BACKUP_BUCKET}/
rm -rf /tmp/backup-\$DATE /tmp/backup-\$DATE.tgz
EOF

chmod +x /usr/local/bin/mongo_backup.sh

# run once at boot 
/usr/local/bin/mongo_backup.sh

# schedule daily at 9pm 
(crontab -l 2>/dev/null; echo "0 21 * * * /usr/local/bin/mongo_backup.sh") | crontab -