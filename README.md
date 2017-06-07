Here's a dump of a really basic shell script I've used for my backups. Note it only keeps however many backups you configure it to keep. 

You will need to edit the variables to fit your context.

Invoke it from /etc/crontab at your leisure. Note that its clean-up depends on the file names being alphabetisable by date, so don't change the date format.

