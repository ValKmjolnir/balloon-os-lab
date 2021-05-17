// balloon system main.c
// copyright @ValKmjolnir
// 2021

#ifndef __MAIN_C__
#define __MAIN_C__

long system_stack[1024];
struct
{
    long *esp; // esp &system_stack[1024]
    short ss;  // ss  0x10
}stack_start={&system_stack[1024],0x10};

int main()
{
    clean();
    printk("balloon OS\n");
    printk("copyright @ValKmjolnir 2021\n");
    printk(">> ");
    while(1)
    {
        //__asm__("hlt");
        char c=getchar();
        if(c>=0)
            printk("%c",c);
    }
    return 0;
}
#endif