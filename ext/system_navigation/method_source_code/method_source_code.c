#include <ruby.h>

#define MAXLINES 1000
#define MAXLINELEN 300

static VALUE rb_eSourceNotFoundError;

static int
read_lines(const char *file, char *lines[])
{
    FILE *fp = fopen(file, "r");
    if (fp == NULL) {
        rb_raise(rb_eIOError, "No such file or directory - %s", file);
    }

    ssize_t read;
    char *cur_line = NULL;
    size_t cur_line_len = 0;
    int line_count = 0;
    while ((read = getline(&cur_line, &cur_line_len, fp)) != -1) {
        strcpy(lines[line_count++], cur_line);
    }

    free(cur_line);
    fclose(fp);

    return line_count;
}

static VALUE
source(VALUE self)
{
    char **lines = malloc(sizeof(char *) * MAXLINES);
    for (int i = 0; i < MAXLINES; i++) {
        lines[i] = malloc(sizeof(char) * (MAXLINELEN + 1));
    }

    if (lines == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory");
    }

    VALUE method = rb_iv_get(self, "@method");
    VALUE source_location = rb_funcall(method, rb_intern("source_location"), 0);
    VALUE name = rb_funcall(method, rb_intern("name"), 0);

    if (NIL_P(source_location)) {
        rb_raise(rb_eSourceNotFoundError, "Could not locate source for %s!",
		 RSTRING_PTR(rb_sym2str(name)));
    }

    const char *file = RSTRING_PTR(RARRAY_AREF(source_location, 0));
    VALUE lineno = RARRAY_AREF(source_location, 1);

    int line_count = read_lines(file, lines);

    VALUE rb_lines = rb_ary_new2(line_count + 1);
    for(int j = 0; j < line_count; j++) {
	    rb_ary_push(rb_lines, rb_str_new2(lines[j]));
    }

    free(lines);

    return rb_lines;
}

void Init_method_source_code(void)
{
    VALUE rb_cSystemNavigation, rb_mMethodSourceCode, rb_mMethodExtensions;

    rb_cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    rb_mMethodSourceCode = rb_define_module_under(rb_cSystemNavigation,
						  "MethodSourceCode");

    rb_eSourceNotFoundError = rb_define_class_under(rb_mMethodSourceCode,
						    "SourceNotFoundError",
						    rb_eStandardError);

    rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode,
						  "MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source", source, 0);
}
