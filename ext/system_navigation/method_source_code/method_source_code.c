#include "method_source_code.h"


static VALUE rb_eSourceNotFoundError;
static int glob=0;

static int
read_lines(const char *filename, char **file[], const int start_line)
{
    FILE *fp;
    ssize_t read;
    char *line = NULL;
    char *occupied_line;
    size_t len = 0;
    int line_count = 0;
    int occupied_lines = 0;

    fp = fopen(filename, "r");
    if (fp == NULL) {
        rb_raise(rb_eIOError, "No such file or directory - %s", filename);
    }

    while ((read = getline(&line, &len, fp)) != -1) {
        if (line_count < start_line) {
            line_count++;
            continue;
        }


        if ((occupied_lines != 0) && (occupied_lines % (MAXLINES-1) == 0)) {
            reallocate_lines(file, occupied_lines);
        }

	// Not working properly yet...
        /* if (read >= MAXLINELEN) { */
        /*     char *tmp; */

        /*     if ((tmp = realloc((*file)[occupied_lines], read + 1)) == NULL) { */
        /*         rb_raise(rb_eNoMemError, "failed to allocate memory"); */
        /*     } */

        /*     line = tmp; */
	/* } */

	occupied_line = (*file)[occupied_lines];
        strncpy(occupied_line, line, read);
	occupied_line[read] = '\0';
	occupied_lines++;
    }

    free(line);
    fclose(fp);

    return occupied_lines;
}

static void
reallocate_lines(char **lines[], int occupied_lines)
{
    int new_size = occupied_lines + MAXLINES + 1;
    char **temp_lines = realloc(*lines, sizeof(*temp_lines) * new_size);

    if (temp_lines == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory");
    } else {
        *lines = temp_lines;

        for (int i = 0; i < MAXLINES; i++) {
            if (((*lines)[occupied_lines + i] = malloc(sizeof(char) * MAXLINELEN)) == NULL) {
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

static char *
filter_interp(char *line)
{
	char *match;
	char *prev_ch;
	int i;

	if ((match = strstr(line, "#{")) != NULL) {
		i = 0;

		if ((prev_ch = (match - 1))[0] == '\\') {
			*prev_ch = VALID_CHAR;
		}

		while (match[i] != '}') {
			match[i++] = VALID_CHAR;
		}
		match[i] = VALID_CHAR;
	}

	return match;
}

static int
contains_end_kw_or_accessor(const char *line)
{
	char *match;
	char prev_ch;

	if ((match = strstr(line, "end")) != NULL) {
		prev_ch = (match - 1)[0];
		return prev_ch == ' ' || prev_ch == '\0' || prev_ch == ';';
	} else if (strstr(line, "install_have_children_element") != NULL) {
		return 1;
	} else {
		return strstr(line, "attr_") != NULL;
	}
}

static int
is_dynamic_definition(const char *first_line)
{
    return strstr(first_line, "def ") == NULL &&
	    strstr(first_line, "attr_") == NULL;
}

static int
is_comment(const char *line)
{
	size_t line_len = strlen(line);

	for (size_t i = 0; i < line_len; i++) {
		if (line[i] == ' ')
			continue;

		if (line[i] == '#' && line[i + 1] != '{') {
			for (size_t j = i - 1; j != 0; j--) {
				if (line[j] != ' ')
					return 0;
			}

			return 1;
		}
	}

	return 0;
}

static VALUE
find_expression(char **file[], const int relevant_lines_count)
{
    char *expr = malloc(relevant_lines_count * MAXLINELEN);
    VALUE rb_expr;
    char *line = NULL;

    expr[0] = '\0';
    if (is_dynamic_definition((*file)[0])) {
	    for (int i = 0; i < relevant_lines_count; i++) {
		    strcat(expr, (*file)[i]);
		    rb_expr = rb_str_new2(expr);

		    if (parse_expr(rb_expr)) {
			    free(expr);
			    return rb_expr;
		    }
	    }
    } else {
	    for (int i = 0; i < relevant_lines_count; i++) {
		    line = (*file)[i];

		    if (is_comment(line))
			    continue;

		    while (filter_interp(line) != NULL)
			    continue;

		    if (i == 0) {
			    if (is_dynamic_definition(line)) {
				    rb_expr = rb_str_new2(expr);

				    if (parse_expr(rb_expr)) {
					    free(expr);
					    return rb_expr;
				    }
			    }
		    }

		    strcat(expr, line);

		    if (contains_end_kw_or_accessor(line)) {
			    rb_expr = rb_str_new2(expr);

			    if (parse_expr(rb_expr)) {
				    free(expr);
				    return rb_expr;
			    }
		    }
	    }
    }

    free(expr);
    rb_raise(rb_eSyntaxError, "failed to parse expression");

    return Qnil;
}

static char **
allocate_memory_for_file(void)
{
    char **file;

    if ((file = malloc(sizeof(*file) * MAXLINES)) == NULL) {
        rb_raise(rb_eNoMemError, "failed to allocate memory");
    }

    for (int i = 0; i < MAXLINES; i++) {
        if ((file[i] = malloc(sizeof(char) * MAXLINELEN)) == NULL) {
            rb_raise(rb_eNoMemError, "failed to allocate memory");
        };
    }

    return file;
}

static void
free_memory_for_file(char **file[], const int occupied_lines)
{
    for (int i = 0; i < occupied_lines; i++) {
        free((*file)[i]);
    }

    free(*file);
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

    char **file = allocate_memory_for_file();

    const char *filename = RSTRING_PTR(RARRAY_AREF(source_location, 0));
    const int start_line = FIX2INT(RARRAY_AREF(source_location, 1)) - 1;

    const int occupied_lines = read_lines(filename, &file, start_line);

    VALUE expression = find_expression(&file, occupied_lines);

    free_memory_for_file(&file, occupied_lines);

    return expression;
}

void Init_method_source_code(void)
{
    VALUE rb_cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    VALUE rb_mMethodSourceCode = rb_define_module_under(rb_cSystemNavigation, "MethodSourceCode");

    rb_eSourceNotFoundError = rb_define_class_under(rb_mMethodSourceCode,"SourceNotFoundError", rb_eStandardError);
    VALUE rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode, "MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source", mMethodExtensions_source, 0);
}
