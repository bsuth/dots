local ffi = require("ffi")

-- https://docs.gtk.org/gio/class.DBusConnection.html
-- /usr/include/glib-2.0/gio/gdbusconnection.h

ffi.cdef([[
typedef struct {} GDBusConnection;

typedef void (*GDBusSignalCallback) (
  GDBusConnection* connection,
  const gchar* sender_name,
  const gchar* object_path,
  const gchar* interface_name,
  const gchar* signal_name,
  GVariant* parameters,
  gpointer user_data
);

GDBusConnection* g_bus_get_sync(
  GBusType bus_type,
  GCancellable* cancellable,
  GError** error
);

void g_dbus_connection_call(
  GDBusConnection* connection,
  const gchar* bus_name,
  const gchar* object_path,
  const gchar* interface_name,
  const gchar* method_name,
  GVariant* parameters,
  const GVariantType* reply_type,
  GDBusCallFlags flags,
  gint timeout_msec,
  GCancellable* cancellable,
  GAsyncReadyCallback callback,
  gpointer user_data
);

GVariant* g_dbus_connection_call_finish(
  GDBusConnection* connection,
  GAsyncResult* res,
  GError** error
);

GVariant* g_dbus_connection_call_sync(
  GDBusConnection* connection,
  const gchar* bus_name,
  const gchar* object_path,
  const gchar* interface_name,
  const gchar* method_name,
  GVariant* parameters,
  const GVariantType* reply_type,
  GDBusCallFlags flags,
  gint timeout_msec,
  GCancellable* cancellable,
  GError** error
);

guint g_dbus_connection_signal_subscribe(
  GDBusConnection* connection,
  const gchar* sender,
  const gchar* interface_name,
  const gchar* member,
  const gchar* object_path,
  const gchar* arg0,
  GDBusSignalFlags flags,
  GDBusSignalCallback callback,
  gpointer user_data,
  GDestroyNotify user_data_free_func
);

void g_dbus_connection_signal_unsubscribe(
  GDBusConnection* connection,
  guint subscription_id
);
]])
