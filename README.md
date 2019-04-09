# ChaosCompanion

To only check out the server do the following: 

```
mkdir chaos_server
cd chaos_server
git init
git remote add -f origin origin git@github.com:gedemagt/chaos_flutter.git
git config core.sparsecheckout true
echo server/ >> .git/info/sparse-checkout
git pull
```
