/* REALLOCATE! */

#include "method_source_code.h"

#define MAXLINES 1000
#define MAXLINELEN 300

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
    FILE *fp = fopen(filename, "r");
    if (fp == NULL) {
        rb_raise(rb_eIOError, "No such file or directory - %s", filename);
    }

    ssize_t read;
    char *cur_line = NULL;
    size_t cur_line_len = 0;
    int line_count = 0;
    while ((read = getline(&cur_line, &cur_line_len, fp)) != -1) {
        strncpy(lines[line_count++], cur_line, cur_line_len);
    }

    free(cur_line);
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
        lines[i] = malloc(sizeof(char) * MAXLINELEN);
    }

    return lines;
}

static VALUE
parse_expr(char str[]) {
    return rb_funcall(sexp_builder(), rb_intern("parse"), 1, rb_str_new2(str));
}

static VALUE
sexp_builder(void)
{
    VALUE rb_cRipper = rb_const_get_at(rb_cObject, rb_intern("Ripper"));
    VALUE rb_cSexpBuilder = rb_const_get_at(rb_cRipper, rb_intern("SexpBuilder"));

    return rb_cSexpBuilder;
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
    if (parse_expr(expr) != Qnil) {
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

    VALUE source = rb_str_new2(expr);
    free(expr);

    return source;
}

void Init_method_source_code(void)
{
    VALUE rb_cSystemNavigation, rb_mMethodSourceCode, rb_mMethodExtensions;

    rb_require("ripper");

    rb_cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    rb_mMethodSourceCode = rb_define_module_under(rb_cSystemNavigation,
						  "MethodSourceCode");

    rb_eSourceNotFoundError = rb_define_class_under(rb_mMethodSourceCode,
						    "SourceNotFoundError",
						    rb_eStandardError);

    rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode,
						  "MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source",
		     mMethodExtensions_source, 0);
}
