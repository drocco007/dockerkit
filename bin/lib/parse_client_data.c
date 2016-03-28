#include <yaml.h>

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>


typedef enum status_e {
    FIND_CLIENT,
    FIND_MAPPING,
    FIND_KEY,
    FIND_VALUE,
    IGNORE_ALL
} status_t;


int
process_event(yaml_event_t *event, const char *client_key,
              const char * var_name)
{
    static status_t status = FIND_CLIENT;
    static char key[4096];
    const char *value = (char *)event->data.scalar.value;

    if (event->type == YAML_STREAM_END_EVENT) {
        return 1;
    }

    switch(status) {
        case FIND_CLIENT:
            if (event->type == YAML_SCALAR_EVENT &&
                    strcmp(value, client_key) == 0) {
                printf("unset %s\n", var_name);
                printf("declare -Ag %s\n", var_name);
                status = FIND_MAPPING;
            }

            break;

        case FIND_MAPPING:
            if (event->type == YAML_MAPPING_START_EVENT)
                status = FIND_KEY;

            break;

        case FIND_KEY:
        case FIND_VALUE:
            if (event->type == YAML_SCALAR_EVENT) {
                if (status == FIND_KEY)
                    strncpy(key, value, sizeof key);
                else
                    printf("%s[%s]=%s\n", var_name, key,
                           event->data.scalar.value);

                status = (status == FIND_KEY) ? FIND_VALUE : FIND_KEY;
            } else if (event->type == YAML_MAPPING_END_EVENT) {
                status = IGNORE_ALL;
                return 1;
            }

            break;

        case IGNORE_ALL:
            break;
    }

    return 0;
}


int
main(int argc, char *argv[])
{
    FILE *file;
    char *client_key = argv[2];
    char *var_name = argv[3];

    yaml_parser_t parser;
    yaml_event_t input_event;

    int done = 0;
    int error = 0;

    if (argc != 4) {
        printf("Usage: %s data.yaml client_key VAR_NAME\n", argv[0]);
        return -1;
    }

    file = fopen(argv[1], "rb");
    assert(file);

    assert(yaml_parser_initialize(&parser));

    yaml_parser_set_input_file(&parser, file);

    while (!done)
    {
        if (!yaml_parser_parse(&parser, &input_event)) {
            error = -1;
            puts("YAML parse error!");
            break;
        }

        done = process_event(&input_event, client_key, var_name);
    }

    yaml_parser_delete(&parser);

    assert(!fclose(file));

    return 0;
}
