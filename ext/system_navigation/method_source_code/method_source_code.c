#include <ruby.h>

static VALUE
mMethodExtensions_source(VALUE self)
{
    VALUE method = rb_iv_get(self, "@method");

    return rb_funcall(method, rb_intern("source_location"), 0);
}

void Init_method_source_code(void)
{
    VALUE rb_cSystemNavigation = rb_define_class("SystemNavigation", rb_cObject);
    VALUE rb_mMethodSourceCode = rb_define_module_under(rb_cSystemNavigation, "MethodSourceCode");
    VALUE rb_mMethodExtensions = rb_define_module_under(rb_mMethodSourceCode, "MethodExtensions");

    rb_define_method(rb_mMethodExtensions, "source", mMethodExtensions_source, 0);
}
