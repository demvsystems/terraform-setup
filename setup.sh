read -p "Wie ist der Projektname?': " EINGABE

find . -type f -name "*.tf*" -print0 | xargs -0 sed -i'' -e "s/<projektname>/${EINGABE}/g"
find . -type f -name "*.tfvars" -print0 | xargs -0 sed -i'' -e "s/<projektname>/${EINGABE}/g"

read -p "Wie ist der KMS-Key?': " EINGABE

find . -type f -name "*.tf*" -print0 | xargs -0 sed -i'' -e "s/<kms-key>/${EINGABE}/g"
