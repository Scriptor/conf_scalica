####This is a primer on how to gain access to and manage aws resources.

I assume you have your ~/.ssh directory set up with your public and private keys as well as the .pem file you received from creating your first aws instance. If this is not the case please refer to this simple tutorial: https://help.github.com/articles/generating-ssh-keys.

> ~/.ssh  
>> config  
>> id_rsa  
>> id_rsa.pub  
>> jax_aws.pem  

If you have not setup your ssh config file (~/.ssh/config) I recommend you do so now. The contents should be similar to the example contents I have printed below. You will replace the HostName with the public IP Address of your ec2 instance. Name the Host whatever you please--I named mine scalica below. Thus, when I want to connect to the server from my machine I type (assuming that you follow the steps in the scripts included):

	$ ssh scalica
	$ scp local/source/file scalica:path/to/destination/file

~/.ssh/config example:


------------------------------------------------------------
Host scalica  
&nbsp;&nbsp;&nbsp;&nbsp;HostName 216.58.219.238  
&nbsp;&nbsp;&nbsp;&nbsp;User jax  
&nbsp;&nbsp;&nbsp;&nbsp;IdentityFile ~/.ssh/id_rsa  
Host cims  
&nbsp;&nbsp;&nbsp;&nbsp;HostName access.cims.nyu.edu  
&nbsp;&nbsp;&nbsp;&nbsp;User jax85  
&nbsp;&nbsp;&nbsp;&nbsp;ForwardX11 yes  
&nbsp;&nbsp;&nbsp;&nbsp;IdentityFile ~/.ssh/id_rsa

------------------------------------------------------------


1. Create your aws account.
2. Set up your ec2 instance.
3. Copy your public IP address for your ec2 instance.

Then, run the following commands:

	$ git clone https://github.com/avash/conf_scalica.git conf_scalica
	$ cat ~/.ssh/id_rsa.pub > conf_scalica/id_rsa.tmp
	$ scp -rpC -i ~/.ssh/jax_aws.pem conf_scalica ubuntu@216.58.219.238:
	$ rm conf_scalica/id_rsa.tmp
	$ ssh -i ~/.ssh/jax_aws.pem ubuntu@216.58.219.238
	$ cd conf_scalica
	$ chmod 700 aws_ubuntu.sh
	$ ./aws_ubuntu.sh
	
Now you should be able to log in as we planned above:

	$ ssh scalica
	
And run the server with:
	
	$ python manage.py runserver 0:8000
