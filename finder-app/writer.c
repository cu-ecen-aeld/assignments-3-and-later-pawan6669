#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<syslog.h>

int  main(int argc, char *argv[])  {
    
	//printf("Number of arguments passed: %d \n", argc);
	openlog ("WriterLog", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);
	
	if (argc < 3) {
		//printf(" Insufficient arguments specified \n");
		syslog(LOG_PERROR, "Insufficient arguments provided");
		exit(1);
	} else {
		FILE *fd = fopen(argv[1],"w+");
		char *writeStr = argv[2];
		//printf("Argument1 : %s \n",argv[0]);
		//printf("Argument2 : %s \n",argv[1]);
		//printf("Argument3 : %s \n",argv[2]);

		if (fd==NULL) {
			//printf("Unable to open the file. Please check if the directory exists!! \n");
			syslog(LOG_PERROR, "Unable to open the file. Please check the directory");
			exit(1);
		} else {
			//printf("File opened successfully. Writing to it!!! \n");
			//printf("Size of the string: %d \n", sizeof(argv[2]));
			//printf("Sizeof of the string with strlen: %d \n", strlen(argv[2]) );
			syslog(LOG_DEBUG, "Writing %s to %s", writeStr, argv[1]);
			fwrite(argv[2], sizeof(char) , strlen(writeStr), fd);
			fclose(fd);
		}
	}
	closelog();
}


