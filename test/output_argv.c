#include <Windows.h>
#include <stdio.h>

int main(int argc, char *argv[]){
  int a;
  printf("===>%s<===\n", GetCommandLine());
  for(a=0; a<argc; a++){
    printf("===>%s<===\n", argv[a]);
  }
  return 0;
}
