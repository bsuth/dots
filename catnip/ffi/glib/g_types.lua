local ffi = require("ffi")

-- https://docs.gtk.org/glib/types.html
-- /usr/include/glib-2.0/glib/gtypes.h

ffi.cdef([[
typedef char gchar;
typedef short gshort;
typedef long glong;
typedef int gint;
typedef gint gboolean;

typedef unsigned char guchar;
typedef unsigned short gushort;
typedef unsigned long gulong;
typedef unsigned int guint;

typedef float gfloat;
typedef double gdouble;

typedef void* gpointer;
typedef const void *gconstpointer;
]])

-- https://docs.gtk.org/glib/types.html
-- /usr/lib/glib-2.0/include/glibconfig.h

ffi.cdef([[
typedef signed char gint8;
typedef unsigned char guint8;

typedef signed short gint16;
typedef unsigned short guint16;

typedef signed int gint32;
typedef unsigned int guint32;

typedef signed long gint64;
typedef unsigned long guint64;

typedef signed long gssize;
typedef unsigned long gsize;

typedef gint64 goffset;

typedef signed long gintptr;
typedef unsigned long guintptr;
]])

-- https://docs.gtk.org/glib/index.html#classes

ffi.cdef([[
  typedef struct {} GError;
  typedef struct {} GObject;
]])

-- https://docs.gtk.org/glib/index.html#callbacks
-- /usr/include/glib-2.0/glib/gtypes.h

ffi.cdef([[
typedef gint (*GCompareFunc) (gconstpointer a, gconstpointer b);
typedef gint (*GCompareDataFunc) (gconstpointer a, gconstpointer b, gpointer user_data);
typedef gboolean (*GEqualFunc) (gconstpointer a, gconstpointer b);
typedef gboolean (*GEqualFuncFull) (gconstpointer a, gconstpointer b, gpointer user_data);
typedef void (*GDestroyNotify) (gpointer data);
typedef void (*GFunc) (gpointer data, gpointer user_data);
typedef guint (*GHashFunc) (gconstpointer key);
typedef void (*GHFunc) (gpointer key, gpointer value, gpointer user_data);
]])
