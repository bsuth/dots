local ffi = require("ffi")

-- https://docs.gtk.org/glib/struct.VariantType.html
-- /usr/include/glib-2.0/glib/gvarianttype.h

ffi.cdef([[
typedef struct {} GVariantType;

GVariantType* g_variant_type_new(const gchar* type_string);
void g_variant_type_free(GVariantType* type);

const gchar* g_variant_type_peek_string(const GVariantType* type);
gsize g_variant_type_get_string_length(const GVariantType* type);

gboolean g_variant_type_is_array(const GVariantType* type);
gboolean g_variant_type_is_basic (const GVariantType  *type);
gboolean g_variant_type_is_container (const GVariantType  *type);
gboolean g_variant_type_is_dict_entry(const GVariantType* type);
gboolean g_variant_type_is_maybe(const GVariantType* type);
gboolean g_variant_type_is_tuple(const GVariantType* type);
gboolean g_variant_type_is_variant(const GVariantType* type);

const GVariantType* g_variant_type_element(const GVariantType* type);
const GVariantType* g_variant_type_first(const GVariantType* type);
const GVariantType* g_variant_type_next(const GVariantType* type);
const GVariantType* g_variant_type_key(const GVariantType* type);
const GVariantType* g_variant_type_value(const GVariantType* type);
gsize g_variant_type_n_items(const GVariantType* type);
]])
