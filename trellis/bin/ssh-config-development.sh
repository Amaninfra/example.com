host="example.dev"
sed "/^$/d;s/Host /$NL&/" ~/.ssh/config | sed '/^Host '"$host"'$/,/^$/d;' > config &&
cat config > ~/.ssh/config &&
rm config &&
vagrant ssh-config --host example.dev >> ~/.ssh/config
