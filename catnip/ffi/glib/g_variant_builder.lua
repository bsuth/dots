local ffi = require("ffi")

-- https://docs.gtk.org/glib/struct.VariantBuilder.html
-- /usr/include/glib-2.0/glib/gvariant.h

ffi.cdef([[
typedef struct {} GVariantBuilder;

GVariantBuilder* g_variant_builder_new(const GVariantType* type);
void g_variant_builder_unref(GVariantBuilder* builder);

void g_variant_builder_open(GVariantBuilder *builder, const GVariantType *type);
void g_variant_builder_close(GVariantBuilder *builder);

void g_variant_builder_add_value(GVariantBuilder* builder, GVariant* value);
]])
