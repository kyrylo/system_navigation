#include <ruby.h>

static VALUE eSourceNotFoundError;

static VALUE
mMethodExtensions_source(VALUE self)
{
    VALUE method = rb_iv_get(self, "@method");
    VALUE source_location = rb_funcall(method, rb_intern("source_location"), 0);
    VALUE name = rb_funcall(method, rb_intern("name"), 0);

    if (NIL_P(source_location)) {
        rb_raise(eSourceNotFoundError, "Could not locate source for %s!",
		 RSTRING_PTR(rb_sym2str(name)));
    }

    return name;
}

void Init_method_source_code(void)
{
    VALUE cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    VALUE mMethodSourceCode = rb_define_module_under(cSystemNavigation,
						     "MethodSourceCode");

    eSourceNotFoundError = rb_define_class_under(mMethodSourceCode,
						 "SourceNotFoundError",
						 rb_eStandardError);

    VALUE mMethodExtensions = rb_define_module_under(mMethodSourceCode,
						     "MethodExtensions");

    rb_define_method(mMethodExtensions, "source", mMethodExtensions_source, 0);
}
