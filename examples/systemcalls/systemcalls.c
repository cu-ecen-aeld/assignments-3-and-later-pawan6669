#include "systemcalls.h"

/**
 * @param cmd the command to execute with system()
 * @return true if the command in @param cmd was executed
 *   successfully using the system() call, false if an error occurred,
 *   either in invocation of the system() call, or if a non-zero return
 *   value was returned by the command issued in @param cmd.
*/
bool do_system(const char *cmd)
{

/*
 * TODO  add your code here
 *  Call the system() function with the command set in the cmd
 *   and return a boolean true if the system() call completed with success
 *   or false() if it returned a failure
*/
    int rid;
    if ( (rid = system(cmd)) == 0 ) {
	    printf(" In %s function succesfully executed with rid: %d \n",__func__, rid);
    	return true;

    }

    printf(" In %s function is not succesfully executed. Returned with %d\n",__func__, rid);
    return false;
}

/**
* @param count -The numbers of variables passed to the function. The variables are command to execute.
*   followed by arguments to pass to the command
*   Since exec() does not perform path expansion, the command to execute needs
*   to be an absolute path.
* @param ... - A list of 1 or more arguments after the @param count argument.
*   The first is always the full path to the command to execute with execv()
*   The remaining arguments are a list of arguments to pass to the command in execv()
* @return true if the command @param ... with arguments @param arguments were executed successfully
*   using the execv() call, false if an error occurred, either in invocation of the
*   fork, waitpid, or execv() command, or if a non-zero return value was returned
*   by the command issued in @param arguments with the specified arguments.
*/

bool do_exec(int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];

    va_end(args);
  
/*
 * TODO:
 *   Execute a system command by calling fork, execv(),
 *   and wait instead of system (see LSP page 161).
 *   Use the command[0] as the full path to the command to execute
 *   (first argument to execv), and use the remaining arguments
 *   as second argument to the execv() command.
 *
*/
    int kid;
    switch(kid = fork()) 
    {
		case -1: perror("fork");abort();
		case 0:
            		printf("This is child process with PID:"" %d \n",getpid());
            		if (execv(command[0], command) == 0 ) {
                		printf("child process Execv is success.  This should never be printed \n"); exit(0);
            		} else {
                		printf("Child process: execv failed \n"); //exit(-1);
				abort();
            		}


		default:
			printf("I am the parent process.  Child ID of the process is %d \n",kid);
            		int wstatus;
            		waitpid(kid, &wstatus, 0); // Store proc info into wstatus
			/*
            		int return_value = WEXITSTATUS(wstatus);
            		printf("The return from child process %d is %d \n", kid, return_value);
            		if (return_value == 0) {
                		return true;
            		} else {
                		return false;
            		}
			*/
			if(WIFEXITED(wstatus) ) {
				printf("The child process %d exited normally \n",kid);
				if (WEXITSTATUS(wstatus)!=0) {
					printf("child process existed but it did not run \n");
					return false;
				}
			} else {
				printf("The child process %d did not exit normally \n",kid);
				return false;
			}
			return true;
	}
    
}

/**
* @param outputfile - The full path to the file to write with command output.
*   This file will be closed at completion of the function call.
* All other parameters, see do_exec above
*/
bool do_exec_redirect(const char *outputfile, int count, ...)
{
    va_list args;
    va_start(args, count);
    char * command[count+1];
    int i;
    for(i=0; i<count; i++)
    {
        command[i] = va_arg(args, char *);
    }
    command[count] = NULL;
    // this line is to avoid a compile warning before your implementation is complete
    // and may be removed
    command[count] = command[count];


/*
 * TODO
 *   Call execv, but first using https://stackoverflow.com/a/13784315/1446624 as a refernce,
 *   redirect standard out to a file specified by outputfile.
 *   The rest of the behaviour is same as do_exec()
 *
*/
    va_end(args);

    int fd = open(outputfile, O_WRONLY|O_TRUNC|O_CREAT, 0666);
    if (fd < 0) { perror("open"); abort(); }
    int kid;
    switch(kid = fork()) {
		case -1: perror("fork");printf("Fork failed. Aborting!!! \n");abort();
		case 0:
            		if (dup2(fd, 1) < 0) {
                		perror("dup2"); abort();
            		}
            		close(fd);
            		printf("This is child process with PID: %d",getpid());
            		execvp(command[0], command); 
            		perror("child process execv had issue execv"); abort();

		default:
			printf("I am the parent process.  Child ID of the process is %d \n",kid);
            		int wstatus;
            		waitpid(kid, &wstatus, 0); // Store proc info into wstatus
			if(WIFEXITED(wstatus) ) {
				printf("The child process %d exited normally \n",kid);
				if (WEXITSTATUS(wstatus)!=0) {
					printf("child process existed but it did not run \n");
					return false;
				}
			} else {
				printf("The child process %d did not exit normally \n",kid);
				return false;
			}


    }

    return true;
}
