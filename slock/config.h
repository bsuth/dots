/* user and group to drop privileges to */
static const char *user  = "nobody";
static const char *group = "nogroup";

static const char *colorname[NUMCOLS] = {
	[BG] =   "#101012",     /* background */
	[INIT] =   "#57a5e5",     /* after initialization */
	[INPUT] =  "#8fb573",   /* during input */
	[FAILED] = "#de5d68",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 0;
