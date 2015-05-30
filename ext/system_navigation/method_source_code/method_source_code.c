#include <ruby.h>

static VALUE rb_eSourceNotFoundError;

static VALUE
lines_for(VALUE file)
{
	return rb_io_s_readlines(1, file);
}

static VALUE
source(VALUE self)
{
    VALUE method, source_location, name, file, line;

    method = rb_iv_get(self, "@method");
    source_location = rb_funcall(method, rb_intern("source_location"), 0);
    name = rb_funcall(method, rb_intern("name"), 0);

    if (NIL_P(source_location)) {
        rb_raise(rb_eSourceNotFoundError, "Could not locate source for %s!",
		 RSTRING_PTR(rb_sym2str(name)));
    }

    file = RSTRING_PTR(RARRAY_AREF(source_location, 0));
    line = RARRAY_AREF(source_location, 1);

    return lines_for(file);
    /* return expression_at(lines_for(file), line); */
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

    rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode, "MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source", source, 0);
}
