struct foo (
	char x;
	int y;
	char *z;
);

main(argc, argv)
char **argv;
{
	struct foo bruh;
	bruh.x = 'C';
	bruh.y = 123;
	bruh.z = "test";
	printf("x = '%c', y = %d, z = \"%s\"\n", bruh.x, bruh.y, bruh.z);
}
