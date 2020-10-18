#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <getopt.h>

#define BYTES_PER_SECTOR 512
#define LBA_OFFSET 0x1B6
#define DEFAULT_DIR "/usr/lib/mbl/"
#define BIOS_BOOT_BIN "bios/boot.bin"
#define BIOS_CORE_BIN "bios/core.bin"

void usage();
void version();
void error_exit(const char* fmt, ...) __attribute__((noreturn)) __attribute__((format(printf, 1, 2)));

const char* prog;

int main(int argc, char* const* argv)
{
    prog = argv[0];

    int opt;
    char* dev_name;
    uint64_t start = 1;
    char* files = DEFAULT_DIR;

    while ((opt = getopt(argc, argv, "hvf:s:")) != -1) {
        switch (opt) {
        case 'h':
            usage();
            return 0;
        case 'v':
            version();
            return 0;
        case 's':
            start = atoll(optarg);
            break;
        case 'f':
            files = optarg;
            break;
        }
    }

    if (optind == argc)
        error_exit("%s: missing reqired argument <device>\n", prog);

    dev_name = argv[optind++];

    if (optind != argc)
        error_exit("%s: too many arguments\n", prog);

    char* name;
    uint8_t* mbr;
    uint8_t* core;
    FILE* boot_bin;
    FILE* core_bin;
    FILE* device;

    mbr = malloc(512);
    core = malloc(64 * 1024);

    if (!mbr || !core) {
        perror("error");
        return 1;
    }

    name = malloc(strlen(files) + sizeof(BIOS_BOOT_BIN));
    strncpy(name, files, strlen(files));
    strcat(name, BIOS_BOOT_BIN);
    boot_bin = fopen(name, "r");

    if (!boot_bin) {
        perror(name);
        return 1;
    }
    free(name);

    fread(mbr, 1, 440, boot_bin);
    fclose(boot_bin);

    name = malloc(strlen(files) + sizeof(BIOS_CORE_BIN));
    strncpy(name, files, strlen(files));
    strcat(name, BIOS_CORE_BIN);
    core_bin = fopen(name, "r");

    if (!core_bin) {
        perror(name);
        return 1;
    }

    free(name);
    fread(core, 1024, 64, core_bin);
    fclose(core_bin);

    device = fopen(dev_name, "r+");

    if (!device) {
        perror(dev_name);
        return 1;
    }

    memcpy((void*)(mbr + LBA_OFFSET), (void*)&start, 8);

    fseek(device, 0, SEEK_SET);
    fwrite(mbr, 1, 440, device);

    fseek(device, start * BYTES_PER_SECTOR, SEEK_SET);
    fwrite(core, 1024, 64, device);

    free(mbr);
    free(core);
    fclose(device);

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
                             "-s sector      set the starting sector of the second stage (default 1)\n"
                             "-f directory   set the directory where to find the images (default /usr/lib/mbl)\n"
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