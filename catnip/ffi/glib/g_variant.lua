local ffi = require("ffi")

-- https://docs.gtk.org/glib/struct.Variant.html
-- /usr/include/glib-2.0/glib/gvariant.h

ffi.cdef([[
typedef struct {} GVariant;

GVariant* g_variant_new(const gchar* format_string, ...);
GVariant* g_variant_new_boolean(gboolean value);
GVariant* g_variant_new_byte(guint8 value);
GVariant* g_variant_new_dict_entry(GVariant* key, GVariant* value);
GVariant* g_variant_new_double(gdouble value);
GVariant* g_variant_new_int16(gint16 value);
GVariant* g_variant_new_int32(gint32 value);
GVariant* g_variant_new_int64(gint64 value);
GVariant* g_variant_new_object_path(const gchar* object_path);
GVariant* g_variant_new_signature(const gchar* signature);
GVariant* g_variant_new_string(const gchar* string);
GVariant* g_variant_new_uint16(guint16 value);
GVariant* g_variant_new_uint32(guint32 value);
GVariant* g_variant_new_uint64(guint64 value);

GVariant* g_variant_ref(GVariant *value);
void g_variant_unref(GVariant *value);
gboolean g_variant_is_floating(GVariant *value);

const GVariantType* g_variant_get_type(GVariant *value);
const gchar* g_variant_get_type_string(GVariant *value);
gboolean g_variant_is_of_type(GVariant *value, const GVariantType *type);
GVariantClass g_variant_classify(GVariant *value);

gboolean g_variant_get_boolean(GVariant* value);
guint8 g_variant_get_byte(GVariant* value);
GVariant* g_variant_get_child_value(GVariant* value, gsize index);
gdouble g_variant_get_double(GVariant* value);
gint16 g_variant_get_int16(GVariant* value);
gint32 g_variant_get_int32(GVariant* value);
gint64 g_variant_get_int64(GVariant* value);
GVariant* g_variant_get_maybe(GVariant* value);
const gchar* g_variant_get_string(GVariant* value, gsize* length);
guint16 g_variant_get_uint16(GVariant* value);
guint32 g_variant_get_uint32(GVariant* value);
guint64 g_variant_get_uint64(GVariant* value);
GVariant* g_variant_get_variant(GVariant* value);

gsize g_variant_n_children(GVariant* value);
]])
