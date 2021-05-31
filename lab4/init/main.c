// balloon system main.c
// copyright @ValKmjolnir
// 2021

#ifndef __MAIN_C__
#define __MAIN_C__

#define NULL 0
#include "../kernel/cstring.h"
#include "../kernel/printk.h"
#include "../kernel/input.h"

long system_stack[2048];
struct
{
    long *esp; // esp &system_stack[2048]
    short ss;  // ss  0x10
}stack_start={&system_stack[2048],0x10};

int help()
{
    printk("This is a toy OS written by ValKmjolnir\n");
    return 0;
}

int version()
{
    printk("Balloon OS v0.0.4\n");
    printk("___  ____          __   __  _  _\n");
    printk("|__] |__| |   |   |  | |  | |\\ |\n");
    printk("|__] |  | |__ |__ |__| |__| | \\|\n");
    return 0;
}

struct
{
    char* cmd_name;
    int (*func_ptr)();
}command_info[]=
{
    {"help",help},
    {"version",version},
    {NULL,NULL}
};

void execcmd(const char* buf)
{
    for(int i=0;command_info[i].cmd_name;++i)
        if(!strcmp(command_info[i].cmd_name,buf))
        {
            command_info[i].func_ptr();
            return;
        }
    printk("%s: command not found\n",buf);
    return;
}

int main()
{
    char buf[256];
    clean();
    printk("Balloon OS\n");
    printk("Copyright @ValKmjolnir 2021\n");
    printk("https://github.com/ValKmjolnir\n");
    while(1)
    {
        printk("$> ");
        getline(255,buf);
        execcmd(buf);
    }
    return 0;
}
#endif