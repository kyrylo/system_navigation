/* REALLOCATE! */
#include "method_source_code.h"


static VALUE rb_eSourceNotFoundError;

static int
read_lines(const char *filename, char **lines[], const int start_line)
{
    FILE *fp;
    ssize_t read;
    char *line = NULL;
    size_t len = 0;
    int line_count = 0;
    int i = 0;

    fp = fopen(filename, "r");
    if (fp == NULL) {
        rb_raise(rb_eIOError, "No such file or directory - %s", filename);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
	    if (line_count < start_line) {
		    line_count++;
		    continue;
	    }

        if ((i != 0) && (i % MAXLINES == 0)) {
            reallocate_lines(lines, line_count);
        }

        strncpy((*lines)[i], line, read);
	(*lines)[i][read] = '\0';
	i++;
	line_count++;
    }

    free(line);
    fclose(fp);

    return line_count;
}

static void
reallocate_lines(char **lines[], int line_count)
{
    int new_size = line_count + MAXLINES;
    char **temp_lines = realloc(*lines, sizeof(char *) * new_size);

    if (temp_lines == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory");
    } else {
        *lines = temp_lines;

	for (int i = line_count; i < new_size; i++) {
		if (((*lines)[i] = malloc(MAXLINELEN)) == NULL) {
			rb_raise(rb_eNoMemError, "failed to allocate memory");
		}
	}
    }
}

static NODE *
with_silenced_stderr(NODE *(*compile)(const char*, VALUE, int), VALUE rb_str)
{
    int old_stderr;
    FILE *null_fd;

    old_stderr = DUP(STDERR_FILENO);
    fflush(stderr);
    null_fd = fopen(null_filename, "w");
    DUP2(fileno(null_fd), STDERR_FILENO);

    NODE *node = (*compile)("-", rb_str, 1);

    fflush(stderr);
    fclose(null_fd);

    DUP2(old_stderr, STDERR_FILENO);
    close(old_stderr);

    return node;
}

static NODE *
parse_expr(VALUE rb_str) {
    return with_silenced_stderr(rb_compile_string, rb_str);
}

static VALUE
find_expression(char **lines[], const int end_line)
{
    char *expr = malloc(end_line * MAXLINELEN);
    VALUE rb_expr;

    expr[0] = '\0';
    for (int i = 0; i < end_line; i++) {
	    char *line = (*lines)[0];
	    size_t line_len = strlen(line);
	    for (size_t j = 0; j < line_len; j++) {
		    if (line[j] == '#' && line[j + 1] == '{') {
			    int k = j + 2;
			    line[j] = 't';
			    line[j + 1] = 't';
			    while (line[k] != '}') {
				    line[k++] = 't';
			    }
			    line[k] = 't';
			    break;
		    }
	    }

	    printf("%s", (*lines)[i]);
	    strcat(expr, (*lines)[i]);
	    rb_expr = rb_str_new2(expr);
	    if (parse_expr(rb_expr)) {
		    return rb_expr;
	    }
    }

    return Qnil;
}

static VALUE
mMethodExtensions_source(VALUE self)
{
    VALUE method = rb_iv_get(self, "@method");
    VALUE source_location = rb_funcall(method, rb_intern("source_location"), 0);
    VALUE name = rb_funcall(method, rb_intern("name"), 0);

    if (NIL_P(source_location)) {
        rb_raise(rb_eSourceNotFoundError, "Could not locate source for %s!",
		 RSTRING_PTR(rb_sym2str(name)));
    }

    char **lines;
    if ((lines = malloc(sizeof(char *) * MAXLINES)) == NULL) {
	    rb_raise(rb_eNoMemError, "failed to allocate memory");
    }

    for (int i = 0; i < MAXLINES; i++) {
	    if ((lines[i] = malloc(MAXLINELEN)) == NULL) {
		    rb_raise(rb_eNoMemError, "failed to allocate memory");
	    };
    }

    const char *filename = RSTRING_PTR(RARRAY_AREF(source_location, 0));
    const int start_line = FIX2INT(RARRAY_AREF(source_location, 1)) - 1;
    const int line_count = read_lines(filename, &lines, start_line);

    const int end_line = line_count - start_line;
    VALUE source = find_expression(&lines, end_line);

    for (int j = 0; j < MAXLINES; j++) {
	    free(lines[j]);
    }
    free(lines);

    return source;
}

void Init_method_source_code(void)
{
    VALUE rb_cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    VALUE rb_mMethodSourceCode = rb_define_module_under(rb_cSystemNavigation, "MethodSourceCode");

    rb_eSourceNotFoundError = rb_define_class_under(rb_mMethodSourceCode,"SourceNotFoundError", rb_eStandardError);
    VALUE rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode, "MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source", mMethodExtensions_source, 0);
}
