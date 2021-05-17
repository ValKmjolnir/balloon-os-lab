// balloon system printk.c
// copyright @ValKmjolnir
// 2021

#ifndef __PRINTK_C__
#define __PRINTK_C__

#include <stdint.h>
#include <stdarg.h>
#define VGA_BEGIN 0xb8000
#define SCREEN_WID 80
#define SCREEN_HGT 25

char printk_buffer[512];

void balloon_putc(uint8_t x,uint8_t y,char c)
{
    uint16_t* monitor=(uint16_t*)VGA_BEGIN;
    uint32_t idx=x+y*SCREEN_WID;
    monitor[idx]=(monitor[idx]&0xff00)|c;
    return;
}

void clean()
{
    for(uint8_t y=0;y<SCREEN_HGT;++y)
        for(uint8_t x=0;x<SCREEN_WID;++x)
            balloon_putc(x,y,'\0');
    return;
}

void vprintk(const char* fmt,va_list ap)
{
    char* tmp=printk_buffer;
    for(int i=0;fmt[i];++i)
    {
        if(fmt[i]=='%' && fmt[i+1])
        {
            ++i;
            switch(fmt[i])
            {
                case 'c':*tmp++=va_arg(ap,int);break;
                case 'd':
                    {
                        int num=va_arg(ap,int);
                        if(!num)
                            *tmp++='0';
                        if(num<0)
                        {
                            *tmp++='-';
                            num=-num;
                        }
                        int width=1;
                        while(num/width)
                            width*=10;
                        width/=10;
                        while(width)
                        {
                            *tmp++=(char)('0'+num/width);
                            num%=width;
                            width/=10;
                        }
                    }
                    break;
                case '%':*tmp++='%';break;
                default:--i;*tmp++='%';break;
            }
        }
        else
        {
            *tmp++=fmt[i];
        }
        if(tmp-printk_buffer>511)
            break;
    }
    *tmp='\0';
    return;
}

void printk(const char* fmt,...)
{
    static uint8_t x=0,y=0;
    va_list ap;
    va_start(ap,fmt);
    vprintk(fmt,ap);
    va_end(ap);
    for(char* tmp=printk_buffer;*tmp;++tmp)
    {
        if(*tmp=='\n')
        {
            x=0;
            ++y;
        }
        else if(*tmp=='\r')
            x=0;
        else if(*tmp=='\b')
        {
            --x;
            if(x<0)
                x=0;
            balloon_putc(x,y,' ');
        }
        else
        {
            if(x>=SCREEN_WID)
            {
                x=0;
                ++y;
            }
            if(y>=SCREEN_HGT)
            {
                x=y=0;
                clean();
            }
            balloon_putc(x,y,*tmp);
            ++x;
        }
    }
    return;
}

#endif