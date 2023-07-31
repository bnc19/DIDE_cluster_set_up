# This repo details how to get set up on the DIDE cluster
  

To get started on the cluster there are already [instructions](https://mrc-ide.github.io/didehpc/articles/didehpc.html#getting-started) written by Rich and Wes, who developed the cluster. 
You should definitely read and refer back to these instructions, however, they can be high-level in places and assume you have a DIDE ICT account, etc. 

The instructions below and the code in this repo hopefully provide a step-by-step introduction to using the cluster.

* N.B. All instructions for remote access, network mapping, and cluster are DIDE-specific. That means any imperial instructions for the above don't necessarily apply here.* 

## Useful contacts:
* DIDE ICT: Chris De La Force or Paul Bunnett e.g. DIDE ICT accounts, computer help, mapping your network drive.
* Setting up the cluster: Wes Hinsley
* Other cluster questions: Wes Hinsley, Rich Fitzjohn 

## Getting set up:

1) Email Chris De La Force or Paul Bunnett: 
* Ask them to set you up a DIDE ICT account if you don't already have one. Your DIDE username is the same as your imperial one without ic.ac.uk (e.g. bnc19).
* Ask them to set up you up a home share - this is a folder specific to you on the DIDE network share where you will run your cluster jobs from (see step 4).
* Check with them about which VPN / Unified access you should use for remote accessing the DIDE network. Currently, it is *Zscalar* but it does seem to change so double-check. If it is Zscalar, instructions are covered in step 4 below. If it is anything else, Chris or Paul will be able to provide instructions. 

2) Once you have your DIDE ICT account, email Wes and ask him to authorise you to use the cluster (send him your DIDE username). 

3) If you are using a laptop or any computer where you don't log in using your DIDE ICT account you next need to set up a Zscaler. In the cluster instructions linked above it mentioned setting up a VPN, however as of 2023 DIDE no longer uses a VPN for remote access. Instead, we use Unified Access via a product called Zscaler Private Access. To see if you already have access, login to https://uafiles.cc.ic.ac.uk/ - it might now work on some browsers so try an alternative browser if it doesn't work at first. If you still do not have access, Paul or Chris can request this for you. Once you have access, download Zscalar and log in with your imperial credentials (or it might be DIDE so you may need to try both).

If you are using a DIDE computer (or remotely accessing a DIDE computer from your laptop) you can go straight to step 4.

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
From here create a folder and i) either copy the R files and data etc. that you need to run your model on the cluster or ii) create your R project within this folder. If you're not using R projects then make sure that you set your working directory in your R session to this location - e.g. setwd("Q:/project_name")
 
6) To set up the cluster for the first time and see some examples of using the cluster, save the folders of this repository in a folder on your network drive called "DIDE_cluster_set_up":
   * *R* - a folder containing scripts of all functions used. 
   * *scripts* - a folder containing a script to set up the cluster and a script to run models on the cluster. 
   * *data* - a folder containing data used for model fitting.
  
  In general, this is a good way to organise your projects. 

Alternatively, if you've used Github before, you can clone this whole repo by clicking the green code button, copying the SSH key then go to R --> create project --> version control --> Git --> paste the SSH key in Repository URL and create the project as a subdirectory of your Q:/ drive.  

8) Open *scripts/cluster_set_up.R* first to configure your cluster settings and run a demo function. 

9) Once you are happy with running a simple function on the cluster, open *scripts/cluster_model_runs.R* for some further examples showing how to run multiple jobs at once. 


