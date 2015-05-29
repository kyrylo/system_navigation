#include <ruby.h>

static VALUE rb_eSourceNotFoundError;

static VALUE
mMethodExtensions_source(VALUE self)
{
    VALUE method = rb_iv_get(self, "@method");
    VALUE source_location = rb_funcall(method, rb_intern("source_location"), 0);
    VALUE name = rb_funcall(method, rb_intern("name"), 0);

    if (NIL_P(source_location)) {
        rb_raise(rb_eSourceNotFoundError,
                 "Could not locate source for %s!", RSTRING_PTR(rb_sym2str(name)));
    }

    return name;
}

void Init_method_source_code(void)
{
    VALUE rb_cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    VALUE rb_mMethodSourceCode = rb_define_module_under(rb_cSystemNavigation,
							"MethodSourceCode");

    rb_eSourceNotFoundError = rb_define_class_under(rb_mMethodSourceCode,
						    "SourceNotFoundError",
						    rb_eStandardError);

    VALUE rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode,
							"MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source", mMethodExtensions_source, 0);
}
