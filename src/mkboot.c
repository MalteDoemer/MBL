#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>
#include <inttypes.h>

#ifndef ARCH
#define ARCH x86_64
#endif

#if ARCH == x86_64
#define STAGE1_BINARY _binary_bin_x86_64_stage1_bin_start
#else
#error Unsupported Architecture
#endif

extern uint8_t* STAGE1_BINARY;

void usage();
void version();
void parse_addr(uint16_t* segment, uint16_t* offset);
uint64_t parse_int64();
uint16_t parse_int16();

const char* programm;

int main(int argc, char* const* argv)
{
    struct option opts[7];

    const char* disk;

    int opt, ind, ret;

    uint64_t lba;
    uint64_t seek;
    uint32_t size;
    uint16_t seg, off;

    lba = 1;
    seek = 0;
    size = 50;
    seg = 0;
    off = 0x800;
    memset(opts, 0, sizeof(opts));
    programm = argv[0];

    opts[0].name = "help";
    opts[0].has_arg = 0;
    opts[0].flag = NULL;
    opts[0].val = 'h';

    opts[1].name = "version";
    opts[1].has_arg = 0;
    opts[1].flag = NULL;
    opts[1].val = 'v';

    opts[2].name = "lba";
    opts[2].has_arg = 1;
    opts[2].flag = NULL;
    opts[2].val = 'l';

    opts[3].name = "size";
    opts[3].has_arg = 1;
    opts[3].flag = NULL;
    opts[3].val = 's';

    opts[4].name = "address";
    opts[4].has_arg = 1;
    opts[4].flag = NULL;
    opts[4].val = 'a';

    opts[5].name = "partition";
    opts[5].has_arg = 1;
    opts[5].flag = NULL;
    opts[5].val = 'p';

    while ((opt = getopt_long(argc, argv, "hvl:s:a:p:", opts, &ind)) != -1) {
        switch (opt) {
        case 'h':
            usage();
            return 0;

        case 'v':
            version();
            return 0;

        case 'l':
            lba = parse_int64();
            break;

        case 'p':
            seek = parse_int64();
            break;

        case 's':
            size = parse_int16();
            if (size < 1 || size > 50) {
                printf("%s: size must be between 1 and 50\n", programm);
                return 1;
            }
            break;

        case 'a':
            parse_addr(&seg, &off);
            break;

        case '?':
            printf("type '%s -h' for help\n", programm);
            return 1;
        }
    }

    if (optind == argc) {
        printf("%s: missing required argument <disk>\n", programm);
        printf("type '%s -h' for help\n", programm);
        return 1;
    }

    disk = argv[optind];
    optind++;

    if (optind != argc) {
        printf("%s: too many arguments\n", programm);
        printf("type '%s -h' for help\n", programm);
        return 1;
    }

    FILE* fp;
    uint8_t boot[512];
    uint8_t data[512];
    

    memset(boot, 0, sizeof(boot));

    fp = fopen(disk, "r+");
    if (fp == NULL) {
        fp = fopen(disk, "w+");
    }

    if (fp == NULL) {
        printf("%s: Failed to create '%s'\n", programm, disk);
        return 1;
    }

    fseek(fp, seek, SEEK_SET);
    fread(data, 1, sizeof(data), fp);

    memcpy(boot, (void*)&STAGE1_BINARY, 512);
    
    memcpy(boot + 3, data + 3, 87);

    memcpy(boot + 426, &size, 2);
    memcpy(boot + 428, &off, 2);
    memcpy(boot + 430, &seg, 2);
    memcpy(boot + 432, &lba, 8);

    fseek(fp, seek, SEEK_SET);
    fwrite(boot, 1, sizeof(boot), fp);

    fclose(fp);
    return 0;
}

void usage()
{
    static const char* msg = "usage: mkboot [option...] [--] <disk>\n"
                             "\n"
                             "Installs a boot record on <disk>. <disk> can be any file or device.\n"
                             "\n"
                             "   -h --help               Display help and exit\n"
                             "   -v --version            Display version and exit\n"
                             "\n"
                             "   -l --lba <lba>          The lba address where to find the second stage. (default 1)\n"
                             "   -p --partition <lba>    The lba of the partition start. Here stage1 gets installed. (default 0)\n"
                             "   -s --size <blocks>      The size in blocks (512-bytes) of the second stage. Must be between 1 and 50. (default 50)\n"
                             "   -a --address <seg:off>  The memory addres to load the second stage. (default 0x00:0x0800)\n"
                             "\n"
                             "\n"
                             "All numbers can either be specified in decimal or in hex using the '0x' prefix.\n"
                             "For more information visit ''.\n"
                             "\n";
    printf("%s", msg);
}

void version()
{
    printf("mkboot version 1.0.0\n");
}

void parse_addr(uint16_t* segment, uint16_t* offset)
{
    uint16_t seg, off;
    seg = off = 0;

    seg = parse_int16();
    if (*optarg != ':') {
        printf("%s: invalid address format\n", programm);
        printf("type '%s -h' for help\n", programm);
        exit(1);
    }
    optarg++;
    off = parse_int16();

    *segment = seg;
    *offset = off;
}

uint64_t parse_int64()
{
    uint64_t res = 0;

    if (*optarg == '0' && *(optarg + 1) == 'x') {
        optarg += 2;

        while (*optarg >= '0' && *optarg <= '9' || *optarg >= 'A' && *optarg <= 'F' || *optarg >= 'a' && *optarg <= 'f') {
            res *= 16;

            if (*optarg >= '0' && *optarg <= '9') {
                res += (*optarg) - '0';
            } else if (*optarg >= 'A' && *optarg <= 'F') {
                res += (*optarg) - 'A';
            } else if (*optarg >= 'a' && *optarg <= 'f') {
                res += (*optarg) - 'a';
            }
            optarg++;
        }
    } else {
        while (*optarg >= '0' && *optarg <= '9') {
            res *= 10;
            res += (*optarg) - '0';
            optarg++;
        }
    }

    return res;
}

uint16_t parse_int16()
{
    uint16_t res = 0;

    if (*optarg == '0' && *(optarg + 1) == 'x') {
        optarg += 2;

        while (*optarg >= '0' && *optarg <= '9' || *optarg >= 'A' && *optarg <= 'F' || *optarg >= 'a' && *optarg <= 'f') {
            res *= 16;

            if (*optarg >= '0' && *optarg <= '9') {
                res += (*optarg) - '0';
            } else if (*optarg >= 'A' && *optarg <= 'F') {
                res += (*optarg) - 'A';
            } else if (*optarg >= 'a' && *optarg <= 'f') {
                res += (*optarg) - 'a';
            }
            optarg++;
        }
    } else {
        while (*optarg >= '0' && *optarg <= '9') {
            res *= 10;
            res += (*optarg) - '0';
            optarg++;
        }
    }

    return res;
}
