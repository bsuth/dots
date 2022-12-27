/* user and group to drop privileges to */
static const char *user  = "bsuth";
static const char *group = "bsuth";

static const char *colorname[NUMCOLS] = {
	[BG] =     "#101012",   /* background */
	[INIT] =   "#4f525c",   /* after initialization */
	[INPUT] =  "#57a5e5",   /* during input */
	[FAILED] = "#de5d68",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 0;

/* size in px of cube */
static const int squaresize = 50;
