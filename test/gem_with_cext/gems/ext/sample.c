#include "ruby.h"

static VALUE c_method(VALUE self)
{
  return 1;
}

void Init_sample(void)
{
  VALUE klass = rb_define_class("Sample", rb_cObject);
  rb_define_method(klass, "c_method", c_method, 0);
}
