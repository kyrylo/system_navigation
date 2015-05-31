#include <ruby.h>

static int find_relevant_lines(char *lines[], char *relevant_lines[],
			       const int start_line, const int end_line);
static int read_lines(const char *filename, char *lines[]);
static char **allocate_lines(const int maxlines);
static VALUE sexp_builder(void);
static char *extract_first_expression(char *lines[], const int linect);
static VALUE mMethodExtensions_source(VALUE self);

static int is_complete_expression(char *expr);
