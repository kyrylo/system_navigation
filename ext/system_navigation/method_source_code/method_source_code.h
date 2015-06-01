#include <stdio.h>
#include <ruby.h>
#include "node.h"

#ifdef _WIN32
#include <io.h>
static cosnt char *null_filename = "NUL";
#define DUP(fd) _dup(fd)
#define DUP2(fd, newfd) _dup2(fd, newfd)
#else
#include <unistd.h>
static const char *null_filename = "/dev/null";
#define DUP(fd) dup(fd)
#define DUP2(fd, newfd) dup2(fd, newfd)
#endif

#define MAXLINES 1000
#define MAXLINELEN 300

static int find_relevant_lines(char *lines[], char *relevant_lines[],
			       const int start_line, const int end_line);
static int read_lines(const char *filename, char *lines[]);
static char **allocate_lines(const int maxlines);
static void reallocate_lines(char **lines[], int line_count);
static char *extract_first_expression(char *lines[], const int linect);
static VALUE mMethodExtensions_source(VALUE self);
static int is_complete_expression(char *expr);
static VALUE parse_expr(VALUE rb_str);
static NODE *with_silenced_stderr(NODE *(*compile)(const char*, VALUE, int),
				  VALUE rb_str);
