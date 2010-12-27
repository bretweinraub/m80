#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>


int main(int argc, char *argv[]) {
  pid_t pid;
//  char *args[] = {"-t", "-l", (char *) 0 };
  pid = fork();
  if (pid == -1) { 
    /* fork error - cannot create child */
    exit(1);
  }
  else if (pid == 0) {
    /* code for child */
    int i;
    /* shift the command off the arg list */
    char *cmd = argv[1];
    char *args[argc - 1];
    for (i = 1 ; i < argc; i++) {
      args[i - 1] = argv[i];
    }
    args[argc - 1] = NULL;
    printf("%s: ", cmd);
    for (i = 0; i < argc - 1 ; i++) { printf("%s ", args[i]); }
    printf("\n");
    execvp(cmd, args);
    printf("Something bad happened!\n");
    _exit(1);
  }
  else { /* code for parent */ 
    exit(0);
  }
}
