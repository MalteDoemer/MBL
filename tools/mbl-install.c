#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <getopt.h>

#define PART_MBR 0
#define PART_GPT 1

#define FIRM_BIOS 0
#define FIRM_UEFI 1

#define DEFAULT_DIR "mbl/"

void usage();
void version();
void error_exit(const char* fmt, ...) __attribute__((noreturn)) __attribute__((format(printf, 1, 2)));

const char* prog;

int main(int argc, char* const* argv)
{
    prog = argv[0];

    int opt;
    char* device;

    char* dir = DEFAULT_DIR;
    int part = PART_MBR;
    int firm = FIRM_BIOS;

    while ((opt = getopt(argc, argv, "hvp:b:d:")) != -1) {
        switch (opt) {
        case 'h':
            usage();
            return 0;
        case 'v':
            version();
            return 0;
        case 'd':
            dir = strdup(optarg);
            break;
        case 'p':
            if (strcmp("mbr", optarg) == 0)
                part = PART_MBR;
            else if (strcmp("gpt", optarg) == 0)
                part = PART_GPT;
            else
                error_exit("%s: unknown parition schema: %s\n", prog, optarg);
            break;
        case 'b':
            if (strcmp("bios", optarg) == 0)
                firm = FIRM_BIOS;
            else if (strcmp("uefi", optarg) == 0)
                firm = FIRM_UEFI;
            else
                error_exit("%s: unknown firmware interface: %s\n", prog, optarg);
            break;
        }
    }

    if (optind == argc)
        error_exit("%s: missing reqired argument <device>\n", prog);

    device = argv[optind++];

    if (optind != argc)
        error_exit("%s: too many arguments\n", prog);

    if (firm == FIRM_UEFI)
        error_exit("%s: uefi not yet supported\n", prog);


    

    return 0;
}

void usage()
{
    static const char* msg = "usage: %s [option...] <device>\n"
                             "Install mbl on <device>.\n"
                             "\n"
                             "-h             display help and exit\n"
                             "-v             display version and exit\n"
                             "\n"
                             "-p mbr|gpt     select a partition scheme\n"
                             "-b bios|uefi   select the firmware interface\n"
                             "-d directory   set the directory where to find the images\n"
                             "\n";
    printf(msg, prog);
}

void version()
{
    static const char* msg = "mbl-install version 1.0.0\n";
    printf("%s", msg);
}

__attribute__(()) void error_exit(const char* fmt, ...)
{
    va_list va;
    va_start(va, fmt);
    vprintf(fmt, va);
    va_end(va);
    printf("type '%s -h' for help\n", prog);
    exit(1);
}