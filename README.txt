
To move across changes from STEREO-OPS machine to my desktop machine to GitHub, I perform the following steps.

1) In my personal folder jbyrne on STEREO-OPS machine I update my folder called STEREO-OPS_content:

rsync -avuSH --delete-after --exclude 'tracks' --exclude 'a' --exclude 'b' /soft/ukssdc/share/Solar/HELCATS/ STEREO-OPS_content/

2) From STEREO-OPS machine I copy across to my desktop machine:

rsync -avuSH --delete-after jbyrne@stereo-ops.stp.rl.ac.uk:STEREO-OPS_content/ STEREO-OPS_content/

3) Commit and push changes in my HELCATS folder to GitHub:

cd HELCATS/
git status
git add ...
git commit ...
etc
