
#include <stdio.h>
#include "main.h"

void startup(void)
{
    puts("[CORE] startup");
}

void shutdown(void)
{
    puts("[CORE] shutdown");
}

void simulate(void)
{
    puts("[CORE] simulating...");
}

int main(void)
{
    startup();
    simulate();
    shutdown();
    return 0;
}
