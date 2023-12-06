timeout 5 
copy D:\CabOS\launcher.cmd D:\CabOS\temp\updater\launcher-2.01.tmp 
copy D:\CabOS\temp\updater\launcher.tmp D:\CabOS\launcher.cmd  
start D:\CabOS\launcher.cmd noupdate 
