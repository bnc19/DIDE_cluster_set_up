# This repo details how to get set up on the DIDE cluster
  

To get started on the cluster there are excellent [instructions](https://mrc-ide.github.io/didehpc/articles/didehpc.html#getting-started) written by Rich and Wes, who developed the cluster. 
You should definitely read and refer back to these instructions, however they can be high level in places and assume you have a DIDE ICT accountetc. 
The instructions below hopefully provide a more step-by-step introduction to using the cluster.

* N.B. all instructions for VPNs, network mapping and cluster are DIDE specific. That means any imperial instructions for the above don't necessarily apply here.* 

## Useful contacts:
* DIDE ICT: Chris De La Force or Paul Bunnett e.g. DIDE ICT accounts, computer help, VPNs, mapping your network drive.
* Setting up the cluster: Wes Hinsley
* Other cluster questions: Wes Hinsley, Rich Fitzjohn 

## Getting set up:

1) Email Chris De La Force or Paul Bunnett: 
* Ask them to set you up a DIDE ICT account if you don't already have one. Your DIDE username is the same as your imperial one without ic.ac.uk (e.g. bnc19).
* Ask them to set up you up a home share - this is a folder specific to you on the DIDE network share where you will run you cluster jobs from (see step 4). 


2) Once you have your DIDE ICT account, email Wes and ask him to authorise you to use the cluster (send him your DIDE username). 

3) If you are using a laptop or any computer where you don't log in using your DIDE ICT account you need to set up a Zscaler. ADD DETAILS HERE. If you are using a DIDE computer (or remotely accessing a DIDE computer from your laptop) you do not need to set up a VPN.
4) The cluster cannot be run from folders saved on your computer desktop and the like - this means nothing with a file path starting C: ! Instead, you need to run everything from a folder on a network share. To do this you map your network drive to your folder on the network share. The path for this is: \\fi--san03.dide.ic.ac.uk\homes\username, where username is your DIDE username. 

To map your network drive on a Windows:
* Open file explorer 
* Go to "This PC"
* At the top click "Map network drive"
* In the window that appears, select any available drive letter from the Drive dropdown list (I use Q). 
* Where is says folder, paste the path above (\\fi--san03.dide.ic.ac.uk\homes\username)
* When prompted to enter your credentials use DIDE\username and your DIDE password.

To map your network drive on a Mac:
* Go to Finder
* Press Command + K which takes you to Connect to Server (or for the long way, Finder --> "Go" at the top left of the page --> Connect to Server). 
* Paste this path: smb://fi--san03.dide.ic.ac.uk/homes/username.
* Tick the Reconnect at logon and Connect using different credentials check boxes.
* Click Finish.
* When prompted to enter your credentials use DIDE\username and your DIDE password.

**If you get a warning here saying that the path cannot be accessed, check your home share has been set up (step 1)**

5) Go to your newly mapped network drive. On Windows your newly mapped network drive will be My PC -->:Q (or whatever letter you chose in step 4). On a Mac go to Network --> fi--san03.dide.ic.ac.uk --> Homes --> username. 
From here create a folder and i) either copy the R files and data etc. that you need to run your model on the cluster or ii) create your R project within this folder. If you're not using R projects then make sure that you set your working directory in your R session to this location - e.g. setwd("Q:/cluster_example")
 
6) To set up the cluster for the first time and see some examples of using the cluster, save all the R scripts in this repository in a folder on your network drive called "cluster_example". 

7) cluster_set_up.R first to configure your cluster settings and run a demo function. 

8) Once you are happy with running a simple function on the cluster, open cluster_model_runs.R for some further examples showing how to run multiple jobs at once. 


