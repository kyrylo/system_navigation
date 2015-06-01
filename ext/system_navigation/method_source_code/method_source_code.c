/* REALLOCATE! */
#include "method_source_code.h"


static VALUE rb_eSourceNotFoundError;

static int
find_relevant_lines(char *lines[], char *relevant_lines[],
		    const int start_line, const int end_line)
{
    int rel_lct = 0;

    do {
        relevant_lines[rel_lct] = lines[start_line + rel_lct];
    } while (rel_lct++ < end_line);

    return rel_lct;
}

static int
read_lines(const char *filename, char *lines[])
{
    FILE *fp;
    ssize_t read;
    char *line = NULL;
    size_t len = 0;
    int line_count = 0;

    fp = fopen(filename, "r");
    if (fp == NULL) {
        rb_raise(rb_eIOError, "No such file or directory - %s", filename);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        if ((line_count != 0) && (line_count % MAXLINES == 0)) {
            reallocate_lines(&lines, line_count);
        }
        strncpy(lines[line_count++], line, read);
    }

    free(line);
    fclose(fp);

    return line_count;
}

static char **
allocate_lines(const int maxlines) {
    char **lines = malloc(sizeof(char *) * maxlines);

    if (lines == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory");
    }

    for (int i = 0; i < maxlines; i++) {
        lines[i] = malloc(sizeof(char *) * MAXLINELEN);
    }

    return lines;
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
	    (*lines)[i] = malloc(sizeof(char *) * MAXLINELEN);
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

static VALUE
parse_expr(VALUE rb_str) {
    NODE *node = with_silenced_stderr(rb_compile_string, rb_str);
    return node ? Qtrue : Qfalse;
}

static char *
extract_first_expression(char *lines[], const int linect)
{
    char *expr = malloc(linect * MAXLINELEN);

    expr[0] = '\0';
    for (int i = 0; i < linect; i++) {
        strcat(expr, lines[i]);
        if (is_complete_expression(expr)) {
            return expr;
        }
    }

    return NULL;
}

static int
is_complete_expression(char *expr)
{
    if (parse_expr(rb_str_new2(expr)) == Qtrue) {
        return 1;
    } else {
        return 0;
    }
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

    const char *filename = RSTRING_PTR(RARRAY_AREF(source_location, 0));
    VALUE lineno = RARRAY_AREF(source_location, 1);

    char **lines = allocate_lines(MAXLINES);
    const int line_count = read_lines(filename, lines);

    char **relevant_lines = allocate_lines(line_count);
    const int start_line = FIX2INT(lineno) - 1;
    const int end_line = line_count - start_line;
    const int relevant_linect = find_relevant_lines(lines, relevant_lines,
						    start_line, end_line);

    char *expr = extract_first_expression(relevant_lines, relevant_linect);

    free(lines);
    free(relevant_lines);

    VALUE source = rb_str_new2(expr == NULL ? "" : expr);
    free(expr);

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
