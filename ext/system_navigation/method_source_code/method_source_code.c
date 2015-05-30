#include <ruby.h>

static VALUE eSourceNotFoundError;

static VALUE
lines_for(VALUE file)
{
	return rb_io_s_readlines(1, file);
}

static VALUE
mMethodExtensions_source(VALUE self)
{
    VALUE method, source_location, name, file, line;

    method = rb_iv_get(self, "@method");
    source_location = rb_funcall(method, rb_intern("source_location"), 0);
    name = rb_funcall(method, rb_intern("name"), 0);

    if (NIL_P(source_location)) {
        rb_raise(eSourceNotFoundError, "Could not locate source for %s!",
		 RSTRING_PTR(rb_sym2str(name)));
    }

    file = RSTRING_PTR(RARRAY_AREF(source_location, 0));
    line = RARRAY_AREF(source_location, 1);

    return lines_for(file);
    /* return expression_at(lines_for(file), line); */
}

void Init_method_source_code(void)
{
    VALUE cSystemNavigation, mMethodSourceCode, mMethodExtensions;

    cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    mMethodSourceCode = rb_define_module_under(cSystemNavigation, "MethodSourceCode");

    eSourceNotFoundError = rb_define_class_under(mMethodSourceCode,
						 "SourceNotFoundError",
						 rb_eStandardError);

    mMethodExtensions = rb_define_module_under(mMethodSourceCode, "MethodExtensions");

    rb_define_method(mMethodExtensions, "source", mMethodExtensions_source, 0);
}
